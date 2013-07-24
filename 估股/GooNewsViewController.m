//
//  GooNewsViewController.m
//  UIDemo
//
//  Created by Xcode on 13-6-14.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "GooNewsViewController.h"
#import "CustomTableView.h"
#import "GooNewsCell.h"
#import "Utiles.h"
#import "EGORefreshTableHeaderView.h"
#import "WebKitAvailability.h"
#import "UIImageView+AFNetworking.h"
#import "GooGuuArticleViewController.h"
#import "MBProgressHUD.h"
#import "MHTabBarController.h"
#import "ArticleCommentViewController.h"
#import "DailyStockCell.h"
#import "UIImageView+AFNetworking.h"
#import "SVPullToRefresh.h"


@interface GooNewsViewController ()

@end

@implementation GooNewsViewController



@synthesize customTableView;
@synthesize newArrList;
@synthesize imageUrl;
@synthesize companyInfo;

@synthesize hud;

- (void)dealloc
{
    [companyInfo release];companyInfo=nil;
    [hud release];hud=nil;
    [customTableView release];customTableView=nil;
    [newArrList release];newArrList=nil;
    [imageUrl release];imageUrl=nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getGooGuuNews];
    
    self.title=@"小马新闻";
    
   	customTableView=[[CustomTableView alloc] initWithFrame:CGRectMake(0,0,320,370)];
    
    customTableView.dataSource=self;
    customTableView.delegate=self;
    
    [self.view addSubview:customTableView];

    [self.customTableView addInfiniteScrollingWithActionHandler:^{
        [self addGooGuuNews];
    }];
   
    if(_refreshHeaderView == nil)
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.customTableView.bounds.size.height, self.view.frame.size.width, self.customTableView.bounds.size.height)];
        
        view.delegate = self;
        [self.customTableView addSubview:view];
        _refreshHeaderView = view;
        [view release];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}





#pragma mark -
#pragma mark Net Get JSON Data

-(void)addGooGuuNews{
    
    NSString *arId=[[self.newArrList lastObject] objectForKey:@"articleid"];
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:arId,@"articleid", nil];
    [Utiles getNetInfoWithPath:@"NewesAnalysereportURL" andParams:params besidesBlock:^(id resObj){

        NSMutableArray *exNews=[resObj objectForKey:@"data"];
        NSMutableArray *temp=[NSMutableArray arrayWithArray:self.newArrList];
        for(id obj in exNews){
            [temp addObject:obj];
        }
        self.newArrList=temp;
        [self.customTableView reloadData];
        [self.customTableView.infiniteScrollingView stopAnimating];
        
    }];
    
}

//网络获取数据
- (void)getGooGuuNews{
    
    [Utiles getNetInfoWithPath:@"NewesAnalysereportURL" andParams:nil besidesBlock:^(id news){
       
        self.newArrList=[news objectForKey:@"data"];
       
        [self.customTableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.customTableView];
        
    }];
    
    [Utiles getNetInfoWithPath:@"DailyStock" andParams:nil besidesBlock:^(id obj){
        
        self.imageUrl=[NSString stringWithFormat:@"%@",[obj objectForKey:@"comanylogourl"]];
        NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[obj objectForKey:@"stockcode"],@"stockcode", nil];
        [Utiles getNetInfoWithPath:@"QueryCompany" andParams:params besidesBlock:^(id resObj){
           
            self.companyInfo=resObj;
            [self.customTableView reloadData];
        }];
        [self.customTableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table Data Source Methods

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return 113;
    }else{
        return 86.0;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(section==0){
        return 1;
    }else if(section==1){
        return [self.newArrList count];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int section=indexPath.section;
    
    if(section==0){
        
        static NSString *DailyStockCellIdentifier = @"DailyStockCellIdentifier";
        DailyStockCell *cell = (DailyStockCell*)[tableView dequeueReusableCellWithIdentifier:DailyStockCellIdentifier];//复用cell
        
        if (cell == nil) {
            NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DailyStockCell" owner:self options:nil];//加载自定义cell的xib文件
            cell = [array objectAtIndex:0];
        }
        if(self.imageUrl){
            [cell.dailyStockImg setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.imageUrl]]
                  placeholderImage:[UIImage imageNamed:@"pumpkin.png"]
                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                               cell.dailyStockImg.image=image;
                               
                           }
                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                               
                           }];
        }
        NSNumber *marketPrice=[self.companyInfo objectForKey:@"marketprice"];
        NSNumber *ggPrice=[self.companyInfo objectForKey:@"googuuprice"];
        float outLook=([ggPrice floatValue]-[marketPrice floatValue])/[marketPrice floatValue];
        cell.marketPriceLabel.text=[NSString stringWithFormat:@"%@",marketPrice];
        cell.companyNameLabel.text=[self.companyInfo objectForKey:@"companyname"];
        cell.marketLabel.text=[self.companyInfo objectForKey:@"market"];
        cell.gooGuuPriceLabel.text=[NSString stringWithFormat:@"%@",ggPrice];
        cell.tradeLabel.text=[self.companyInfo objectForKey:@"trade"];
        cell.outLookLabel.text=[NSString stringWithFormat:@"%.2f%%",outLook*100];
        UIView *backView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,86)];
        backView.backgroundColor=[Utiles colorWithHexString:@"#edc951"];
        [cell setBackgroundView:backView];
        [backView release];backView=nil;
      
        return cell;
        
    }else if(section==1){
        static NSString *GooNewsCellIdentifier = @"GooNewsCellIdentifier";
        static BOOL nibsRegistered = NO;
        if (!nibsRegistered) {
            UINib *nib = [UINib nibWithNibName:@"GooNewsCell" bundle:nil];
            [tableView registerNib:nib forCellReuseIdentifier:GooNewsCellIdentifier];
            nibsRegistered = YES;
        }
        
        GooNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:GooNewsCellIdentifier];
        if (cell == nil) {
            cell = [[[GooNewsCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier: GooNewsCellIdentifier] autorelease];
        }
        
        int row=[indexPath row];
        id model=[newArrList objectAtIndex:row];
        
        cell.title=[model objectForKey:@"title"];
        cell.titleLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
        cell.content=[model objectForKey:@"concise"];
        cell.contentLabel.font=[UIFont fontWithName:@"Heiti SC" size:12.0f];
        
        UIView *backView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,86)];
        backView.backgroundColor=[Utiles colorWithHexString:@"#F3EFE1"];
        [cell setBackgroundView:backView];
        [backView release];backView=nil;
        
        [cell setBackgroundColor:[Utiles colorWithHexString:@"#FEF8F8"]];
        
        
        return cell;
    }
    
    return nil;

}




#pragma mark -
#pragma mark Table Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(indexPath.section==0){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else if(indexPath.section==1){
        NSString *artId=[NSString stringWithFormat:@"%@",[[self.newArrList objectAtIndex:indexPath.row] objectForKey:@"articleid"]];
        GooGuuArticleViewController *articleViewController=[[GooGuuArticleViewController alloc] init];
        articleViewController.articleId=artId;
        articleViewController.title=@"研究报告";
        ArticleCommentViewController *articleCommentViewController=[[ArticleCommentViewController alloc] init];
        articleCommentViewController.articleId=artId;
        articleCommentViewController.title=@"评论";
        articleCommentViewController.type=News;
        MHTabBarController *container=[[MHTabBarController alloc] init];
        NSArray *controllers=[NSArray arrayWithObjects:articleViewController,articleCommentViewController, nil];
        container.viewControllers=controllers;
        
        [self.navigationController pushViewController:container animated:YES];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}



#pragma mark -
#pragma mark - Table Header View Methods


- (void)doneLoadingTableViewData{
    
    [self getGooGuuNews];  
    _reloading = NO;
    
}


#pragma mark –
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    
}

#pragma mark –
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [_activityIndicatorView startAnimating];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
  
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    
    return _reloading; // should return if data source model is reloading
    
}
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


-(BOOL)shouldAutorotate{
    return NO;
}














@end

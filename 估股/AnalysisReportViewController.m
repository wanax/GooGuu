//
//  AnalysisReportViewController.m
//  UIDemo
//
//  Created by Xcode on 13-5-8.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 股票详细页-股票分析

#import "AnalysisReportViewController.h"
#import "XYZAppDelegate.h"
#import "UILabel+VerticalAlign.h"
#import "MHTabBarController.h"
#import "CustomTableView.h"
#import "MBProgressHUD.h"
#import "GooNewsCell.h"
#import "AnalyDetailViewController.h"



@interface AnalysisReportViewController ()

@end

#define FINGERCHANGEDISTANCE 100.0

@implementation AnalysisReportViewController

@synthesize analyReportList;
@synthesize customTableView;
@synthesize nibsRegistered;
@synthesize readingMarksDic;

- (void)dealloc
{
    SAFE_RELEASE(readingMarksDic);
    SAFE_RELEASE(customTableView);
    SAFE_RELEASE(analyReportList);
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

-(void)viewDidAppear:(BOOL)animated{
    
    [self.customTableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    nibsRegistered=NO;
    [self.view setBackgroundColor:[Utiles colorWithHexString:@"#EFEBD9"]];
    self.readingMarksDic=[Utiles getConfigureInfoFrom:@"readingmarks" andKey:nil inUserDomain:YES];
    [self getAnalyrePort];
    customTableView=[[UITableView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,370)];
    [self.customTableView setBackgroundColor:[Utiles colorWithHexString:@"#F3EFE1"]];
    customTableView.dataSource=self;
    customTableView.delegate=self;
    
    [self.view addSubview:customTableView];
    
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
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    
    CGPoint change=[tap translationInView:self.view];
    
    if(change.x<-FINGERCHANGEDISTANCE){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:3 animated:YES];
    }else if(change.x>FINGERCHANGEDISTANCE){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
    }
}


#pragma mark -
#pragma mark Net Get JSON Data

//网络获取数据
- (void)getAnalyrePort{
    
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[delegate.comInfo objectForKey:@"stockcode"],@"stockcode", nil];
    [Utiles postNetInfoWithPath:@"CompanyAnalyReportURL" andParams:params besidesBlock:^(id obj){
        if([obj JSONString].length>5){
            self.analyReportList=obj;
            
            [self.customTableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.customTableView];
        }else{
            [Utiles ToastNotification:@"暂无数据" andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}



#pragma mark -
#pragma mark Table Data Source Methods

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 71.0;

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [self.analyReportList count];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *GooNewsCellIdentifier = @"GooNewsCellIdentifier";
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
    id model=[analyReportList objectAtIndex:row];
    
    cell.title=[model objectForKey:@"title"];
    [self setReadingMark:cell andTitle:[model objectForKey:@"title"]];
    cell.content=[model objectForKey:@"brief"];
    cell.timeDiferLabel.text=[Utiles intervalSinceNow:[model objectForKey:@"updatetime"]];
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,71)];
    [bgImgView setImage:[UIImage imageNamed:@"newscellbackground.png"]];
    [cell setBackgroundView:bgImgView];
    SAFE_RELEASE(bgImgView);
 
    return cell;

    
}

#pragma mark -
#pragma mark General Methods

-(void)setReadingMark:(GooNewsCell *)cell andTitle:(NSString *)title{
    
    if(readingMarksDic){
        if ([[readingMarksDic allKeys] containsObject:title]) {
            cell.readMarkImg.image=[UIImage imageNamed:@"readed"];
        }else{
            cell.readMarkImg.image=[UIImage imageNamed:@"unread"];
        }
    }else{
        cell.readMarkImg.image=[UIImage imageNamed:@"unread"];
    }
    
}


#pragma mark -
#pragma mark Table Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *artId=[NSString stringWithFormat:@"%@",[[self.analyReportList objectAtIndex:indexPath.row] objectForKey:@"articleid"]];
    AnalyDetailViewController *detail=[[AnalyDetailViewController alloc] init];
    detail.articleId=artId;
    
    //[self.navigationController pushViewController:container animated:YES];
    [self presentViewController:detail animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [Utiles setConfigureInfoTo:@"readingmarks" forKey:[[self.analyReportList objectAtIndex:indexPath.row] objectForKey:@"title"] andContent:@"1"];
    self.readingMarksDic=[Utiles getConfigureInfoFrom:@"readingmarks" andKey:nil inUserDomain:YES];
    
}



#pragma mark -
#pragma mark - Table Header View Methods


- (void)doneLoadingTableViewData{
    
    [self getAnalyrePort];
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





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(NSUInteger)supportedInterfaceOrientations{
  
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate{
    return NO;
}

















@end

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
#import "Utiles.h"
#import "JSONKit.h"
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

- (void)dealloc
{
    [customTableView release];
    [analyReportList release];
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
    nibsRegistered=NO;
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[Utiles colorWithHexString:@"#EFEBD9"]];
    //[[self.navigationController navigationBar] setHidden:YES];
    [self getAnalyrePort];
    customTableView=[[UITableView alloc] initWithFrame:CGRectMake(0,0,320,370)];
    
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
            [Utiles ToastNotification:@"暂无数据" andView:self.view andLoading:NO andIsBottom:NO andIsHide:NO];
        }
    }];
}



#pragma mark -
#pragma mark Table Data Source Methods

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 86.0;

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
    cell.titleLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
    cell.content=[model objectForKey:@"brief"];
    cell.contentLabel.font=[UIFont fontWithName:@"Heiti SC" size:12.0f];
    
    UIView *backView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,86)];
    backView.backgroundColor=[Utiles colorWithHexString:@"#F3EFE1"];
    [cell setBackgroundView:backView];
    [backView release];backView=nil;
    
    [cell setBackgroundColor:[Utiles colorWithHexString:@"#FEF8F8"]];
    
    
    return cell;

    
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
    [detail release];
    
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

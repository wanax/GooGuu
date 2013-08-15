//
//  ModelViewController.m
//  UIDemo
//
//  Created by Xcode on 13-5-8.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 股票详细页-股票模型

#import "ModelViewController.h"
#import "ChartViewController.h"
#import "UIButton+BGColor.h"
#import "MHTabBarController.h"
#import "FinancalModelChartViewController.h"
#import "DahonValuationViewController.h"
#import "XYZAppDelegate.h"
#import "MBProgressHUD.h"

@interface ModelViewController ()

@end

@implementation ModelViewController

@synthesize browseType;
@synthesize savedStockList;
@synthesize chartViewController;
@synthesize savedTable;

- (void)dealloc
{
    SAFE_RELEASE(savedStockList);
    SAFE_RELEASE(savedTable);
    SAFE_RELEASE(chartViewController);
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
  
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[Utiles colorWithHexString:@"#F3EFE1"]];

    [self addNewButton:@"查看金融模型" Tag:1 frame:CGRectMake(10, 10, 145, 50)];
    [self addNewButton:@"查看大行估值" Tag:3 frame:CGRectMake(165, 10, 145, 50)];
    [self addNewButton:@"调整模型参数" Tag:2 frame:CGRectMake(10, 70, 300, 50)];
    
    if(self.browseType==MySavedType){
        [self initSavedTable];
        [self getSavedStockList];
    }
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];

}

-(void)initSavedTable{
    UILabel *board=[[UILabel alloc] initWithFrame:CGRectMake(0,125,SCREEN_WIDTH,30)];
    [board setBackgroundColor:[Utiles colorWithHexString:@"#F3EFE1"]];
    [board setFont:[UIFont fontWithName:@"Heiti SC" size:13.0]];
    [board setTextColor:[UIColor blackColor]];
    [board setText:@"已保存数据"];
    [board setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:board];
    self.savedTable=[[UITableView alloc] initWithFrame:CGRectMake(0,155,SCREEN_WIDTH,218) style:UITableViewStylePlain];
    [self.savedTable setBackgroundColor:[Utiles colorWithHexString:@"#F3EFE1"]];
    self.savedTable.dataSource=self;
    self.savedTable.delegate=self;
    [self.view addSubview:self.savedTable];
    if(_refreshHeaderView == nil)
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.savedTable.bounds.size.height, self.view.frame.size.width, self.savedTable.bounds.size.height)];
        
        view.delegate = self;
        [self.savedTable addSubview:view];
        _refreshHeaderView = view;
        [view release];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    SAFE_RELEASE(board);
}

-(void)getSavedStockList{
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    id comInfo=delegate.comInfo;
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[comInfo objectForKey:@"stockcode"],@"stockcode",[Utiles getUserToken],@"token",@"googuu",@"from", nil];
    [Utiles getNetInfoWithPath:@"AdjustedData" andParams:params besidesBlock:^(id resObj){
        if(resObj!=nil){
            self.savedStockList=[resObj objectForKey:@"data"];
            [self.savedTable reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}


#pragma mark -
#pragma mark Table Data Source Methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell  forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[Utiles colorWithHexString:[Utiles getConfigureInfoFrom:@"colorconfigure" andKey:@"NormalCellColor" inUserDomain:NO]]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.savedStockList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SavedStockCellIdentifier = @"SavedStockCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             SavedStockCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleValue1
                reuseIdentifier:SavedStockCellIdentifier];
    }
    
    id info=[self.savedStockList objectAtIndex:indexPath.row];
    [cell.textLabel setText:[info objectForKey:@"itemname"]];
    [cell.textLabel setFont:[UIFont fontWithName:@"Heiti SC" size:15.0]];
    
    return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    chartViewController=[[ChartViewController alloc] init];
    chartViewController.sourceType=self.browseType;
    chartViewController.globalDriverId=[[self.savedStockList objectAtIndex:indexPath.row] objectForKey:@"itemcode"];
    chartViewController.view.frame=CGRectMake(0,0,SCREEN_HEIGHT,SCREEN_WIDTH);
    [self presentViewController:chartViewController animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)addNewButton:(NSString *)title Tag:(NSInteger)tag frame:(CGRect)rect{
    UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt1.frame = rect;
    [bt1 setTitle:title forState: UIControlStateNormal];
    [bt1 setBackgroundColorString:@"#C96125" forState:UIControlStateNormal];
    [bt1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bt1.titleLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
    bt1.tag = tag;
    [bt1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt1];
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    CGPoint change=[tap translationInView:self.view];
    if(change.x<-100){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
    }
}

-(void)buttonClicked:(UIButton *)bt{
    
    if(bt.tag==1){
        FinancalModelChartViewController *model=[[FinancalModelChartViewController alloc] init];
        [self presentViewController:model animated:YES completion:nil];
        SAFE_RELEASE(model);
    }else if(bt.tag==2){
        chartViewController=[[ChartViewController alloc] init];
        chartViewController.sourceType=self.browseType;
        chartViewController.view.frame=CGRectMake(0,0,SCREEN_HEIGHT,SCREEN_WIDTH);
        [self presentViewController:chartViewController animated:YES completion:nil];
    }else if(bt.tag==3){
        DahonValuationViewController *dahon=[[DahonValuationViewController alloc] init];
        [self presentViewController:dahon animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

    [self.chartViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(NSUInteger)supportedInterfaceOrientations{

    if([self isKindOfClass:NSClassFromString(@"ModelViewController")])
        return UIInterfaceOrientationMaskPortrait;

    return [self.chartViewController supportedInterfaceOrientations];
}

#pragma mark -
#pragma mark - Table Header View Methods


- (void)doneLoadingTableViewData{
    [self getSavedStockList];
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.savedTable];
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

- (BOOL)shouldAutorotate{

    return [self.chartViewController shouldAutorotate];
}

























@end

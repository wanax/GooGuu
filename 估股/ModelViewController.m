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
#import "DiscountRateViewController.h"

@interface ModelViewController ()

@end

@implementation ModelViewController

@synthesize comInfo;
@synthesize jsonForChart;
@synthesize browseType;
@synthesize savedStockList;
@synthesize chartViewController;
@synthesize disViewController;
@synthesize savedTable;

- (void)dealloc
{
    SAFE_RELEASE(disViewController);
    SAFE_RELEASE(comInfo);
    SAFE_RELEASE(jsonForChart);
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

-(void)viewDidAppear:(BOOL)animated{
    if(browseType==MySavedType){
        [self.savedTable reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    comInfo=delegate.comInfo;
    
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[Utiles colorWithHexString:@"#F3EFE1"]];

    UIImageView *backGround1=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"valuationModelBack"]];
    backGround1.frame=CGRectMake(0,0, SCREEN_WIDTH,60);
    [self.view addSubview:backGround1];
    UIImageView *backGround2=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"valuationModelBack"]];
    backGround2.frame=CGRectMake(0,60, SCREEN_WIDTH,60);
    [self.view addSubview:backGround2];
    
    [self addNewButton:@"查看财务数据" Tag:1 frame:CGRectMake(163, 15, 150, 26)];
    [self addNewButton:@"查看大行估值" Tag:3 frame:CGRectMake(8, 15, 150, 26)];
    [self addNewButton:@"调整模型参数" Tag:2 frame:CGRectMake(84, 78, 150, 26)];
    
    [self addActionButtonTag:AddAttention frame:CGRectMake(0, 345, 106, 45) img:@"modelConcernBt"];
    [self addActionButtonTag:AddComment frame:CGRectMake(106, 345, 106, 45) img:@"modelComment"];
    [self addActionButtonTag:AddShare frame:CGRectMake(212, 345, 108, 45) img:@"modelShareBt"];
    
    if(self.browseType==MySavedType){
        [self initSavedTable];
        [self getChartJsonData];
        [self getSavedStockList];
    }
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
    SAFE_RELEASE(backGround1);
    SAFE_RELEASE(backGround2);

}
-(void)addActionButtonTag:(NSInteger)tag frame:(CGRect)rect img:(NSString *)img{
    UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt1.frame = rect;
    [bt1 setBackgroundImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
    bt1.tag = tag;
    [bt1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt1];
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
    _count=0;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    SAFE_RELEASE(board);
}

-(void)getSavedStockList{
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[comInfo objectForKey:@"stockcode"],@"stockcode",[Utiles getUserToken],@"token",@"googuu",@"from", nil];
    [Utiles getNetInfoWithPath:@"AdjustedData" andParams:params besidesBlock:^(id resObj){
        if(resObj!=nil){
            self.savedStockList=[resObj objectForKey:@"data"];
            [self.savedTable reloadData];
            if(_count==1){
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                _count=0;
            }else{
                _count++;
            }
            
        }
    }];
}

-(void)getChartJsonData{
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[comInfo objectForKey:@"stockcode"],@"stockCode", nil];
    [Utiles getNetInfoWithPath:@"CompanyModel" andParams:params besidesBlock:^(id resObj){
        self.jsonForChart=[resObj JSONString];
        self.jsonForChart=[self.jsonForChart stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\\\\\""];
        self.jsonForChart=[self.jsonForChart stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        disViewController=[[DiscountRateViewController alloc] init];
        disViewController.jsonData=self.jsonForChart;
        disViewController.view.frame=CGRectMake(0,0,SCREEN_HEIGHT,SCREEN_WIDTH);
        if(_count==1){
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            _count=0;
        }else{
            _count++;
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
    if([[[self.savedStockList objectAtIndex:indexPath.row] objectForKey:@"data"] count]==1){
        
        [self presentViewController:disViewController animated:YES completion:nil];
    }else{
        chartViewController=[[ChartViewController alloc] init];
        chartViewController.sourceType=self.browseType;
        chartViewController.globalDriverId=[[self.savedStockList objectAtIndex:indexPath.row] objectForKey:@"itemcode"];
        chartViewController.view.frame=CGRectMake(0,0,SCREEN_HEIGHT,SCREEN_WIDTH);
        [self presentViewController:chartViewController animated:YES completion:nil];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)addNewButton:(NSString *)title Tag:(NSInteger)tag frame:(CGRect)rect{
    UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt1.frame = rect;
    [bt1 setTitle:title forState: UIControlStateNormal];
    [bt1 setBackgroundColorString:@"#C96125" forState:UIControlStateNormal];
    [bt1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bt1 setBackgroundImage:[UIImage imageNamed:@"valueModelBt"] forState:UIControlStateNormal];
    bt1.titleLabel.font=[UIFont fontWithName:@"Heiti SC" size:14.0f];
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
    }else if(bt.tag==AddAttention){
        
        NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[Utiles getUserToken],@"token",@"googuu",@"from",[comInfo objectForKey:@"stockcode"],@"stockcode", nil];
        
        [Utiles postNetInfoWithPath:@"AddAttention" andParams:params besidesBlock:^(id resObj){
            
            if([[resObj objectForKey:@"status"] isEqualToString:@"1"]){
                [Utiles ToastNotification:[resObj objectForKey:@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
            }else{
                [Utiles ToastNotification:[resObj objectForKey:@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
            }
            
        }];
        
    }else if(bt.tag==AddComment){
        
    }else if(bt.tag==AddShare){
        
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

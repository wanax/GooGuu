//
//  CompanyListViewController.h
//  welcom_demo_1
//
//  股票添加列表
//
//  Created by Xcode on 13-5-9.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-09 | Wanax | 股票添加列表

#import "CompanyListViewController.h"
#import "DBLite.h"
#import "math.h"
#import "XYZAppDelegate.h"
#import "MHTabBarController.h"
#import "ComFieldViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomTableView.h"
#import "StockCell.h"
#import "Utiles.h"
#import "UIButton+BGColor.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSONKit.h"
#import "MBProgressHUD.h"

@interface CompanyListViewController ()

@end

#define FINGERCHANGEDISTANCE 100.0

@implementation CompanyListViewController

@synthesize comList;
@synthesize comType;
@synthesize rowImage;
@synthesize table;
@synthesize search;
@synthesize isShowSearchBar=_isShowSearchBar;
@synthesize concernStocksCodeArr;
@synthesize type;
@synthesize nibsRegistered;

- (void)dealloc {
    [concernStocksCodeArr release];
    [comType release];
    [comList release];
    [rowImage release];
    [table release];
    [search release];
    [super dealloc];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self getConcernStocksCode];
    [self.table reloadData];
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    nibsRegistered = NO;

    [self getCompanyList];

    if(self.isShowSearchBar){
        table=[[UITableView alloc] initWithFrame:CGRectMake(0,40,320,330)];
        search=[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,40)];
        search.delegate=self;
        [self.view addSubview:search];
    }else{
        table=[[UITableView alloc] initWithFrame:CGRectMake(0,0,320,290)];
    }
   
    table.dataSource=self;
    table.delegate=self;
    
    [self.view addSubview:table];
    [self getConcernStocksCode];
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
    
    if(_refreshHeaderView == nil)
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.table.bounds.size.height, self.view.frame.size.width, self.table.bounds.size.height)];
        
        view.delegate = self;
        [self.table addSubview:view];
        _refreshHeaderView = view;
        [view release];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

#pragma mark -
#pragma mark Init Methods

-(void)getCompanyList{
 
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:type],@"market", nil];
    [Utiles getNetInfoWithPath:@"QueryAllCompany" andParams:params besidesBlock:^(id resObj){
        
        self.comList=resObj;
        [self.table reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
}
     
-(void)getConcernStocksCode{

    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"],@"token",@"googuu",@"from", nil];
    [Utiles postNetInfoWithPath:@"AttentionData" andParams:params besidesBlock:^(id resObj){
        if(![[resObj objectForKey:@"status"] isEqualToString:@"0"]){
            self.concernStocksCodeArr=[[NSMutableArray alloc] init];
            NSArray *temp=[resObj objectForKey:@"data"];
            for(id obj in temp){
                [concernStocksCodeArr addObject:[NSString stringWithFormat:@"%@",[obj objectForKey:@"stockcode"]]];
            }
            [self.table reloadData];
        }else{
            [Utiles ToastNotification:[resObj objectForKey:@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
            self.concernStocksCodeArr=[[NSMutableArray alloc] init];
        }        
    }];
    
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    
    CGPoint change=[tap translationInView:self.view];
    if(fabs(change.x)>FINGERCHANGEDISTANCE-1){
        if([self.comType isEqualToString:@"港交所"]){
            if(change.x<-FINGERCHANGEDISTANCE){
                [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
            }
        }else if([self.comType isEqualToString:@"美股"]){
            if(change.x<-FINGERCHANGEDISTANCE){
                [(MHTabBarController *)self.parentViewController setSelectedIndex:2 animated:YES];
            }else if(change.x>FINGERCHANGEDISTANCE){
                [(MHTabBarController *)self.parentViewController setSelectedIndex:0 animated:YES];
            }
        }else if([self.comType isEqualToString:@"沪深"]){
            if(change.x>FINGERCHANGEDISTANCE){
                [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
            }
        }
    }
  
}

#pragma mark -
#pragma mark Table Data Source Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.comList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * StockCellIdentifier =
    @"StockCellIdentifier";
    
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"StockCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:StockCellIdentifier];
        nibsRegistered = YES;
    }
    
    StockCell *cell = [tableView dequeueReusableCellWithIdentifier:StockCellIdentifier];
    if (cell == nil) {
        cell = [[[StockCell alloc] initWithStyle:UITableViewCellStyleValue1
                                  reuseIdentifier: StockCellIdentifier] autorelease];
    }
    

    NSUInteger row;
    row = [indexPath row];
    @try{
        NSDictionary *comInfo=[comList objectAtIndex:row];
        cell.stockNameLabel.text=[comInfo objectForKey:@"companyname"];
        cell.stockNameLabel.font=[UIFont fontWithName:@"Heiti SC" size:15.0f];
        cell.concernBt.titleLabel.font=[UIFont fontWithName:@"Heiti SC" size:11.0f];
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"]){
            if([self.concernStocksCodeArr containsObject:[NSString stringWithFormat:@"%@",[comInfo objectForKey:@"stockcode"]]]){
                [cell.concernBt setTitle:@"取消关注" forState:UIControlStateNormal];
                [cell.concernBt setBackgroundColorString:@"#34C3C1" forState:UIControlStateNormal];
                [cell.concernBt setTag:row+1];
            }else{
                [cell.concernBt setTitle:@"添加关注" forState:UIControlStateNormal];
                [cell.concernBt setBackgroundColorString:@"#F21E83" forState:UIControlStateNormal];
                [cell.concernBt setTag:row+1];
            }
            
            [cell.concernBt addTarget:self action:@selector(cellBtClick:) forControlEvents:UIControlEventTouchDown];
            [cell.concernBt setHidden:NO];
        }else{
            [cell.concernBt setHidden:YES];
        }
        UIView *backView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,86)];
        backView.backgroundColor=[Utiles colorWithHexString:@"#EFEBD9"];
        [cell setBackgroundView:backView];
  
    }@catch (NSException *e) {
        NSLog(@"%@",e);
    }
    
    return cell;
    
}

-(void)cellBtClick:(id)sender{
    
    UIButton *cellBt=(UIButton *)sender;
    NSString *title=[cellBt currentTitle];
    NSString *stockCode=[[self.comList objectAtIndex:cellBt.tag-1] objectForKey:@"stockcode"];
    if([title isEqualToString:@"取消关注"]){

        [cellBt setTitle:@"添加关注" forState:UIControlStateNormal];
        [cellBt setBackgroundColorString:@"#F21E83" forState:UIControlStateNormal];
        
        [self NetAction:@"DeleteAttention" andCode:stockCode];
 
    }else if([title isEqualToString:@"添加关注"]){

        [cellBt setTitle:@"取消关注" forState:UIControlStateNormal];
        [cellBt setBackgroundColorString:@"#34C3C1" forState:UIControlStateNormal];
        
        [self NetAction:@"AddAttention" andCode:stockCode];
      
    }
    
}

-(Boolean)NetAction:(NSString *)url andCode:(NSString *)stockCode{
    __block Boolean tag;

    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"],@"token",@"googuu",@"from",stockCode,@"stockcode", nil];
    
    [Utiles postNetInfoWithPath:url andParams:params besidesBlock:^(id resObj){

        if(![[resObj objectForKey:@"status"] isEqualToString:@"1"]){
            [Utiles ToastNotification:[resObj objectForKey:@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
        }
        if([url isEqualToString:@"AddAttention"]){
            [self.concernStocksCodeArr addObject:stockCode];
        }else if([url isEqualToString:@"DeleteAttention"]){
            [self.concernStocksCodeArr removeObject:stockCode];
        }
        tag=YES;
        [self.table reloadData];
        
    }];

    return tag;
}


#pragma mark -
#pragma mark Table Delegate Methods

-(void)viewDidDisappear:(BOOL)animated{
    [search resignFirstResponder];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    int row=indexPath.row;
    delegate.comInfo=[self.comList objectAtIndex:row];
    
    ComFieldViewController *com=[[ComFieldViewController alloc] init];
    com.view.frame=CGRectMake(0,20,320,480);
    [delegate.window addSubview:com.view];
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFilterLinear;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [[com.view layer] addAnimation:animation forKey:@"animation"];
    animation=nil;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [search resignFirstResponder];
}



#pragma mark -
#pragma mark Search Delegate Methods

//搜索实现
-(void)resetSearch
{//重置搜索
    DBLite *tool=[[DBLite alloc] init];
    [tool openSQLiteDB];
    
    //获取同类股票列表
    self.comList=[tool getCompanyInfo:self.comType];
    
    [tool closeDB];
    [tool release];
    
}
-(void)handleSearchForTerm:(NSString *)searchTerm
{
    [super viewDidLoad];
    
    DBLite *tool=[[DBLite alloc] init];
    [tool openSQLiteDB];
    
    //获取同类股票列表
    self.comList=[tool searchStocks:searchTerm from:self.comType];
    
    [tool closeDB];
    [table reloadData];
    [tool release];
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{//TableView的项被选择前触发
    [search resignFirstResponder];
    //搜索条释放焦点，隐藏软键盘
    return indexPath;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{//按软键盘右下角的搜索按钮时触发
    NSString *searchTerm=[searchBar text];
    //读取被输入的关键字
    [self handleSearchForTerm:searchTerm];
    //根据关键字，进行处理
    [search resignFirstResponder];
    //隐藏软键盘
    
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{//搜索条输入文字修改时触发
    if([searchText length]==0)
    {//如果无文字输入
        [self resetSearch];
        [table reloadData];
        return;
    }
    
    [self handleSearchForTerm:searchText];
    //有文字输入就把关键字传给handleSearchForTerm处理
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{//取消按钮被按下时触发
    [self resetSearch];
    //重置
    searchBar.text=@"";
    //输入框清空
    [table reloadData];
    [search resignFirstResponder];
    //重新载入数据，隐藏软键盘
    
}

#pragma mark -
#pragma mark - Table Header View Methods


- (void)doneLoadingTableViewData{
    [self getCompanyList];
    [self getConcernStocksCode];
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.table];
    _reloading = NO;
    
}


#pragma mark –
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    [search resignFirstResponder];
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





@end

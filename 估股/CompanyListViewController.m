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
#import "CustomTableView.h"
#import "StockCell.h"
#import "UIButton+BGColor.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "SVPullToRefresh.h"
#import "IndicatorComView.h"
#import "StockSearchListViewController.h"


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
@synthesize com;
@synthesize type;
@synthesize nibsRegistered;
@synthesize isSearchList;

- (void)dealloc {
    SAFE_RELEASE(com);
    SAFE_RELEASE(concernStocksCodeArr);
    SAFE_RELEASE(comType);
    SAFE_RELEASE(comList);
    SAFE_RELEASE(rowImage);
    SAFE_RELEASE(table);
    SAFE_RELEASE(search);
    [super dealloc];
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self getConcernStocksCode];
    [self.table reloadData];
    if(isSearchList){
        [self.search becomeFirstResponder];
    }
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    nibsRegistered = NO;
    if(isSearchList){
        self.title=@"股票搜索";
    }else{
        self.title=@"估值模型";
    }
    
    [self getCompanyList];
   
    table=[[UITableView alloc] initWithFrame:CGRectMake(0,62,SCREEN_WIDTH,320)];
    search=[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,35)];
    [[self.search.subviews objectAtIndex:0] removeFromSuperview];
    self.search.backgroundColor = [UIColor grayColor];
    search.delegate=self;
    
    IndicatorComView *indicator=[[IndicatorComView alloc] init];
    indicator.center=CGPointMake(SCREEN_WIDTH/2,50);
    [self.view insertSubview:indicator aboveSubview:self.table];
    [indicator release];
    [self.view addSubview:search];
    [table setBackgroundColor:[Utiles colorWithHexString:[Utiles getConfigureInfoFrom:@"colorconfigure" andKey:@"NormalCellColor" inUserDomain:NO]]];
    table.dataSource=self;
    table.delegate=self;
    
    [self.view addSubview:table];
    [self getConcernStocksCode];
    
    if(!self.isSearchList){
        [self.table addInfiniteScrollingWithActionHandler:^{
            [self addCompany];
        }];
    }
    
    
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
#pragma mark Net Get JSON Data

-(void)addCompany{

    NSString *updateTime=[[self.comList lastObject] objectForKey:@"updatetime"];   
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:type],@"market",updateTime,@"updatetime", nil];
    
    [Utiles getNetInfoWithPath:@"QueryAllCompany" andParams:params besidesBlock:^(id resObj){
        
        NSMutableArray *temp=[NSMutableArray arrayWithArray:self.comList];
        for(id obj in resObj){
            [temp addObject:obj];
        }
        self.comList=temp;
        [self.table reloadData];
        [self.table.infiniteScrollingView stopAnimating];
    }];
    
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

    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[Utiles getUserToken],@"token",@"googuu",@"from", nil];
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
        }else if([self.comType isEqualToString:@"深市"]){
            if(change.x<-FINGERCHANGEDISTANCE){
                [(MHTabBarController *)self.parentViewController setSelectedIndex:3 animated:YES];
            }else if(change.x>FINGERCHANGEDISTANCE){
                [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
            }
        }else if([self.comType isEqualToString:@"沪市"]){
            if(change.x>FINGERCHANGEDISTANCE){
                [(MHTabBarController *)self.parentViewController setSelectedIndex:2 animated:YES];
            }
        }
    }
  
}

#pragma mark -
#pragma mark Table Data Source Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.comList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell  forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[Utiles colorWithHexString:[Utiles getConfigureInfoFrom:@"colorconfigure" andKey:@"NormalCellColor" inUserDomain:NO]]];
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
        cell.stockNameLabel.text=[comInfo objectForKey:@"companyname"]==nil?@"":[comInfo objectForKey:@"companyname"];

        if([Utiles isLogin]){
            if([self.concernStocksCodeArr containsObject:[NSString stringWithFormat:@"%@",[comInfo objectForKey:@"stockcode"]]]){
                [cell.concernBt setTitle:@"取消关注" forState:UIControlStateNormal];
                [cell.concernBt setBackgroundImage:[UIImage imageNamed:@"cancelConcernBt"] forState:UIControlStateNormal];
                [cell.concernBt setTag:row+1];
            }else{
                [cell.concernBt setTitle:@"添加关注" forState:UIControlStateNormal];
                //[cell.concernBt setBackgroundColorString:@"#F21E83" forState:UIControlStateNormal];
                [cell.concernBt setBackgroundImage:[UIImage imageNamed:@"addConcernBt"] forState:UIControlStateNormal];
                [cell.concernBt setTag:row+1];
            }
            
            [cell.concernBt addTarget:self action:@selector(cellBtClick:) forControlEvents:UIControlEventTouchDown];
            [cell.concernBt setHidden:NO];
        }else{
            [cell.concernBt setHidden:YES];
        }
        NSNumber *gPriceStr=[comInfo objectForKey:@"googuuprice"];
        float g=[gPriceStr floatValue];
        cell.gPriceLabel.text=[NSString stringWithFormat:@"%.2f",g];
        NSNumber *priceStr=[comInfo objectForKey:@"marketprice"];
        float p = [priceStr floatValue];
        cell.priceLabel.text=[NSString stringWithFormat:@"%.2f",p];
        cell.belongLabel.text=[NSString stringWithFormat:@"%@.%@",[comInfo objectForKey:@"stockcode"],[comInfo objectForKey:@"marketname"]];
        float outLook=(g-p)/p;
        cell.percentLabel.text=[NSString stringWithFormat:@"%.2f%%",outLook*100];
        
        
        NSString *riseColorStr=[NSString stringWithFormat:@"RiseColor%@",[Utiles getConfigureInfoFrom:@"userconfigure" andKey:@"stockColorSetting" inUserDomain:YES]];
        NSString *fallColorStr=[NSString stringWithFormat:@"FallColor%@",[Utiles getConfigureInfoFrom:@"userconfigure" andKey:@"stockColorSetting" inUserDomain:YES]];
        NSString *riseColor=[Utiles getConfigureInfoFrom:@"colorconfigure" andKey:riseColorStr inUserDomain:NO];
        NSString *fallColor=[Utiles getConfigureInfoFrom:@"colorconfigure" andKey:fallColorStr inUserDomain:NO];

        if(outLook>0){
            cell.percentLabel.backgroundColor=[Utiles colorWithHexString:riseColor];
        }else if(outLook==0){
            cell.percentLabel.backgroundColor=[UIColor whiteColor];
        }else if(outLook<0){
            cell.percentLabel.backgroundColor=[Utiles colorWithHexString:fallColor];
        }
  
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
     
        [self NetAction:@"DeleteAttention" andCode:stockCode withBt:cellBt];
 
    }else if([title isEqualToString:@"添加关注"]){

        [self NetAction:@"AddAttention" andCode:stockCode withBt:cellBt];
      
    }
    
}

-(Boolean)NetAction:(NSString *)url andCode:(NSString *)stockCode withBt:(UIButton *)cellBt{
    __block Boolean tag;

    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[Utiles getUserToken],@"token",@"googuu",@"from",stockCode,@"stockcode", nil];
    
    [Utiles postNetInfoWithPath:url andParams:params besidesBlock:^(id resObj){

        if(![[resObj objectForKey:@"status"] isEqualToString:@"1"]){
            [Utiles ToastNotification:[resObj objectForKey:@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
        }else if([[resObj objectForKey:@"status"] isEqualToString:@"1"]){
            if([url isEqualToString:@"AddAttention"]){
                [self.concernStocksCodeArr addObject:stockCode];
                [cellBt setTitle:@"取消关注" forState:UIControlStateNormal];
                [cellBt setBackgroundColorString:@"#34C3C1" forState:UIControlStateNormal];
            }else if([url isEqualToString:@"DeleteAttention"]){
                [self.concernStocksCodeArr removeObject:stockCode];
                [cellBt setTitle:@"添加关注" forState:UIControlStateNormal];
                [cellBt setBackgroundColorString:@"#F21E83" forState:UIControlStateNormal];
            }
            tag=YES;
            [self.table reloadData];
        }
        
    }];

    return tag;
}


#pragma mark -
#pragma mark Table Delegate Methods

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [search resignFirstResponder];
    return indexPath;
}

-(void)viewDidDisappear:(BOOL)animated{
    [search resignFirstResponder];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    int row=indexPath.row;
    delegate.comInfo=[self.comList objectAtIndex:row];
    
    com=[[ComFieldViewController alloc] init];
    com.browseType=ValuationModelType;
    com.view.frame=CGRectMake(0,20,SCREEN_WIDTH,SCREEN_HEIGHT);
    [self presentViewController:com animated:YES completion:nil];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [search resignFirstResponder];
}



#pragma mark -
#pragma mark Search Delegate Methods

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if(!isSearchList){
        CompanyListViewController *searchList=[[CompanyListViewController alloc] init];
        searchList.isSearchList=YES;
        searchList.type=ALL;
        [self.navigationController pushViewController:searchList animated:YES];
        SAFE_RELEASE(searchList);
        [search resignFirstResponder];
    }
  
}
//搜索实现
-(void)resetSearch
{  
    [self handleSearchForTerm:@""];
    
}
-(void)handleSearchForTerm:(NSString *)searchTerm
{
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:searchTerm,@"q", nil];
    [Utiles postNetInfoWithPath:@"Query" andParams:params besidesBlock:^(id resObj){
        
        self.comList=resObj;
        [self.table reloadData];
        
    }];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchTerm=[searchBar text];
    [self handleSearchForTerm:searchTerm];
    [search resignFirstResponder];
    
}
/*-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText length]==0)
    {
        [self resetSearch];
        [table reloadData];
        return;
    }else{
        [self handleSearchForTerm:searchText];
    }
    
    //有文字输入就把关键字传给handleSearchForTerm处理
}*/
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
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
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}






@end

//
//  MyGooguuViewController.m
//  UIDemo
//
//  Created by Xcode on 13-6-13.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "ConcernedViewController.h"
#import "ClientLoginViewController.h"
#import "CustomTableView.h"
#import "CustomCell.h"
#import "AddCell.h"
#import "UserCell.h"
#import "XYZAppDelegate.h"
#import "MHTabBarController.h"
#import "ComFieldViewController.h"
#import "PrettyTabBarViewController.h"
#import "PrettyNavigationController.h"
#import "MBProgressHUD.h"
#import "IndicatorView.h"
#import "Indicator2View.h"


@interface ConcernedViewController ()


@end

@implementation ConcernedViewController

@synthesize companyFieldViewController;
@synthesize comFieldViewController;
@synthesize loginViewController;
@synthesize customTableView;
@synthesize type;
@synthesize browseType;
@synthesize nibsRegistered;
@synthesize nibsRegistered2;
@synthesize isEditing;

@synthesize comInfoList;


- (void)dealloc
{
    SAFE_RELEASE(comFieldViewController);
    SAFE_RELEASE(type);
    SAFE_RELEASE(companyFieldViewController);
    SAFE_RELEASE(customTableView);
    SAFE_RELEASE(comInfoList);
    SAFE_RELEASE(loginViewController);
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
    
    [self getComList];

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _showToast=NO;
    nibsRegistered=NO;
    nibsRegistered2=NO;
    self.comInfoList=[[NSMutableArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"",@"googuuprice",@"",@"marketprice",@"",@"market",@"",@"companyname", nil],nil];
    if(browseType==MyConcernedType){
        IndicatorView *indicator=[[IndicatorView alloc] init];
        [self.view addSubview:indicator];
        [indicator release];
    }else if(browseType==MySavedType){
        Indicator2View *indicator=[[Indicator2View alloc] init];
        [self.view addSubview:indicator];
        [indicator release];
    }
    
   	customTableView=[[UITableView alloc] initWithFrame:CGRectMake(0,30,SCREEN_WIDTH,312)];
    [customTableView setBackgroundColor:[Utiles colorWithHexString:[Utiles getConfigureInfoFrom:@"colorconfigure" andKey:@"NormalCellColor" inUserDomain:NO]]];
    customTableView.dataSource=self;
    customTableView.delegate=self;

    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
    
    [self.view addSubview:customTableView];
    [self getComList];
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
    
    /*UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];
    SAFE_RELEASE(tap);*/
}

-(void)tapAction:(UITapGestureRecognizer *)tap{
    if(isEditing){
        [customTableView setEditing:NO animated:YES];
        isEditing=NO;
    }
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    CGPoint change=[tap translationInView:self.view];
    if([self.type isEqualToString:@"AttentionData"]){
        if(change.x<-100){
            [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
        }else if(change.x>100){
            [(MHTabBarController *)self.parentViewController setSelectedIndex:0 animated:YES];
        }
    }else if([self.type isEqualToString:@"SavedData"]){
        if(change.x<-100){
            [(MHTabBarController *)self.parentViewController setSelectedIndex:2 animated:YES];
        }else if(change.x>100){
            [(MHTabBarController *)self.parentViewController setSelectedIndex:0 animated:YES];
        }
    }
    
}

-(void)getComList{
   
    NSDictionary *params = @{@"token": [Utiles getUserToken],@"from": @"googuu"};
    [Utiles postNetInfoWithPath:self.type andParams:params besidesBlock:^(id obj){
        if(![obj[@"status"] isEqualToString:@"0"]){
            @try {
                self.comInfoList=[NSMutableArray arrayWithArray:obj[@"data"]];
                [customTableView reloadData];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
            }
        
        }else{
            [Utiles ToastNotification:obj[@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
            self.comInfoList=[NSMutableArray arrayWithCapacity:0];
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

   return [self.comInfoList count];

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell  forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setBackgroundColor:[Utiles colorWithHexString:[Utiles getConfigureInfoFrom:@"colorconfigure" andKey:@"NormalCellColor" inUserDomain:NO]]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    //股票栏目
    static NSString *CustomCellIdentifier = @"CustomCellIdentifier";
    
    if (!nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:CustomCellIdentifier];
        nibsRegistered = YES;
    }
    
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if (cell == nil) {
        cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleValue1
                                  reuseIdentifier: CustomCellIdentifier] autorelease];
    }
    
    @try {
        NSUInteger row = [indexPath row];
        id comInfo=(self.comInfoList)[row];
        cell.name=comInfo[@"companyname"];
   
        NSNumber *gPriceStr=comInfo[@"googuuprice"];
        float g=[gPriceStr floatValue];
        cell.gPrice=[NSString stringWithFormat:@"%.2f",g];
        NSNumber *priceStr=comInfo[@"marketprice"];
        float p = [priceStr floatValue];
        cell.price=[NSString stringWithFormat:@"%.2f",p];
        cell.belong=[NSString stringWithFormat:@"%@.%@",comInfo[@"stockcode"],comInfo[@"marketname"]];
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
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
    
    
    UILongPressGestureRecognizer *longP=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:andCellIndex:)];
    [cell addGestureRecognizer:longP];
   
    SAFE_RELEASE(longP);
    return cell;
    
}


-(void)longAction:(UILongPressGestureRecognizer *)press andCellIndex:(NSIndexPath *)indexPath{

    [customTableView setEditing:YES animated:YES];
    isEditing=YES;

    UIBarButtonItem *cancelEdit=[[UIBarButtonItem alloc] initWithTitle:@"取消删除" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelAction)];
    [self.parentViewController.parentViewController.parentViewController.navigationItem setRightBarButtonItem:cancelEdit animated:NO];
    SAFE_RELEASE(cancelEdit);

    
}
-(void)cancelAction{
    [customTableView setEditing:NO animated:YES];
    [self.parentViewController.parentViewController.parentViewController.navigationItem setRightBarButtonItem:nil animated:NO];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        if (editingStyle==UITableViewCellEditingStyleDelete) {
            NSInteger row = [indexPath row];
            NSString *stockCode=[(self.comInfoList)[row][@"stockcode"] copy];
            [self.comInfoList removeObjectAtIndex:row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            NSDictionary *params=@{@"token": [Utiles getUserToken],@"from": @"googuu",@"stockcode": stockCode};
            NSString *netAction=nil;
            if(self.browseType==MyConcernedType){
                netAction=@"DeleteAttention";
            }else if(self.browseType==MySavedType){
                netAction=@"DeleteModelData";
            }
            [Utiles postNetInfoWithPath:netAction andParams:params besidesBlock:^(id resObj){
                if(![resObj[@"status"] isEqualToString:@"1"]){
                    [Utiles ToastNotification:resObj[@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
                }
            }];
            [stockCode release];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
}
//单元格返回的编辑风格，包括删除 添加 和 默认  和不可编辑三种风格
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 40.0;

}
#pragma mark Table Delegate Methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{


    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    int row=indexPath.row;
    @try {
        delegate.comInfo=[(self.comInfoList)[row] retain];
        
        comFieldViewController=[[ComFieldViewController alloc] init];
        comFieldViewController.browseType=self.browseType;
        comFieldViewController.view.frame=CGRectMake(0,20,SCREEN_WIDTH,SCREEN_HEIGHT);
        [self presentViewController:comFieldViewController animated:YES completion:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }

 
}


#pragma mark -
#pragma mark - Table Header View Methods


- (void)doneLoadingTableViewData{
    
    [self getComList];
   _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.customTableView];
    
}


#pragma mark –
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    //[customTableView setEditing:NO animated:YES];
    _showToast=NO;
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
    
    //NSLog(@"concern supportedInterfaceOrientations");
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate{

    return NO;
}




@end

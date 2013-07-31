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
#import "Utiles.h"
#import "ComFieldViewController.h"
#import "PrettyTabBarViewController.h"
#import "PrettyNavigationController.h"
#import "MBProgressHUD.h"

@interface ConcernedViewController ()


@end

@implementation ConcernedViewController

@synthesize companyFieldViewController;

@synthesize loginViewController;
@synthesize customTableView;
@synthesize type;
@synthesize nibsRegistered;

@synthesize comInfoList;


- (void)dealloc
{
    [type release];
    [companyFieldViewController release];

    [customTableView release];
    [comInfoList release];
    
    [loginViewController release];
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
    self.title=@"小马财经";
    nibsRegistered=NO;
    
    self.comInfoList=[[NSMutableArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"",@"googuuprice",@"",@"marketprice",@"",@"market",@"",@"companyname", nil],nil];
    
   	customTableView=[[UITableView alloc] initWithFrame:CGRectMake(0,0,320,330)];
    
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
   
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"], @"token",@"googuu",@"from",
                            nil];
    [Utiles postNetInfoWithPath:self.type andParams:params besidesBlock:^(id obj){
        if(![[obj objectForKey:@"status"] isEqualToString:@"0"]){
            self.comInfoList=[NSMutableArray arrayWithArray:[obj objectForKey:@"data"]];
            [customTableView reloadData];
        }else{
            [Utiles ToastNotification:[obj objectForKey:@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
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
        id com=[self.comInfoList objectAtIndex:row];
        cell.name=[com objectForKey:@"companyname"];
        //cell.topImg=[UIImage imageNamed:@"web.png"];
        //cell.bottomImg=[UIImage imageNamed:@"up.png"];
       
        NSNumber *gPriceStr=[com objectForKey:@"googuuprice"];
        float g=[gPriceStr floatValue];
        cell.gPrice=[NSString stringWithFormat:@"%.2f",g];
        NSNumber *priceStr=[com objectForKey:@"marketprice"];
        float p = [priceStr floatValue];
        cell.price=[NSString stringWithFormat:@"%.2f",p];
        cell.belong=[NSString stringWithFormat:@"%@.%@",[com objectForKey:@"stockcode"],[com objectForKey:@"marketname"]];
        float outLook=(g-p)/p;
        cell.percentLabel.text=[NSString stringWithFormat:@"%.2f%%",outLook*100];
        NSString *riseColorStr=[NSString stringWithFormat:@"RiseColor%@",[Utiles getConfigureInfoFrom:@"userconfigure" andKey:@"stockColorSetting" inUserDomain:YES]];
        NSString *fallColorStr=[NSString stringWithFormat:@"FallColor%@",[Utiles getConfigureInfoFrom:@"userconfigure" andKey:@"stockColorSetting" inUserDomain:YES]];
        NSString *riseColor=[Utiles getConfigureInfoFrom:@"colorconfigure" andKey:riseColorStr inUserDomain:NO];
        NSString *fallColor=[Utiles getConfigureInfoFrom:@"colorconfigure" andKey:fallColorStr inUserDomain:NO];
        if(outLook>0){
            cell.percentLabel.backgroundColor=[Utiles colorWithHexString:riseColor];
            cell.percentLabel.layer.borderColor = [Utiles colorWithHexString:riseColor].CGColor;
        }else if(outLook==0){
            cell.percentLabel.backgroundColor=[UIColor whiteColor];
        }else if(outLook<0){
            cell.percentLabel.backgroundColor=[Utiles colorWithHexString:fallColor];
            cell.percentLabel.layer.borderColor = [Utiles colorWithHexString:fallColor].CGColor;
        }
        
        UIView *backView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,86)];
        backView.backgroundColor=[Utiles colorWithHexString:[Utiles getConfigureInfoFrom:@"colorconfigure" andKey:@"NormalCellColor" inUserDomain:NO]];
        [cell setBackgroundView:backView];
        cell.gooGuuPriceLabel.layer.cornerRadius = 5;
        cell.gooGuuPriceLabel.layer.borderColor = [Utiles colorWithHexString:@"#EAC117"].CGColor;
        cell.gooGuuPriceLabel.layer.borderWidth = 1;
        cell.marketPriceLabel.layer.cornerRadius = 5;
        cell.marketPriceLabel.layer.borderColor = [Utiles colorWithHexString:@"#599653"].CGColor;
        cell.marketPriceLabel.layer.borderWidth = 1;
        cell.percentLabel.layer.cornerRadius = 5;        
        cell.percentLabel.layer.borderWidth = 1;
        

    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
    
    
    UILongPressGestureRecognizer *longP=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longAction:andCellIndex:)];
    [cell addGestureRecognizer:longP];
    [longP release];
    
    return cell;    
}

-(void)longAction:(UILongPressGestureRecognizer *)press andCellIndex:(NSIndexPath *)indexPath{
    [customTableView setEditing:YES animated:YES];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        if (editingStyle==UITableViewCellEditingStyleDelete) {
            NSInteger row = [indexPath row];
            NSString *stockCode=[[[self.comInfoList objectAtIndex:row] objectForKey:@"stockcode"] copy];
            [self.comInfoList removeObjectAtIndex:row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"],@"token",@"googuu",@"from",stockCode,@"stockcode", nil];
            [Utiles postNetInfoWithPath:@"DeleteAttention" andParams:params besidesBlock:^(id resObj){
                if(![[resObj objectForKey:@"status"] isEqualToString:@"1"]){
                    [Utiles ToastNotification:[resObj objectForKey:@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 62.0;
}
#pragma mark Table Delegate Methods



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    int row=indexPath.row;
    delegate.comInfo=[self.comInfoList objectAtIndex:row];
    
    ComFieldViewController *com=[[ComFieldViewController alloc] init];
    com.view.frame=CGRectMake(0,20,320,480);
    [self presentViewController:com animated:YES completion:nil];
    
    /*CATransition *animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFilterLinear;
    animation.type = kCATransitionPush;
    animation.subtype = kCATransitionFromTop;
    [[com.view layer] addAnimation:animation forKey:@"animation"];
    animation=nil;
    */
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
    [customTableView setEditing:NO animated:YES];
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



/*-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    //NSLog(@"concern didRotateFromInterfaceOrientation");
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration NS_AVAILABLE_IOS(3_0)
{
    //NSLog(@"concern willAnimateRotationToInterfaceOrientation");
    XYZAppDelegate *delegate1=[[UIApplication sharedApplication] delegate];
    [[delegate1.tabBarController.childViewControllers objectAtIndex:5] willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}*/


-(NSUInteger)supportedInterfaceOrientations{
    
    //NSLog(@"concern supportedInterfaceOrientations");
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate{

    return NO;
}




@end

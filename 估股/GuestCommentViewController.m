//
//  GuestCommentViewController.h
//  welcom_demo_1
//
//  Created by Xcode on 13-5-8.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 股票详细页-用户评论

#import "GuestCommentViewController.h"
#import "UserCell.h"
#import "NSDictionary+MutableDeepCopy.h"
#import "UIImageView+AFNetworking.h"
#import "XYZAppDelegate.h"
#import "MHTabBarController.h"
#import "CustomTableView.h"
#import "EGORefreshTableHeaderView.h"
#import "ComFieldViewController.h"
#import "AddCommentViewController.h"
#import "PrettyKit.h"


@interface GuestCommentViewController ()

@end

@implementation GuestCommentViewController

@synthesize nibsRegistered;

@synthesize commentList;

@synthesize search;
@synthesize table;



- (void)dealloc
{
    SAFE_RELEASE(commentList);
    SAFE_RELEASE(search);
    SAFE_RELEASE(table);
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

-(void)viewDidDisappear:(BOOL)animated{

    if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"]){
        NSMutableArray *arr=[(ComFieldViewController *)self.parentViewController.parentViewController.parentViewController myToolBarItems];
        [arr removeLastObject];
        UIToolbar *toolBar=[(ComFieldViewController *)self.parentViewController.parentViewController.parentViewController top];
        [toolBar setItems:[NSArray arrayWithArray:arr] animated:YES];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{

    if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"]){
        UIBarButtonItem *wanSay=[[UIBarButtonItem alloc] initWithTitle:@"添加评论" style:UIBarButtonItemStyleBordered target:self action:@selector(wanSay:)];
        
        self.parentViewController.parentViewController.navigationController.navigationItem.rightBarButtonItem=wanSay;
        
        NSMutableArray *arr=[(ComFieldViewController *)self.parentViewController.parentViewController.parentViewController myToolBarItems];
        [arr addObject:wanSay];
        
        PrettyToolbar *toolBar=[(ComFieldViewController *)self.parentViewController.parentViewController.parentViewController top];
        [toolBar setItems:[NSArray arrayWithArray:arr] animated:YES];
        [wanSay release];
        
    }
    [self.table reloadData];
}

-(void)wanSay:(id)sender{
    
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    id comInfo=delegate.comInfo;
    
    NSString *code=[NSString stringWithFormat:@"%@",[comInfo objectForKey:@"stockcode"]];
    
    AddCommentViewController *addCommentViewController=[[AddCommentViewController alloc] initWithNibName:@"AddCommentView" bundle:nil];
    addCommentViewController.articleId=code;
    addCommentViewController.type=CompanyType;
    
    [self presentViewController:addCommentViewController animated:YES completion:nil];
    [addCommentViewController release];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor redColor]];
    
    self.table=[[UITableView alloc] initWithFrame:CGRectMake(0,0,320,383)];
    self.table.delegate=self;
    self.table.dataSource=self;
    
    [self.view addSubview:self.table];
    
    if(_refreshHeaderView == nil)
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.table.bounds.size.height, self.view.frame.size.width, self.table.bounds.size.height)];
        
        view.delegate = self;
        [self.table addSubview:view];
        _refreshHeaderView = view;
        
        [view release];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    [self getComments];
    

    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    CGPoint change=[tap translationInView:self.view];
    
    if(change.x>FINGERCHANGEDISTANCE){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:2 animated:YES];
    }
}

-(void)getComments{
    
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    NSString *stockCode=[NSString stringWithFormat:@"%@",[delegate.comInfo objectForKey:@"stockcode"]];

    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:stockCode,@"stockcode", nil];
    [Utiles postNetInfoWithPath:@"CompanyArticleURL" andParams:params besidesBlock:^(id obj){
        if([obj JSONString].length>5){
            self.commentList=obj;
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.table];
            [table reloadData];
        }else{
            [Utiles ToastNotification:@"暂无评论" andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.table];
        }
    }];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table Data Source Methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *UserCellIdentifier = @"UserCellIdentifier";
    
    if(!nibsRegistered){
        UINib *nib=[UINib nibWithNibName:@"UserCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:UserCellIdentifier];
        nibsRegistered = YES;
    }
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:UserCellIdentifier];
    if (cell == nil) {
        cell = [[UserCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:UserCellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    id model=[self.commentList objectAtIndex:row];
    
    cell.name = [model objectForKey:@"author"];
    cell.dec = [model objectForKey:@"content"];
    cell.loc = [model objectForKey:@"updatetime"];
    
    @try {
        if([[NSString stringWithFormat:@"%@",[model objectForKey:@"headerpicurl"]] length]>7){
            //异步加载cell图片
            [cell.imageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[model objectForKey:@"headerpicurl"]]]
              placeholderImage:[UIImage imageNamed:@"pumpkin.png"]
                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                           cell.image = image;
                           
                       }
                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                           
                       }];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    UIView *backView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,86)];
    backView.backgroundColor=[Utiles colorWithHexString:@"#EFEBD9"];
    [cell setBackgroundView:backView];
    return cell;
}


#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark - Table Header View Methods


- (void)doneLoadingTableViewData{
    
    
    [self getComments];
    [self.table reloadData];
    
    _reloading = NO;
    
    //[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.customTableView];
    
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

- (BOOL)shouldAutorotate{
    return NO;
}


















@end

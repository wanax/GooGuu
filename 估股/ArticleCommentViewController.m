//
//  ArticleCommentViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-16.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "ArticleCommentViewController.h"
#import "ArticleCommentModel.h"
#import "UserCell.h"
#import "MHTabBarController.h"
#import "UIImageView+AFNetworking.h"
#import "AddCommentViewController.h"
#import "PrettyKit.h"
#import "AnalyDetailViewController.h"

@interface ArticleCommentViewController ()

@end

@implementation ArticleCommentViewController

@synthesize articleId;
@synthesize cusTable;
@synthesize commentArr;
@synthesize type;

- (void)dealloc
{
    [commentArr release];
    [cusTable release];
    [articleId release];
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
    
    if([Utiles isLogin]){
        if(self.type==StockCompany){
            NSMutableArray *arr=[(AnalyDetailViewController *)self.parentViewController.parentViewController.parentViewController myToolBarItems];
            [arr removeLastObject];
            UIToolbar *toolBar=[(AnalyDetailViewController *)self.parentViewController.parentViewController.parentViewController top];
            [toolBar setItems:[NSArray arrayWithArray:arr] animated:YES];
        }
    }
  
}

-(void)viewDidAppear:(BOOL)animated{
    
    if([Utiles isLogin]){
        if(self.type==News){
            UIBarButtonItem *wanSay=[[UIBarButtonItem alloc] initWithTitle:@"添加评论" style:UIBarButtonItemStyleBordered target:self action:@selector(wanSay:)];
            self.parentViewController.navigationItem.rightBarButtonItem=wanSay;
            CATransition *transition=[CATransition animation];
            transition.duration=0.4f;
            transition.fillMode=kCAFillModeForwards;
            transition.type=kCATruncationMiddle;
            transition.subtype=kCATransitionFromRight;
            [self.parentViewController.navigationController.navigationBar.layer addAnimation:transition forKey:@"animation"];
        }else{
            NSAssert(self.type==StockCompany,@"Analy Report");
            UIBarButtonItem *wanSay=[[UIBarButtonItem alloc] initWithTitle:@"添加评论" style:UIBarButtonItemStyleBordered target:self action:@selector(wanSay:)];
            NSMutableArray *arr=[(AnalyDetailViewController *)self.parentViewController.parentViewController.parentViewController myToolBarItems];
            [arr addObject:wanSay];
            
            PrettyToolbar *toolBar=[(AnalyDetailViewController *)self.parentViewController.parentViewController.parentViewController top];
            [toolBar setItems:[NSArray arrayWithArray:arr] animated:YES];
            [wanSay release];
            [self.cusTable reloadData];
        }
    }
  
    [self getComment];
    
}

-(void)wanSay:(id)sender{
    AddCommentViewController *addCommentViewController=[[AddCommentViewController alloc] initWithNibName:@"AddCommentView" bundle:nil];
    addCommentViewController.articleId=self.articleId;
    
    if(self.type==News){
        addCommentViewController.type=NewsType;
        [(UINavigationController *)self.parentViewController.parentViewController pushViewController:addCommentViewController animated:YES];
    }else{
        NSAssert(self.type==StockCompany,@"Should be articel");
        addCommentViewController.type=ArticleType;
        [self presentViewController:addCommentViewController animated:YES completion:nil];
    }
    
    [addCommentViewController release];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    nibsRegistered=NO;

    
    self.cusTable=[[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    self.cusTable.dataSource=self;
    self.cusTable.delegate=self;
    [self.view addSubview:cusTable];
    if(_refreshHeaderView == nil)
    {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.cusTable.bounds.size.height, self.view.frame.size.width, self.cusTable.bounds.size.height)];
        
        view.delegate = self;
        [self.cusTable addSubview:view];
        _refreshHeaderView = view;
        
        [view release];
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    
    [self getComment];
  
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    CGPoint change=[tap translationInView:self.view];
    
    if(change.x>FINGERCHANGEDISTANCE){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:0 animated:YES];
    }
}

-(void)getComment{

    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:self.articleId,@"articleid", nil];
    [Utiles getNetInfoWithPath:@"Commentary" andParams:params besidesBlock:^(id resObj){
        self.commentArr=resObj;
        
        [self.cusTable reloadData];
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.cusTable];
    }];
    
}

#pragma mark -
#pragma mark Table Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentArr count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    NSAssert([self.commentArr count]>=row,@"index bound");
    id model=[self.commentArr objectAtIndex:row];
    
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



#pragma mark -
#pragma mark Table Methods Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark - Table Header View Methods


- (void)doneLoadingTableViewData{
    
    
    [self getComment];
    [self.cusTable reloadData];
    
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (BOOL)shouldAutorotate{
    return NO;
}


- (NSUInteger)supportedInterfaceOrientations{

    return UIInterfaceOrientationMaskPortrait;
}






















@end

//
//  SaveModelViewController.m
//  UIDemo
//
//  Created by Xcode on 13-6-18.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "SaveModelViewController.h"
#import "ClientLoginViewController.h"
#import "CustomTableView.h"
#import "CustomCell.h"
#import "AddCell.h"
#import "UserCell.h"
#import "XYZAppDelegate.h"
#import "MHTabBarController.h"
#import "Utiles.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSONKit.h"
#import "ComFieldViewController.h"

@interface SaveModelViewController ()

@end

@implementation SaveModelViewController

@synthesize companyFieldViewController;

@synthesize loginViewController;
@synthesize customTableView;

@synthesize comInfoList;


- (void)dealloc
{
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
    
    [self getSaveComList];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"小马财经";
    
    self.navigationController.navigationBarHidden=YES;
    
    self.comInfoList=[[NSMutableArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"",@"googuuprice",@"",@"marketprice",@"",@"market",@"",@"companyname", nil],nil];
    
   	customTableView=[[CustomTableView alloc] initWithFrame:CGRectMake(0,0,320,330)];
    
    customTableView.dataSource=self;
    customTableView.delegate=self;
    
    [self.view addSubview:customTableView];
    
    [self getSaveComList];

    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
    
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    CGPoint change=[tap translationInView:self.view];
    if(change.x<-100){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:2 animated:YES];
    }else if(change.x>100){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:0 animated:YES];
    }
}


-(void)getSaveComList{
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.googuu.net"]];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"], @"token",@"googuu",@"from",
                            nil];
    [httpClient postPath:@"/m/saveddata "
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     
                     
                     self.comInfoList=[operation.responseString objectFromJSONString];
                     [customTableView reloadData];
                     
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
                 }];
    
    [httpClient release];
    [self.customTableView reloadData];
    
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
    
    static BOOL nibsRegistered = NO;
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
    
    NSUInteger row = [indexPath row];
    id com=[self.comInfoList objectAtIndex:row];
    cell.name=[com objectForKey:@"companyname"];
    cell.nameLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
    cell.topImg=[UIImage imageNamed:@"web.png"];
    cell.bottomImg=[UIImage imageNamed:@"up.png"];
    cell.gPrice=[NSString stringWithFormat:@"%@",[com objectForKey:@"googuuprice"]];
    cell.gPriceLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
    cell.price=[NSString stringWithFormat:@"%@",[com objectForKey:@"marketprice"]];
    cell.belong=[com objectForKey:@"market"];
    UIView *backView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,86)];
    backView.backgroundColor=[Utiles colorWithHexString:@"#FEF8F8"];
    [cell setBackgroundView:backView];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}

#pragma mark Table Delegate Methods



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    int row=indexPath.row;
    delegate.comInfo=[self.comInfoList objectAtIndex:row];
    
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
   
    
}


-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate{
    NSLog(@"save");
    return NO;
}


















@end

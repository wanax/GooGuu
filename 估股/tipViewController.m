//
//  tipViewController.h
//  welcom_demo_1
//
//  Created by chaoxiao zhuang on 13-04-10.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-04-10 | Wanax | 初次使用引导界面

#import "tipViewController.h"
#import "XYZAppDelegate.h"
#import "GooNewsViewController.h"
#import "MyGooguuViewController.h"
#import "FinanceToolsViewController.h"
#import "ClientCenterViewController.h"
#import "DBLite.h"
#import "PrettyTabBarViewController.h"
#import "ClientCenterViewController.h"
#import "UniverseViewController.h"
#import "ChartViewController.h"
#import "Company.h"
#import "PrettyNavigationController.h"
#import "PrettyTabBarViewController.h"
#import "Utiles.h"
#import "Reachability.h"
#import "ChartViewController.h"
#import "CommonlyMacros.h"

@interface tipViewController ()

@end

@implementation tipViewController


#define HEIGHT 460
#define SAWTOOTH_COUNT 10
#define SAWTOOTH_WIDTH_FACTOR 20 

@synthesize imageView;
@synthesize left = _left;
@synthesize right = _right;
@synthesize pageScroll;
@synthesize pageControl;
@synthesize gotoMainViewBtn;

- (void)dealloc
{
    SAFE_RELEASE(imageView);
    SAFE_RELEASE(_left);
    SAFE_RELEASE(_right);
    SAFE_RELEASE(pageControl);
    SAFE_RELEASE(pageScroll);
    SAFE_RELEASE(gotoMainViewBtn);
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
    
    self.view.backgroundColor = [UIColor whiteColor];
        
    pageScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, HEIGHT)];
    pageScroll.contentSize = CGSizeMake(5*320, HEIGHT);
    pageScroll.pagingEnabled = YES;
    pageScroll.delegate = self;
    [pageScroll setShowsHorizontalScrollIndicator:NO];
    
    self.gotoMainViewBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.gotoMainViewBtn.frame = CGRectMake(110, 200, 80, 30);
    [self.gotoMainViewBtn setTitle:@"Go In To" forState:UIControlStateNormal];
    [self.gotoMainViewBtn addTarget:self action:@selector(gotoMainView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = CGRectMake(0, 0, 320, 480);
    self.imageView.image = [UIImage imageNamed:@"66.png"];
    
    
    UIImageView * imageView1 = [[UIImageView alloc]init];
    imageView1.image = [UIImage imageNamed:@"welcome1.png"];
    
    UIImageView * imageView2 = [[UIImageView alloc]init];
    imageView2.image = [UIImage imageNamed:@"22.png"];
    
    UIImageView * imageView3 = [[UIImageView alloc]init];
    imageView3.image = [UIImage imageNamed:@"33.png"];
    
    UIImageView * imageView4 = [[UIImageView alloc]init];
    imageView4.image = [UIImage imageNamed:@"44.png"];
    
    UIView * returnView = [[UIView alloc]init];
    returnView.backgroundColor = [UIColor redColor];
    [returnView addSubview:self.imageView];
    [returnView addSubview:self.gotoMainViewBtn];
    
    
    for(int i = 0; i < 5; ++ i )
    {
        if( i == 0 )
        {
            [pageScroll addSubview:imageView1];
            imageView1.frame = CGRectMake(i*320, 0, 320, HEIGHT);
        }
        else if( i == 1 )
        {
            [pageScroll addSubview:imageView2];
            imageView2.frame = CGRectMake(i*320, 0, 320, HEIGHT);
        }
        else if( i == 2 )
        {
            [pageScroll addSubview:imageView3];
            imageView3.frame = CGRectMake(i*320, 0, 320, HEIGHT);
        }
        else if( i == 3 )
        {
            [pageScroll addSubview:imageView4];
            imageView4.frame = CGRectMake(i*320, 0, 320, HEIGHT);
        }
        else if( i == 4 )
        {
            returnView.frame = CGRectMake(i*320, 0, 320, HEIGHT);
            [pageScroll addSubview:returnView];
        }
    }
    
    [self.view addSubview:pageScroll];
    
    
    pageControl = [[UIPageControl alloc] init];
    pageControl.frame = CGRectMake(141,364,50,50);
    [pageControl setNumberOfPages:5];
    pageControl.currentPage = 0;
    [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:pageControl];
    
}


-(void)hide{
    UIApplication *app=[UIApplication sharedApplication];
    [app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)gotoMainView:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstLaunch"];
       

    [self.pageControl setHidden:YES];
    [self.pageScroll setHidden:YES];
    
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    
    CATransition *animation =[CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFillModeForwards;
    animation.type = kCATruncationMiddle;
    animation.subtype = kCATransitionFromRight;
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    
    UITabBarItem *barItem=[[UITabBarItem alloc] initWithTitle:@"估股动态" image:[UIImage imageNamed:@"googuuNewsBar"] tag:1];
    UITabBarItem *barItem2=[[UITabBarItem alloc] initWithTitle:@"我的估股" image:[UIImage imageNamed:@"myGooGuuBar"] tag:2];
    UITabBarItem *barItem3=[[UITabBarItem alloc] initWithTitle:@"金融工具" image:[UIImage imageNamed:@"hammer.png"] tag:3];
    UITabBarItem *barItem4=[[UITabBarItem alloc] initWithTitle:@"功能设置" image:[UIImage imageNamed:@"moreAboutBar"] tag:4];
    UITabBarItem *barItem5=[[UITabBarItem alloc] initWithTitle:@"估值模型" image:[UIImage imageNamed:@"companyListBar"] tag:5];
    
    //股票关注
    MyGooguuViewController *myGooGuu=[[MyGooguuViewController alloc] init];
    myGooGuu.tabBarItem=barItem2;
    PrettyNavigationController *myGooGuuNavController=[[PrettyNavigationController alloc] initWithRootViewController:myGooGuu];

    //客户设置
    ClientCenterViewController *clientView=[[ClientCenterViewController alloc] init];
    clientView.tabBarItem=barItem4;
    PrettyNavigationController *clientCenterNav=[[PrettyNavigationController alloc] initWithRootViewController:clientView];
    
    
    //估股新闻
    GooNewsViewController *gooNewsViewController=[[GooNewsViewController alloc] init];
    gooNewsViewController.tabBarItem=barItem;
    PrettyNavigationController *gooNewsNavController=[[PrettyNavigationController alloc] initWithRootViewController:gooNewsViewController];
    
    
    //股票列表
    UniverseViewController *universeViewController=[[UniverseViewController alloc] init];
    universeViewController.tabBarItem=barItem5;
    PrettyNavigationController *universeNav=[[PrettyNavigationController alloc] initWithRootViewController:universeViewController];
    
    
    
    
    delegate.tabBarController = [[[PrettyTabBarViewController alloc] init] autorelease];
    
    delegate.tabBarController.viewControllers = [NSArray arrayWithObjects:gooNewsNavController,universeNav,myGooGuuNavController, clientCenterNav ,nil];
    
    delegate.window.backgroundColor=[UIColor clearColor];
    delegate.window.rootViewController = self.tabBarController;
    
    [delegate.window addSubview:delegate.tabBarController.view];

    
    [[delegate.window layer] addAnimation:animation forKey:kCATransitionReveal];
    
    SAFE_RELEASE(barItem);
    SAFE_RELEASE(barItem2);
    SAFE_RELEASE(barItem3);
    SAFE_RELEASE(barItem4);
    SAFE_RELEASE(barItem5);
    
    SAFE_RELEASE(myGooGuu);
    SAFE_RELEASE(clientView);
    SAFE_RELEASE(gooNewsNavController);
    SAFE_RELEASE(universeViewController);
    
    SAFE_RELEASE(myGooGuuNavController);
    SAFE_RELEASE(clientCenterNav);
    SAFE_RELEASE(gooNewsNavController);
    SAFE_RELEASE(universeNav);
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //NSLog(@"scrollViewDidScroll");
    CGPoint offset = scrollView.contentOffset;
    pageControl.currentPage = offset.x/320;
}


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // NSLog(@"scrollViewDidEndDecelerating");
    CGPoint offset = scrollView.contentOffset;
    pageControl.currentPage = offset.x / 320;
}


-(void)pageTurn:(UIPageControl*)aPageControl
{
    NSLog(@"pageTurn");
    /*
    int whichPage = aPageControl.currentPage;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:2];
    pageScroll.contentOffset = CGPointMake(320*whichPage, 0);
    [UIView commitAnimations];
     */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"shouldAutorotateToInterfaceOrientation");
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end






































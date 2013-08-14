//
//  MyGooguuViewController.m
//  UIDemo
//
//  Created by Xcode on 13-6-18.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "MyGooguuViewController.h"
#import "ConcernedViewController.h"
#import "ClientLoginViewController.h"
#import "MHTabBarController.h"
#import "GooGuuContainerViewController.h"
#import "XYZAppDelegate.h"


@interface MyGooguuViewController ()

//界面基本参数
- (void) addBasicView;
- (void) addToolBar;
- (void) addButtonAndSlid;

//左右滑动相关
- (void)initScrollView;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)createAllEmptyPagesForScrollView;

//界面按钮事件
- (void) btnActionShow;
- (void) concernButtonAction;
- (void) saveButtonAction;


@end

@implementation MyGooguuViewController

@synthesize concernedViewController;
@synthesize saveModelViewControler;

@synthesize concernNavViewController;

@synthesize concernButton;
@synthesize saveButton;

@synthesize scrollView;
@synthesize slidLabel;
@synthesize pageControl;
@synthesize tabBarController;

- (void)dealloc
{
    [tabBarController release];tabBarController=nil;
    [concernedViewController release];concernedViewController=nil;
    [saveModelViewControler release];saveModelViewControler=nil;
    
    [concernNavViewController release];concernNavViewController=nil;
    
    [concernButton release];concernButton=nil;
    [saveButton release];saveButton=nil;
    
    [scrollView release];scrollView=nil;
    [slidLabel release];slidLabel=nil;
    [pageControl release];pageControl=nil;
    
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

- (void)viewDidAppear:(BOOL)animated{
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"]){
        ClientLoginViewController *loginViewController = [[ClientLoginViewController alloc] init];
        
        loginViewController.view.frame=CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT);
        XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
        [delegate.window addSubview:loginViewController.view];
        [self addChildViewController:loginViewController];
        [loginViewController release];
        
        CATransition *animation = [CATransition animation];
        //animation.delegate = self;
        animation.duration = 0.5f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.fillMode = kCAFillModeForwards;
        animation.type = kCATransitionMoveIn;
        animation.subtype = kCATransitionFromTop;
        [loginViewController.view.layer addAnimation:animation forKey:@"animation"];
    }
 
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"我的估股"];
    
    GooGuuContainerViewController *content=[[GooGuuContainerViewController alloc] init];
    content.view.frame=CGRectMake(0,-21,SCREEN_WIDTH,SCREEN_HEIGHT);

    [self.view addSubview:content.view];
    [self addChildViewController:content];
    SAFE_RELEASE(content);
    
}


-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        
    } else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){

    }
}

-(NSUInteger)supportedInterfaceOrientations{
    
    if([[self childViewControllers] count]>0){
        return [[self.childViewControllers objectAtIndex:0] supportedInterfaceOrientations];
    }else{
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    
}

- (BOOL)shouldAutorotate{

    if([[self childViewControllers] count]>0){
        return [[self.childViewControllers objectAtIndex:0] shouldAutorotate];
    }else{
        return NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}























@end

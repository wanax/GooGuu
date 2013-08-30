//
//  TestViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-10.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "GooGuuContainerViewController.h"
#import "MHTabBarController.h"
#import "ConcernedViewController.h"
#import "CalendarViewController.h"
#import "CommonlyMacros.h"

@interface GooGuuContainerViewController ()

@end

@implementation GooGuuContainerViewController

@synthesize concernedViewController;
@synthesize saveModelViewControler;
@synthesize calendarViewController;
@synthesize tabBarController;

- (void)dealloc
{
    SAFE_RELEASE(tabBarController);
    SAFE_RELEASE(calendarViewController);
    SAFE_RELEASE(concernedViewController);
    SAFE_RELEASE(saveModelViewControler);
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
    concernedViewController = [[ConcernedViewController alloc] init];
    concernedViewController.type=@"AttentionData";
    concernedViewController.browseType=MyConcernedType;
    saveModelViewControler = [[ConcernedViewController alloc] init];
    saveModelViewControler.type=@"SavedData";
    saveModelViewControler.browseType=MySavedType;
    calendarViewController=[[CalendarViewController alloc] init];
    calendarViewController.view.frame=CGRectMake(0,100,SCREEN_WIDTH,600);
    concernedViewController.title=@"我的关注";
    saveModelViewControler.title=@"我的模型";
    calendarViewController.title=@"投资日历";

    
    
	NSArray *viewControllers = @[concernedViewController, saveModelViewControler,calendarViewController];
	tabBarController = [[MHTabBarController alloc] init];
	tabBarController.viewControllers = viewControllers;
    
    [self addChildViewController:tabBarController];
    [self.view addSubview:tabBarController.view];
    
}



-(NSUInteger)supportedInterfaceOrientations{
  
    return [self.tabBarController selectedViewController].supportedInterfaceOrientations;
}

- (BOOL)shouldAutorotate{

    return [self.tabBarController selectedViewController].shouldAutorotate;
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}








@end

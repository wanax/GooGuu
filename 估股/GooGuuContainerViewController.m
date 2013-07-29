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

@interface GooGuuContainerViewController ()

@end

@implementation GooGuuContainerViewController

@synthesize concernedViewController;
@synthesize saveModelViewControler;
@synthesize calendarViewController;
@synthesize tabBarController;

- (void)dealloc
{
    [tabBarController release];
    [calendarViewController release];
    [concernedViewController release];
    [saveModelViewControler release];
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
    saveModelViewControler = [[ConcernedViewController alloc] init];
    saveModelViewControler.type=@"SavedData";
    calendarViewController=[[CalendarViewController alloc] init];
    calendarViewController.view.frame=CGRectMake(0,100,320,600);
    concernedViewController.title=@"已关注";
    saveModelViewControler.title=@"已保存";
    calendarViewController.title=@"投资日历";

    
    
	NSArray *viewControllers = [NSArray arrayWithObjects:concernedViewController, saveModelViewControler,calendarViewController, nil];
	tabBarController = [[MHTabBarController alloc] init];
    
	tabBarController.viewControllers = viewControllers;
    
    [self.view addSubview:tabBarController.view];
    [self addChildViewController:tabBarController];
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

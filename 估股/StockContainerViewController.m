//
//  StockContainerViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-11.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "StockContainerViewController.h"
#import "MHTabBarController.h"
#import "CompanyListViewController.h"

@interface StockContainerViewController ()

@end

@implementation StockContainerViewController

@synthesize hkListViewController;
@synthesize szListViewController;
@synthesize usListViewController;
@synthesize shListViewController;
@synthesize tabBarController;

- (void)dealloc
{
    [tabBarController release];
    [hkListViewController release];
    [szListViewController release];
    [shListViewController release];
    [usListViewController release];
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
    
    hkListViewController = [[CompanyListViewController alloc] init];
    usListViewController = [[CompanyListViewController alloc] init];
    szListViewController = [[CompanyListViewController alloc] init];
    shListViewController = [[CompanyListViewController alloc] init];

    hkListViewController.comType=@"港交所";
    usListViewController.comType=@"美股";
    szListViewController.comType=@"深市";
    shListViewController.comType=@"沪市";
    
    hkListViewController.title=@"港交所";
    usListViewController.title=@"美股";
    szListViewController.title=@"深市";
    shListViewController.title=@"沪市";
    
    hkListViewController.type=HK;
    usListViewController.type=NANY;
    szListViewController.type=SZSE;
    shListViewController.type=SHSE;
    
    hkListViewController.isShowSearchBar=NO;
    usListViewController.isShowSearchBar=NO;
    szListViewController.isShowSearchBar=NO;
    shListViewController.isShowSearchBar=NO;
  
	NSArray *viewControllers = [NSArray arrayWithObjects:hkListViewController, usListViewController,szListViewController,shListViewController, nil];
	tabBarController = [[MHTabBarController alloc] init];
    
	tabBarController.viewControllers = viewControllers;
    
    [self.view addSubview:tabBarController.view];
    [self addChildViewController:tabBarController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations{

    return [[self.tabBarController selectedViewController] supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate
{
    return [[self.tabBarController selectedViewController] shouldAutorotate];
}

















@end

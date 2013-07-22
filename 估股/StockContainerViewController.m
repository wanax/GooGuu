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
@synthesize csiListViewController;
@synthesize usListViewController;
@synthesize tabBarController;

- (void)dealloc
{
    [tabBarController release];
    [hkListViewController release];
    [csiListViewController release];
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
    csiListViewController = [[CompanyListViewController alloc] init];

    hkListViewController.comType=@"港交所";
    usListViewController.comType=@"美股";
    csiListViewController.comType=@"沪深";
    
    hkListViewController.title=@"港交所";
    usListViewController.title=@"美股";
    csiListViewController.title=@"沪深";
    
    hkListViewController.type=HK;
    usListViewController.type=NANY;
    csiListViewController.type=SHSZSE;
    
    hkListViewController.isShowSearchBar=NO;
    usListViewController.isShowSearchBar=NO;
    csiListViewController.isShowSearchBar=NO;
  
	NSArray *viewControllers = [NSArray arrayWithObjects:hkListViewController, usListViewController,csiListViewController, nil];
	tabBarController = [[MHTabBarController alloc] init];
    
	tabBarController.viewControllers = viewControllers;
    
    [self.view addSubview:tabBarController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



















@end

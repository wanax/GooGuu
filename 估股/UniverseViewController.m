//
//  UniverseViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-11.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "UniverseViewController.h"
#import "XYZAppDelegate.h"
#import "StockContainerViewController.h"
#import "CompanyListViewController.h"
#import "DBLite.h"

@interface UniverseViewController ()

@end

@implementation UniverseViewController

@synthesize theSearchBar;


- (void)dealloc {
    [theSearchBar release], theSearchBar = nil;
    [super dealloc];
}



- (void)viewDidLoad
{
	[super viewDidLoad];
    self.title=@"股票搜索";
    // Do any additional setup after loading the view.
    StockContainerViewController *content=[[StockContainerViewController alloc] init];
    content.view.frame=CGRectMake(0,20,320,480);
    
    [self.view addSubview:content.view];
    [self addChildViewController:content];
    
    self.theSearchBar=[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,40)];
    
    [[self.theSearchBar.subviews objectAtIndex:0] removeFromSuperview];
    self.theSearchBar.backgroundColor = [UIColor grayColor];
    
    self.theSearchBar.delegate=self;
    [self.view addSubview:self.theSearchBar];
    [content release];
}


- (void)viewDidAppear:(BOOL)animated {
    //[self.theSearchBar becomeFirstResponder];
    [super viewDidAppear:animated];
}



#pragma mark -
#pragma mark Search Delegate Methods


-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
    [self.theSearchBar resignFirstResponder];
    CompanyListViewController *nextController=[[CompanyListViewController alloc] init];
    nextController.comType=@"全部";
    nextController.isShowSearchBar=YES;
    nextController.type=ALL;
    
    if(![self.navigationController.topViewController isKindOfClass:[CompanyListViewController class]]){
        @try{
            [self.navigationController pushViewController:nextController animated:YES];
            [theSearchBar resignFirstResponder];
        }@catch (NSException *e) {
            NSLog(@"%@",e);
        }
    }
    [self resignFirstResponder];
}



- (BOOL)shouldAutorotate
{
    return NO;
}

















@end
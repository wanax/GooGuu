//
//  ModelViewController.m
//  UIDemo
//
//  Created by Xcode on 13-5-8.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 股票详细页-股票模型

#import "ModelViewController.h"
#import "Utiles.h"
#import "ChartViewController.h"

@interface ModelViewController ()

@end

@implementation ModelViewController

@synthesize chartViewController;

- (void)dealloc
{
    [chartViewController release];
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
    [self.view setBackgroundColor:[Utiles colorWithHexString:@"#EFEBD9"]];

    chartViewController=[[ChartViewController alloc] init];
    chartViewController.view.frame=CGRectMake(0,0,480,320);
    [self.view addSubview:chartViewController.view];
    [self addChildViewController:chartViewController];
    [self setTitle:@"model"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //NSLog(@"model willAnimateRotationToInterfaceOrientation");
    [self.chartViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(NSUInteger)supportedInterfaceOrientations{
    //NSLog(@"model supportedInterfaceOrientations");
    return [self.chartViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate{
    //NSLog(@"model shouldAutorotate");
    return [self.chartViewController shouldAutorotate];
}

























@end

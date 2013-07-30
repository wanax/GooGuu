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
#import "UIButton+BGColor.h"
#import "MHTabBarController.h"

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
    [self.view setBackgroundColor:[Utiles colorWithHexString:@"#F3EFE1"]];

    UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt1.frame = CGRectMake(10, 20, 300, 50);
    [bt1 setTitle:@"查看模型金融模型" forState: UIControlStateNormal];
    [bt1 setBackgroundColorString:@"#C96125" forState:UIControlStateNormal];
    [bt1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bt1.titleLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
    bt1.tag = 1;
    [bt1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt1];
    UIButton *bt2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt2.frame = CGRectMake(10, 75, 300, 50);
    [bt2 setTitle:@"调整模型参数" forState: UIControlStateNormal];
    [bt2 setBackgroundColorString:@"#C96125" forState:UIControlStateNormal];
    [bt2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bt2.titleLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
    bt2.tag = 2;
    [bt2 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt2];
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];

}

-(void)panView:(UIPanGestureRecognizer *)tap{
    CGPoint change=[tap translationInView:self.view];
    if(change.x<-100){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
    }
}

-(void)buttonClicked:(UIButton *)bt{
    
    if(bt.tag==1){
        NSLog(@"1");
    }else if(bt.tag==2){
        chartViewController=[[ChartViewController alloc] init];
        chartViewController.view.frame=CGRectMake(0,0,480,320);
        [self presentViewController:chartViewController animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

    [self.chartViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(NSUInteger)supportedInterfaceOrientations{

    if([self isKindOfClass:NSClassFromString(@"ModelViewController")])
        return UIInterfaceOrientationMaskPortrait;

    return [self.chartViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate{

    return [self.chartViewController shouldAutorotate];
}

























@end

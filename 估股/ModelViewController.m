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
#import "FinancalModelChartViewController.h"
#import "CommonlyMacros.h"
#import "DahonValuationViewController.h"

@interface ModelViewController ()

@end

@implementation ModelViewController

@synthesize chartViewController;

- (void)dealloc
{
    SAFE_RELEASE(chartViewController);
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

    
    [self addNewButton:@"查看金融模型" Tag:1 frame:CGRectMake(10, 20, 300, 50)];
    [self addNewButton:@"调整模型参数" Tag:2 frame:CGRectMake(10, 75, 300, 50)];
    [self addNewButton:@"查看大行估值" Tag:3 frame:CGRectMake(10, 130, 300, 50)];
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];

}

-(void)addNewButton:(NSString *)title Tag:(NSInteger)tag frame:(CGRect)rect{
    UIButton *bt1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    bt1.frame = rect;
    [bt1 setTitle:title forState: UIControlStateNormal];
    [bt1 setBackgroundColorString:@"#C96125" forState:UIControlStateNormal];
    [bt1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    bt1.titleLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
    bt1.tag = tag;
    [bt1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bt1];
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    CGPoint change=[tap translationInView:self.view];
    if(change.x<-100){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
    }
}

-(void)buttonClicked:(UIButton *)bt{
    
    if(bt.tag==1){
        FinancalModelChartViewController *model=[[FinancalModelChartViewController alloc] init];
        [self presentViewController:model animated:YES completion:nil];
        SAFE_RELEASE(model);
    }else if(bt.tag==2){
        chartViewController=[[ChartViewController alloc] init];
        chartViewController.view.frame=CGRectMake(0,0,SCREEN_HEIGHT,SCREEN_WIDTH);
        [self presentViewController:chartViewController animated:YES completion:nil];
    }else if(bt.tag==3){
        DahonValuationViewController *dahon=[[DahonValuationViewController alloc] init];
        [self presentViewController:dahon animated:YES completion:nil];
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

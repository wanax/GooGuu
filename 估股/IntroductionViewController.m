//
//  IntroductionViewController.m
//  UIDemo
//
//  Created by Xcode on 13-5-8.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 股票详细页-股票介绍

#import "IntroductionViewController.h"
#import "Utiles.h"
#import "UIImageView+AFNetworking.h"
#import "XYZAppDelegate.h"
#import "MHTabBarController.h"

@interface IntroductionViewController ()

@end

@implementation IntroductionViewController


@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [imageView release];
    [super dealloc];
}

-(void)viewDidAppear:(BOOL)animated{
    

    
}

-(void)viewDidDisappear:(BOOL)animated{
    
    imageView.frame=CGRectMake(0,0,320,2400);
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    id comInfo=delegate.comInfo;
    NSString *url=[NSString stringWithFormat:@"%@",[comInfo objectForKey:@"companypicurl"]];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 350.0f, 2400.0f)];
    
    
    if(url.length>10){
        [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
        UIPanGestureRecognizer *panGest=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
        [imageView addGestureRecognizer:panGest];
        imageView.userInteractionEnabled = YES;
        [self.view insertSubview:imageView atIndex:0];
    }else{
        [Utiles ToastNotification:@"暂无数据" andView:self.view andLoading:NO andIsBottom:NO andIsHide:NO];
    }
    
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

-(void)move:(UIPanGestureRecognizer *)tapGr{
    
    CGPoint change=[tapGr translationInView:self.view];

    if(tapGr.state==UIGestureRecognizerStateChanged){
        
        imageView.frame=CGRectMake(0,MAX(MIN(standard.y+change.y,0),-2300),320,2600);

    }else if(tapGr.state==UIGestureRecognizerStateEnded){
        standard=imageView.frame.origin;
    }
    
    //手指向左滑动，向右切换scrollView视图
    if(change.x<-FINGERCHANGEDISTANCE&&change.y<5){

        [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer

{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






















@end

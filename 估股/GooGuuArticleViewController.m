//
//  GooGuuArticleViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-10.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "GooGuuArticleViewController.h"
#import "MHTabBarController.h"
#import "MBProgressHUD.h"
#import "Utiles.h"
#import <QuartzCore/QuartzCore.h>

@interface GooGuuArticleViewController ()

@end

@implementation GooGuuArticleViewController

@synthesize articleId;

- (void)dealloc
{
    [articleId release];
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

-(void)viewDidAppear:(BOOL)animated{

    CATransition *transition=[CATransition animation];
    transition.duration=0.4f;
    transition.fillMode=kCAFillModeRemoved;
    transition.type=kCATruncationMiddle;
    transition.subtype=kCATransitionFromRight;
    [self.parentViewController.navigationController.navigationBar.layer addAnimation:transition forKey:@"animation"];
    self.parentViewController.navigationItem.rightBarButtonItem=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor whiteColor];
    MBProgressHUD *hud=[[MBProgressHUD alloc] initWithView:self.view];
    [Utiles showHUD:@"Loading..." andView:self.view andHUD:hud];
    [UIApplication sharedApplication].networkActivityIndicatorVisible=YES;
    
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:articleId,@"articleid", nil];
    [Utiles getNetInfoWithPath:@"ArticleURL" andParams:params besidesBlock:^(id article){

        UIWebView *articleWeb=[[UIWebView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width, self.view.bounds.size.height)];
        [articleWeb loadHTMLString:[article objectForKey:@"content"] baseURL:nil];
        articleWeb.scalesPageToFit=YES;
        [hud hide:YES];
        [UIApplication sharedApplication].networkActivityIndicatorVisible=NO;
        [self.view addSubview:articleWeb];
        [articleWeb release];
        
    }];
  
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
    
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    CGPoint change=[tap translationInView:self.view];
    
    if(change.x<-FINGERCHANGEDISTANCE){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations{

    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotate{
    return NO;
}




















@end

//
//  ComFieldViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-10.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "ComFieldViewController.h"
#import "XYZAppDelegate.h"
#import "IntroductionViewController.h"
#import "ModelViewController.h"
#import "AnalysisReportViewController.h"
#import "MHTabBarController.h"
#import "ContainerViewController.h"
#import "PrettyToolbar.h"


@interface ComFieldViewController ()

@end

@implementation ComFieldViewController

@synthesize browseType;

@synthesize viewController1;
@synthesize viewController2;
@synthesize viewController3;
@synthesize viewController4;
@synthesize tabBarController;
@synthesize top;
@synthesize myToolBarItems;



- (void)dealloc
{
    SAFE_RELEASE(myToolBarItems);
    SAFE_RELEASE(top);
    SAFE_RELEASE(tabBarController);
    SAFE_RELEASE(viewController1);
    SAFE_RELEASE(viewController2);
    SAFE_RELEASE(viewController3);
    SAFE_RELEASE(viewController4);
    
    [super dealloc];
}

//退回主菜单
-(void)back:(id)sender{
    
    //XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    
    //viewController1.imageView.frame=CGRectMake(0,0,320,2600);
    
    /*[UIView beginAnimations:@"animation" context:nil];
     [UIView setAnimationDuration:0.8f];
     [UIView setAnimationCurve:UIViewAnimationCurveLinear];
     [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:delegate.window cache:YES];
     [UIView commitAnimations];
    
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5f;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.fillMode = kCAFilterNearest;
    animation.type = kCATransitionReveal;
    animation.subtype = kCATransitionFromBottom;
    [[delegate.window layer] addAnimation:animation forKey:@"animation"];
    animation=nil;
    
    [self removeFromParentViewController];
    [self.view removeFromSuperview];*/
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popToViewController:self animated:YES];
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
    ContainerViewController *content=[[ContainerViewController alloc] init];
    content.browseType=self.browseType;
    content.view.frame=CGRectMake(0,24,self.view.frame.size.width,self.view.frame.size.height);
    [self.view addSubview:content.view];
    [self addChildViewController:content];
    [self addToolBar];
    [content release];

    
}

-(void)addToolBar{
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    top=[[PrettyToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    UIBarButtonItem *back=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    myToolBarItems=[[NSMutableArray alloc] init];
    [myToolBarItems addObject:back];
    [top setItems:myToolBarItems];
    [self.view addSubview:top];
    [back release];
    [top release];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSUInteger)supportedInterfaceOrientations{
    
    if([[self childViewControllers] count]>0){
        return [[self.childViewControllers objectAtIndex:0] supportedInterfaceOrientations];
    }else{
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
}

- (BOOL)shouldAutorotate
{
    if([[self childViewControllers] count]>0){
        return [[self.childViewControllers objectAtIndex:0] shouldAutorotate];
    }else{
        return NO;
    }
}











@end

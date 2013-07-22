//
//  FinanceToolsViewController.m
//  UIDemo
//
//  Created by Xcode on 13-6-18.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "FinanceToolsViewController.h"
#import "LoginView.h"
#import "ClientLoginViewController.h"

@interface FinanceToolsViewController ()

@end

@implementation FinanceToolsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{

    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"]){
        ClientLoginViewController *loginViewController = [[ClientLoginViewController alloc] init];
        
        loginViewController.view.frame=CGRectMake(0, 20, 320, 480);
        
        [self.view addSubview:loginViewController.view];
        [self addChildViewController:loginViewController];
        [loginViewController release];
        
        CATransition *animation = [CATransition animation];
        //animation.delegate = self;
        animation.duration = 0.5f;
        animation.timingFunction = UIViewAnimationCurveEaseInOut;
        animation.fillMode = kCAFillModeForwards;
        animation.type = kCATransitionMoveIn;
        animation.subtype = kCATransitionFromTop;
        [loginViewController.view.layer addAnimation:animation forKey:@"animation"];
    }
    

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)shouldAutorotate{
    return NO;
}



















@end

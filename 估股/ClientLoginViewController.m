//
//  ClientLongViewController.m
//  UIDemo
//
//  Created by Xcode on 13-6-7.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  客户登录控制器


#import "ClientLoginViewController.h"
#import "LoginView.h"
#import "DBLite.h"
#import "ConcernedViewController.h"
#import "XYZAppDelegate.h"
#import "LoginView.h"
#import "MBProgressHUD.h"
#import "PrettyTabBarViewController.h"
#import "GooGuuContainerViewController.h"
#import "MHTabBarController.h"
#import "ConcernedViewController.h"


@interface ClientLoginViewController ()

@end

@implementation ClientLoginViewController

@synthesize loginView;


- (void)dealloc
{   
    [loginView release];loginView=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
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
    
    loginView=[[LoginView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [loginView setBackgroundColor:[[Utiles class] colorWithHexString:@"#34C3C1"]];
    
    [self.view addSubview:loginView];
    loginView.delegate=self;
    
    [loginView userNameField].delegate=self;
    [loginView userPwdField].delegate=self;
    UITapGestureRecognizer *out=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDisMiss)];
    [[loginView cancel] addGestureRecognizer:out];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isGoIn=NO;

}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    

    if(textField.tag==100){
        [textField resignFirstResponder];
    }else if(textField.tag==200){
        
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
        [Utiles showHUD:@"正在加载" andView:self.view andHUD:hud];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES ;
        NSString *name=[loginView userNameField].text;
        NSString *pwd=[loginView userPwdField].text;
        
        //NSString *name=@"mxchenry@163.com";
        //NSString *pwd=@"123456";
        
        NSDictionary *params=@{@"username": [name lowercaseString],@"password": [Utiles md5:pwd],@"from": @"googuu"};
        [Utiles getNetInfoWithPath:@"Login" andParams:params besidesBlock:^(id info){

            if([info[@"status"] isEqualToString:@"1"]){
             
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginKeeping" object:nil];
                [[NSUserDefaults standardUserDefaults] setObject:info[@"token"] forKey:@"UserToken"];
                NSDictionary *userInfo=@{@"username": name,@"password": pwd};
                [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"UserInfo"];
                
                NSLog(@"%@",info[@"token"]);
                isGoIn=YES;
                [self viewDisMiss];
                [textField resignFirstResponder];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO ;
                [hud hide:YES];
                [hud release];
                NSArray *controllers=self.parentViewController.childViewControllers;
                for(id obj in controllers){
                    if([obj isKindOfClass:[GooGuuContainerViewController class]]){
                        ConcernedViewController *test= (ConcernedViewController *)[[(GooGuuContainerViewController *)obj tabBarController] selectedViewController];
                        [test viewDidAppear:YES];
                    }
                }
            }else {
                NSLog(@"%@",info[@"msg"]);
            }
            
        }];
        
        [textField resignFirstResponder];
    }
    
    return YES;
}


-(void)viewDisMiss{
    [[loginView userNameField] resignFirstResponder];
    [[loginView userPwdField] resignFirstResponder];
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    [delegate.window addSubview:delegate.tabBarController.view];
    if(isGoIn){
        [delegate.tabBarController setSelectedIndex:2];
    }else if(!isGoIn){
        [delegate.tabBarController setSelectedIndex:0];
    }
    
    CATransition *transition=[CATransition animation];
    transition.duration=0.5f;
    transition.fillMode=kCAFillRuleEvenOdd;
    transition.type=kCATransitionReveal;
    transition.subtype=kCATransitionFromBottom;
    [delegate.window.layer addAnimation:transition forKey:@"animation"];
}

-(void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void *)context{
    NSLog(@"finished");
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"warning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate{
    return NO;
}

@end

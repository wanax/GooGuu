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
#import <QuartzCore/QuartzCore.h>
#import "DBLite.h"
#import "User.h"
#import "ConcernedViewController.h"
#import "XYZAppDelegate.h"
#import "Utiles.h"
#import "LoginView.h"
#import "MBProgressHUD.h"
#import "PrettyTabBarViewController.h"
#import "User.h"

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
    
    loginView=[[LoginView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
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
        //NSString *name=[loginView userNameField].text;
        //NSString *pwd=[loginView userPwdField].text;
        
        NSString *name=@"mxchenry@163.com";
        NSString *pwd=@"123456";
        
        NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[name lowercaseString],@"username",[Utiles md5:pwd],@"password",@"googuu",@"from", nil];
        [Utiles getNetInfoWithPath:@"Login" andParams:params besidesBlock:^(id info){

            if([[info objectForKey:@"status"] isEqualToString:@"1"]){
             
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginKeeping" object:nil];
                [[NSUserDefaults standardUserDefaults] setObject:[info objectForKey:@"token"] forKey:@"UserToken"];
                NSDictionary *userInfo=[NSDictionary dictionaryWithObjectsAndKeys:name,@"username",pwd,@"password", nil];
                [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"UserInfo"];
                
                NSLog(@"%@",[info objectForKey:@"token"]);
                isGoIn=YES;
                [self viewDisMiss];
                [textField resignFirstResponder];
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO ;
                [hud hide:YES];
                [hud release];
            }else {
                NSLog(@"%@",[info objectForKey:@"msg"]);
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
        [delegate.tabBarController setSelectedIndex:1];
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

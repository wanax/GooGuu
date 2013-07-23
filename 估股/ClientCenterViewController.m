//
//  ClientCenterViewController.m
//  UIDemo
//
//  Created by Xcode on 13-5-29.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "ClientCenterViewController.h"
#import "SettingCenterViewController.h"
#import "Utiles.h"
#import "DBLite.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSONKit.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"



@interface ClientCenterViewController ()


@end

@implementation ClientCenterViewController

@synthesize logoutButton;
@synthesize userIdLabel;
@synthesize userNameLabel;

@synthesize eventArr=_eventArr;
@synthesize dateDic=_dateDic;

- (void)dealloc
{
    [_dateDic release];
    [_eventArr release];
    [userNameLabel release];
    [userIdLabel release];
    [logoutButton release];
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
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"]){
        
        logoutButton.hidden=NO;
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"], @"token",@"googuu",@"from",
                                nil];
        [Utiles postNetInfoWithPath:@"UserInfo" andParams:params besidesBlock:^(id resObj){
           if(![[resObj objectForKey:@"status"] isEqualToString:@"0"]){
               id userInfo=[resObj objectForKey:@"data"];
               [userNameLabel setText:[userInfo objectForKey:@"nickname"]];
               [userIdLabel setText:[userInfo objectForKey:@"userid"]];
           }else{
               [Utiles ToastNotification:[resObj objectForKey:@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
           }
            
            
        }];
        
    }else{
        logoutButton.hidden=YES;
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"个人中心"];

    
    self.view.backgroundColor=[Utiles colorWithHexString:@"#19d2b2"];

    
    UIBarButtonItem *setting=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(setting:)];
    self.navigationItem.rightBarButtonItem=setting;
    
    logoutButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
    logoutButton.frame=CGRectMake(20,300,60,40);
    [logoutButton addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:logoutButton];
    
    userNameLabel=[[UILabel alloc] initWithFrame:CGRectMake(90,300,80,40)];
    userNameLabel.textAlignment=NSTextAlignmentCenter;
    userIdLabel=[[UILabel alloc] initWithFrame:CGRectMake(180,300,120,40)];
    userNameLabel.layer.cornerRadius = 6;
    userIdLabel.layer.cornerRadius=6;
    [self.view addSubview:userNameLabel];
    [self.view addSubview:userIdLabel];
    
    [setting release];
  
}



-(void)logout:(id)sender{
    
    NSString *token= [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"];
    if(token){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserToken"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                token, @"token",@"googuu",@"from",
                                nil];
        [Utiles postNetInfoWithPath:@"LogOut" andParams:params besidesBlock:^(id info){
           
            if([[info objectForKey:@"status"] isEqualToString:@"1"]){
                NSLog(@"logout success");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LogOut" object:nil];
                logoutButton.hidden=YES;
                userNameLabel.text=@"";
                userIdLabel.text=@"";
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserToken"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserInfo"];
            }else if([[info objectForKey:@"status"] isEqualToString:@"0"]){
                NSLog(@"logout failed:%@",[info objectForKey:@"msg"]);
            }
            
        }];
        
    }else{
        NSLog(@"logout failed");
    }
    

}


-(void)setting:(id)sender{
    
    SettingCenterViewController *setingViewController=[[SettingCenterViewController alloc] init];
    
    [self.navigationController pushViewController:setingViewController animated:YES];
    [setingViewController release];
    
}





-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        //NSLog(@"Reachable");
    }
    else
    {
        //NSLog(@"NReachable");
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(BOOL)shouldAutorotate{
    return NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


















@end

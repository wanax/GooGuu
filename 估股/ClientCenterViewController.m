//
//  ClientCenterViewController.m
//  UIDemo
//
//  Created by Xcode on 13-5-29.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "ClientCenterViewController.h"
#import "SettingCenterViewController.h"
#import "DBLite.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "UIButton+BGColor.h"




@interface ClientCenterViewController ()


@end

@implementation ClientCenterViewController

@synthesize userNameLabel;
@synthesize logoutBt;
@synthesize avatar;


@synthesize eventArr=_eventArr;
@synthesize dateDic=_dateDic;

- (void)dealloc
{
    SAFE_RELEASE(avatar);
    SAFE_RELEASE(logoutBt);
    SAFE_RELEASE(_dateDic);
    SAFE_RELEASE(_eventArr);
    SAFE_RELEASE(userNameLabel);
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
    
    if([Utiles isLogin]){
        
        logoutBt.hidden=NO;
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [Utiles getUserToken], @"token",@"googuu",@"from",
                                nil];
        [Utiles postNetInfoWithPath:@"UserInfo" andParams:params besidesBlock:^(id resObj){
           if(![[resObj objectForKey:@"status"] isEqualToString:@"0"]){
               id userInfo=[resObj objectForKey:@"data"];
               [userNameLabel setText:[userInfo objectForKey:@"nickname"]];
           }else{
               [Utiles ToastNotification:[resObj objectForKey:@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
           }
            
            
        }];
        
    }else{
        logoutBt.hidden=YES;
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"个人中心"];
    
    self.view.backgroundColor=[Utiles colorWithHexString:@"#F3EFE1"];
    [self.logoutBt setBackgroundColorString:@"#C96125" forState:UIControlStateNormal];
    
    avatar.layer.cornerRadius=5;
    avatar.layer.borderWidth=2;
    
    UIBarButtonItem *setting=[[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleBordered target:self action:@selector(setting:)];
    self.navigationItem.rightBarButtonItem=setting;
    
    
    [setting release];
  
}



-(void)logoutBtClick:(id)sender{
    
    NSString *token= [Utiles getUserToken];
    if(token){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserToken"];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                token, @"token",@"googuu",@"from",
                                nil];
        [Utiles postNetInfoWithPath:@"LogOut" andParams:params besidesBlock:^(id info){
           
            if([[info objectForKey:@"status"] isEqualToString:@"1"]){
                NSLog(@"logout success");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LogOut" object:nil];
                logoutBt.hidden=YES;
                userNameLabel.text=@"";
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

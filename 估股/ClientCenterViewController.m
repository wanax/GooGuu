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
        DBLite *tool=[[DBLite alloc] init];
        [tool userToken:[[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"] Todo:@"/m/userinfo" WithBlock:^(id resObj){
            id userInfo=[resObj objectForKey:@"data"];
            [userNameLabel setText:[userInfo objectForKey:@"nickname"]];
            [userIdLabel setText:[userInfo objectForKey:@"userid"]];
            
        }];
        [tool release];
        
    }else{
        logoutButton.hidden=YES;
    }
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"个人中心"];
    
    
    
    self.view.backgroundColor=[Utiles colorWithHexString:@"#7EEBE9"];
    
    VRGCalendarView *calendar = [[VRGCalendarView alloc] init];
    calendar.delegate=self;
    [self.view addSubview:calendar];
    
    UIBarButtonItem *setting=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(setting:)];
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
        DBLite *tool=[[DBLite alloc] init];
        [tool userToken:token Todo:@"/m/logout" WithBlock:^(id info){
            
            if([[info objectForKey:@"status"] isEqualToString:@"1"]){
                NSLog(@"logout success");
                logoutButton.hidden=YES;
                userNameLabel.text=@"";
                userIdLabel.text=@"";
            }else if([[info objectForKey:@"status"] isEqualToString:@"0"]){
                NSLog(@"logout failed");
            }
            
        }];
        [tool release];
        
    }else{
        NSLog(@"logout failed");
    }
    

}


-(void)setting:(id)sender{
    
    SettingCenterViewController *setingViewController=[[SettingCenterViewController alloc] init];
    
    [self.navigationController pushViewController:setingViewController animated:YES];
    [setingViewController release];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Calendar Delegate Methods

-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated {
    if (month==[[NSDate date] month]) {
       
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"], @"token",
                                @"2013",@"year",@"07",@"month",@"googuu",@"from",
                                nil];
        [Utiles postNetInfoWithPath:@"UserStockCalendar" andParams:params besidesBlock:^(id resObj){
           
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            NSMutableArray *dates=[[NSMutableArray alloc] init];
            self.eventArr=[resObj objectForKey:@"data"];
            for(id obj in self.eventArr){
                [dates addObject:[f numberFromString:[obj objectForKey:@"day"]]];
            }
            [calendarView markDates:dates];
            self.dateDic=[[NSMutableDictionary alloc] init];
            for(id key in self.eventArr){
                [self.dateDic setObject:[key objectForKey:@"data"] forKey:[key objectForKey:@"day"]];
            }
            [dates release];
            
        }];
        

    }
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date {

    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd"];
    NSString *currentDateStr = [dateFormat stringFromDate:date];
    
    if ([[self.dateDic allKeys] containsObject:currentDateStr]){
        NSString *msg=[[NSString alloc] init];
        for(id obj in [self.dateDic objectForKey:currentDateStr]){
            msg=[msg stringByAppendingFormat:@"%@:%@",[obj objectForKey:@"companyname"],[obj objectForKey:@"desc"]];
        }
        UIAlertView *tip=[[UIAlertView alloc] initWithTitle:@"今天事件" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [tip show];
        [tip release];
    }
    
    [dateFormat release];

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




















@end

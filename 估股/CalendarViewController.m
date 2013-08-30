//
//  CalendarViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-11.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "CalendarViewController.h"
#import "DBLite.h"
#import "MBProgressHUD.h"
#import "MHTabBarController.h"
#import "UILabel+VerticalAlign.h"

@interface CalendarViewController ()

@end

@implementation CalendarViewController

@synthesize eventArr=_eventArr;
@synthesize dateDic=_dateDic;
@synthesize dateIndicator;
@synthesize messageLabel;

- (void)dealloc
{
    SAFE_RELEASE(messageLabel);
    SAFE_RELEASE(dateIndicator);
    SAFE_RELEASE(_dateDic);
    SAFE_RELEASE(_eventArr);
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
    self.view.backgroundColor=[Utiles colorWithHexString:@"#EFEFEF"];
    VRGCalendarView *calendar = [[VRGCalendarView alloc] init];
    calendar.delegate=self;
    [self.view addSubview:calendar];
    calendar.userInteractionEnabled=YES;
    self.view.userInteractionEnabled=YES;
    
    dateIndicator=[[UILabel alloc] initWithFrame:CGRectMake(0,292,SCREEN_WIDTH,30)];
    dateIndicator.backgroundColor=[Utiles colorWithHexString:@"#7B140E"];
    dateIndicator.numberOfLines = 0;
    dateIndicator.font=[UIFont fontWithName:@"Heiti SC" size:13.0f];
    dateIndicator.textColor=[UIColor whiteColor];

    [self.view addSubview:dateIndicator];
    
    
    messageLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,322,SCREEN_WIDTH,120)];
    messageLabel.backgroundColor=[Utiles colorWithHexString:@"#892D24"];
    messageLabel.numberOfLines =5;
    messageLabel.font=[UIFont fontWithName:@"Heiti SC" size:13.0f];
    messageLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:messageLabel];
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    CGPoint change=[tap translationInView:self.view];
    if(change.x>100){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
    }
    if(tap.state==UIGestureRecognizerStateChanged){
        
        self.view.frame=CGRectMake(0,MAX(MIN(standard.y+change.y,0),-100),SCREEN_WIDTH,442);
        
    }else if(tap.state==UIGestureRecognizerStateEnded){
        standard=self.view.frame.origin;
    }
    
}


#pragma mark -
#pragma mark Calendar Delegate Methods

-(void)calendarView:(VRGCalendarView *)calendarView switchedToMonth:(int)month targetHeight:(float)targetHeight animated:(BOOL)animated {
    if (month==[[NSDate date] month]){
        id dateNow=[NSDate date];
        
        NSDictionary *params = @{@"token": [Utiles getUserToken],
                                @"year": [NSString stringWithFormat:@"%d",[dateNow year]],@"month": [NSString stringWithFormat:@"0%d",[dateNow month]],@"from": @"googuu"};
        [Utiles postNetInfoWithPath:@"UserStockCalendar" andParams:params besidesBlock:^(id resObj){
            if(![resObj[@"status"] isEqualToString:@"0"]){
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                NSMutableArray *dates=[[NSMutableArray alloc] init];
                self.eventArr=resObj[@"data"];
                for(id obj in self.eventArr){
                    [dates addObject:[f numberFromString:obj[@"day"]]];
                }
                [calendarView markDates:dates];
                self.dateDic=[[NSMutableDictionary alloc] init];
                for(id key in self.eventArr){
                    (self.dateDic)[key[@"day"]] = key[@"data"];
                }
                SAFE_RELEASE(dates);
                SAFE_RELEASE(f);
            }else{
                [Utiles ToastNotification:resObj[@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
            }
          
        }];
    }
}

-(void)calendarView:(VRGCalendarView *)calendarView dateSelected:(NSDate *)date {
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd"];
    NSString *currentDateStr = [dateFormat stringFromDate:date];
    [dateFormat setDateFormat:@"YYYY/MM/dd"];
    NSString *pointerDate=[NSString stringWithFormat:@"%@相关信息",[dateFormat stringFromDate:date]];
    dateIndicator.text=pointerDate;
    [self.messageLabel setText:@""];
    if ([[self.dateDic allKeys] containsObject:currentDateStr]){
        NSString *msg=[[NSString alloc] init];
        for(id obj in (self.dateDic)[currentDateStr]){
            msg=[msg stringByAppendingFormat:@"%@:%@\n",obj[@"companyname"],obj[@"desc"]];
        }
        [self.messageLabel setText:msg];
        [messageLabel alignTop];
        self.view.center=CGPointMake(SCREEN_WIDTH/2,70);
    }
   
    [dateFormat release];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


















@end

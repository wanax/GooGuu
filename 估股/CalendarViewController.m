//
//  CalendarViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-11.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "CalendarViewController.h"
#import "Utiles.h"
#import "DBLite.h"
#import "MBProgressHUD.h"
#import "MHTabBarController.h"

@interface CalendarViewController ()

@end

@implementation CalendarViewController

@synthesize eventArr=_eventArr;
@synthesize dateDic=_dateDic;

- (void)dealloc
{
    [_dateDic release];
    [_eventArr release];
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
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [calendar addGestureRecognizer:pan];
    [pan release];
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    CGPoint change=[tap translationInView:self.view];
    if(change.x>100){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
    }
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




















@end

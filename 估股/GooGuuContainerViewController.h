//
//  TestViewController.h
//  UIDemo
//
//  Created by Xcode on 13-7-10.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ConcernedViewController;
@class CalendarViewController;
@class MHTabBarController;

@interface GooGuuContainerViewController : UIViewController

@property (nonatomic,retain) ConcernedViewController *concernedViewController;
@property (nonatomic,retain) ConcernedViewController *saveModelViewControler;
@property (nonatomic,retain) CalendarViewController *calendarViewController;
@property (nonatomic,retain) MHTabBarController* tabBarController;

@end

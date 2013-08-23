//
//  XYZAppDelegate.h
//  welcom_demo_1
//
//  Created by chaoxiao zhuang on 13-1-10.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TSPopoverController.h"

@class ConcernedViewController;
@class Company;
@class PrettyTabBarViewController;

@interface XYZAppDelegate : NSObject <UIApplicationDelegate>{
    IBOutlet UIWindow *window;
    NSString *_stockCode;
}
@property (nonatomic,retain) TSPopoverController *popoverController;
@property (nonatomic,retain) UIScrollView *scrollView;
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,retain)  PrettyTabBarViewController *tabBarController;

@property (retain,nonatomic) UIPageControl * pageControl;
@property (nonatomic,strong) id comInfo;
@property (nonatomic,retain) NSTimer *loginTimer;














@end

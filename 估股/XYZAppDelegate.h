//
//  XYZAppDelegate.h
//  welcom_demo_1
//
//  Created by chaoxiao zhuang on 13-1-10.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ConcernedViewController;
@class Company;

@interface XYZAppDelegate : NSObject <UIApplicationDelegate>{
    IBOutlet UIWindow *window;
    NSString *_stockCode;
}

@property (nonatomic,retain) UIScrollView *scrollView;
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,retain)  UITabBarController *tabBarController;

@property (retain,nonatomic) UIPageControl * pageControl;
@property (nonatomic,retain) id comInfo;


@end

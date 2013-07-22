//
//  PRPSplashScreenDelegate.h
//  welcom_demo_1
//
//  Created by Xcode on 2013-05-08.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 开机动画

#import "PRPSplashScreen.h"
@class PRPSplashScreen;

@protocol PRPSplashScreenDelegate <NSObject>


@optional

-(void)splashScreenDidAppear:(PRPSplashScreen *)splashScreen;
-(void)splashScreenWillDisappear:(PRPSplashScreen *)splashScreen;
-(void)splashScreenDidDisappear:(PRPSplashScreen *)splashScreen;

@end

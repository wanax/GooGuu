//
//  PRPSplashScreen.h
//  welcom_demo_1
//
//  Created by Xcode on 2013-05-08.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 开机动画

#import <UIKit/UIKit.h>
#import "PRPSplashScreenDelegate.h"


@interface PRPSplashScreen : UIViewController<PRPSplashScreenDelegate>{}

@property (nonatomic,retain) UIImage *splashImage;
@property (nonatomic,assign) BOOL showsStatusBarOnDismissal;
@property (nonatomic,retain) IBOutlet id<PRPSplashScreenDelegate> delegate;

-(void)hide;

@end

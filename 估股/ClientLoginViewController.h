//
//  ClientLongViewController.h
//  UIDemo
//
//  Created by Xcode on 13-6-7.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  客户登录控制器

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class LoginView;

@interface ClientLoginViewController : UIViewController<UITextFieldDelegate>{
    BOOL isGoIn;
}

@property (nonatomic,retain) LoginView *loginView;


@end

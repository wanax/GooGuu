//
//  ClientCenterViewController.h
//  UIDemo
//
//  Created by Xcode on 13-5-29.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  用户中心

#import <UIKit/UIKit.h>
#import "VRGCalendarView.h"


@interface ClientCenterViewController : UIViewController<VRGCalendarViewDelegate>{
    
    NSMutableArray *_eventArr;
    NSMutableDictionary *_dateDic;
    
}

@property (nonatomic,retain) UIButton *logoutButton;
@property (nonatomic,retain) UILabel *userNameLabel;
@property (nonatomic,retain) UILabel *userIdLabel;

@property (nonatomic,retain) NSMutableArray *eventArr;
@property (nonatomic,retain) NSMutableDictionary *dateDic;

@end

//
//  CalendarViewController.h
//  UIDemo
//
//  Created by Xcode on 13-7-11.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VRGCalendarView.h"

@interface CalendarViewController : UIViewController<VRGCalendarViewDelegate>{
    
    NSMutableArray *_eventArr;
    NSMutableDictionary *_dateDic;
    CGPoint standard;
    
}

@property (nonatomic,retain) NSMutableArray *eventArr;
@property (nonatomic,retain) NSMutableDictionary *dateDic;
@property (nonatomic,retain) UILabel *dateIndicator;
@property (nonatomic,retain) UILabel *messageLabel;


@end

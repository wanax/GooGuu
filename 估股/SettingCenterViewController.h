//
//  SettingCenterViewController.h
//  UIDemo
//
//  Created by Xcode on 13-6-21.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  设置中心

#import <UIKit/UIKit.h>
#import "NimbusModels.h"

@class CustomTableView;
@class NIMutableTableViewModel;
@class NITableViewModel;
@class NIRadioGroup;


// This enumeration is used in the sub radio group mapping.
typedef enum {
    SubRadioOption1,
    SubRadioOption2,
    SubRadioOption3,
} SubRadioOptions;

@interface SettingCenterViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource,NIRadioGroupDelegate,UITextFieldDelegate>

@property (nonatomic,retain) UIToolbar *top;

@property (nonatomic, readwrite, retain) NITableViewModel* model;
@property (nonatomic, readwrite, retain) NITableViewActions* actions;

@property (nonatomic, readwrite, retain) NIRadioGroup* subRadioGroup;












@end

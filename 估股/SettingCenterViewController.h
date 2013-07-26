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

// This enumeration is used in the radio group mapping.
typedef enum {
    RadioOption1,
    RadioOption2,
    RadioOption3,
} RadioOptions;

// This enumeration is used in the sub radio group mapping.
typedef enum {
    SubRadioOption1,
    SubRadioOption2,
    SubRadioOption3,
} SubRadioOptions;

@interface SettingCenterViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource,NIRadioGroupDelegate,UITextFieldDelegate>

@property (nonatomic,retain) UIToolbar *top;

@property (nonatomic, readwrite, retain) NITableViewModel* model;

// A radio group object allows us to easily maintain radio group-style interactions in a table view.
@property (nonatomic, readwrite, retain) NIRadioGroup* radioGroup;

// Each radio group object maintains a specific set of table objects, so in order to have multiple
// radio groups you need to instantiate multiple radio group objects.
@property (nonatomic, readwrite, retain) NIRadioGroup* subRadioGroup;












@end

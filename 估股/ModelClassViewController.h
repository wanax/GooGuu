//
//  ModelClassViewController.h
//  估股
//
//  Created by Xcode on 13-8-1.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ModelClassViewController :UITableViewController

@property (nonatomic,retain) id jsonData;
@property (nonatomic,retain) NSArray *modelClass;
@property (nonatomic,retain) UITableView *customTable;

@end

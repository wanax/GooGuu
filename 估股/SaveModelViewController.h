//
//  SaveModelViewController.h
//  UIDemo
//
//  Created by Xcode on 13-6-18.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  用户保存公司列表

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@class CompanyFieldViewController;
@class ClientLoginViewController;
@class CustomTableView;

@interface SaveModelViewController : UINavigationController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>



@property (nonatomic,retain) ClientLoginViewController *loginViewController;
@property (nonatomic,retain) CustomTableView *customTableView;

@property (nonatomic,retain) CompanyFieldViewController *companyFieldViewController;


@property (nonatomic,retain) NSMutableArray *comInfoList;


@end

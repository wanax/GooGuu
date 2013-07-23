//
//  MyGooguuViewController.h
//  UIDemo
//
//  Created by Xcode on 13-6-13.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  用户关注公司列表

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EGORefreshTableHeaderView.h"

@class CompanyFieldViewController;
@class ClientLoginViewController;
@class CustomTableView;

@interface ConcernedViewController : UINavigationController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,EGORefreshTableHeaderDelegate>{
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;//主要是记录是否在刷新中
    __strong UIActivityIndicatorView *_activityIndicatorView;
}

@property (nonatomic,retain) NSString *type;
@property BOOL nibsRegistered;
@property (nonatomic,retain) ClientLoginViewController *loginViewController;
@property (nonatomic,retain) UITableView *customTableView;

@property (nonatomic,retain) CompanyFieldViewController *companyFieldViewController;


@property (nonatomic,retain) NSMutableArray *comInfoList;



















@end

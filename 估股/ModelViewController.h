//
//  ModelViewController.h
//  UIDemo
//
//  Created by Xcode on 13-5-8.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 股票详细页-股票模型

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@class ChartViewController;

@interface ModelViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate>{

    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;//主要是记录是否在刷新中
    __strong UIActivityIndicatorView *_activityIndicatorView;
    
}

@property BrowseSourceType browseType;
@property (nonatomic,retain) id savedStockList;

@property (nonatomic,retain) ChartViewController *chartViewController;
@property (nonatomic,retain) UITableView *savedTable;

@end

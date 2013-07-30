//
//  GooNewsViewController.h
//  UIDemo
//
//  Created by Xcode on 13-6-14.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  估股新闻栏目

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@class CustomTableView;
@class MBProgressHUD;

@interface GooNewsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,EGORefreshTableHeaderDelegate>{
    
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;//主要是记录是否在刷新中
    
    __strong UIActivityIndicatorView *_activityIndicatorView;
    
}

@property (nonatomic,retain) CustomTableView *customTableView;

@property (nonatomic,retain) NSMutableArray *newArrList;
@property (nonatomic,retain) NSString *imageUrl;
@property (nonatomic,retain) id companyInfo;

@property (nonatomic,retain) NSDictionary *readingMarksDic;

@property (nonatomic,retain) MBProgressHUD *hud;

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end

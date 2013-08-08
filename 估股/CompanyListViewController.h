//
//  CompanyListViewController.h
//  welcom_demo_1
//
//  股票添加列表
//
//  Created by Xcode on 13-5-9.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-09 | Wanax | 股票添加列表
//  2013-08-05 | Wanax | 估值模型页面

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

@class ComFieldViewController;

typedef enum {
    
    HK=1,//港股
    NYSE=2,//纽交所
    SZSE=4,//深圳
    SHSE=8,//上海
    SHSZSE=12,//沪深
    NASDAQ=16,//纳斯达克
    NANY=18,//美股
    ALL=31
    
} MarketType;

@interface CompanyListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate>{
    BOOL _isShowSearchBar;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;//主要是记录是否在刷新中
    
    __strong UIActivityIndicatorView *_activityIndicatorView;

}
@property MarketType type;
@property BOOL nibsRegistered;
@property (nonatomic,retain) NSString *comType;
@property (nonatomic,retain) UIImage *rowImage;

@property (nonatomic, retain) UITableView *table;
@property (nonatomic, retain) UISearchBar *search;

@property (nonatomic,retain) NSMutableArray *comList;
@property (nonatomic) BOOL isShowSearchBar;

@property (nonatomic,retain) NSMutableArray *concernStocksCodeArr;
@property (nonatomic,retain) ComFieldViewController *com;

- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;




@end

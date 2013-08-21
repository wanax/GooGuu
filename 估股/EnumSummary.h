//
//  EnumSummary.h
//  googuu
//
//  Created by Xcode on 13-8-15.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EnumSummary : NSObject

//评论类型，此页面三种评论公用
typedef enum {
    
    CompanyType,//关于股票公司的评论
    NewsType,//估股新闻中分析报告的评论
    ArticleType//股票公司中分析报告的评论
    
} CommentType;

//浏览来源，当从保存列表进入时加载保存数据 ChartViewController
typedef enum {
    ValuationModelType,
    MyConcernedType,
    MySavedType,
    ModelViewType,
    ChartviewType,
    DragableChart,
    FinancalModelChart
} BrowseSourceType;

//股票市场 CompanyListViewController
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

//拖动图表按钮动作定义
typedef enum{
    SaveData=1,
    DragChartType=2,
    ResetChart=3,
    BackToSuperView=4
} ChartBtAction;

typedef enum{
    MainIncome=11,
    OperaFee=22,
    OperaCap=33,
    DiscountRate=44
} IndustoryModelType;








@end

//
//  Chart3ViewController.h
//  Chart1.3
//
//  Created by Xcode on 13-4-15.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <math.h>
#import "CorePlot-CocoaTouch.h"


//数据点个数
#define NUM 10

//绘图空间与绘图view底部距离
#define GRAPAHBOTTOMPAD 0.0f
//绘图空间与绘图view顶部的距离
#define GRAPAHTOPPAD 0.0f
//绘图view与self.view顶部距离
#define HOSTVIEWTOPPAD 40.0f
//绘图view与self.view底部距离
#define HOSTVIEWBOTTOMPAD 90.0f


//x轴起点
#define XRANGEBEGIN 9.0
//x轴在屏幕可视范围内的范围
#define XRANGELENGTH 14.0
//y轴起点
#define YRANGEBEGIN -0.3
//y轴在屏幕可视范围内的范围
#define YRANGELENGTH 0.9


//x轴屏幕范围内大坐标间距
#define XINTERVALLENGTH 3.0
//x轴坐标的原点（x轴在y轴上的坐标）
#define XORTHOGONALCOORDINATE -0.1
//x轴每两个大坐标间小坐标个数
#define XTICKSPERINTERVAL 2

#define YINTERVALLENGTH 0.1
#define YORTHOGONALCOORDINATE 11.0
#define YTICKSPERINTERVAL 2

#define FINGERCHANGEDISTANCE 100.0


@interface ChartViewController : UIViewController<CPTPieChartDataSource,UIWebViewDelegate>{
    CPTXYGraph * graph ;
    //可调整当前数据线
    NSMutableArray *_forecastPoints;
    //默认置灰当前可调整数据线，做调整后数据对比使用
    NSMutableArray *_forecastDefaultPoints;
    //不可调整历史数据线
    NSMutableArray *_hisPoints;
    //分割线
    NSMutableArray *_dividingPoints;
    //网络获取图表所需数据
    NSString *_jsonForChart;
    //股票种类
    NSArray *_industryClass;
    
    NSMutableArray *_standard;
    
}
//预测曲线
@property (nonatomic,retain) NSMutableArray *forecastPoints;
//预测默认曲线
@property (nonatomic,retain) NSMutableArray *forecastDefaultPoints;
//历史曲线
@property (nonatomic,retain) NSMutableArray *hisPoints;
//分割线
@property (nonatomic,retain) NSMutableArray *dividingPoints;
//网络获取数据
@property (nonatomic,retain) NSString *jsonForChart;
@property (nonatomic,retain) NSMutableArray *standard;

@property (nonatomic,retain) CPTScatterPlot * forecastLinePlot;
@property (nonatomic,retain) CPTScatterPlot * forecastDefaultLinePlot;
@property (nonatomic,retain) CPTScatterPlot * historyLinePlot;
@property (nonatomic,retain) CPTScatterPlot * dividingLinePlot;
@property (nonatomic,retain) CPTBarPlot *barPlot;
//是否联动
@property (nonatomic) BOOL linkage;

//行业分类
@property (nonatomic,retain) NSArray *industryClass;

@property (nonatomic,retain) UIWebView *webView;
@property (nonatomic,retain) UILabel *priceLabel;

//转换坐标系字典，与手指触摸点匹配
@property (nonatomic,retain) NSMutableDictionary *reverseDic;
//js引擎上下文
//@property (nonatomic) JSGlobalContextRef context;
//绘图view
@property (nonatomic,retain) CPTGraphHostingView *hostView;

//坐标转换方法，实际坐标转化相对坐标
- (CGPoint)CoordinateTransformRealToAbstract:(CGPoint)point;
//坐标转换方法，相对坐标转化实际坐标
- (CGPoint)CoordinateTransformAbstractToReal:(CGPoint)point;
//判断手指触摸点是否在折点旁边
-(BOOL)isNearByThePoint:(CGPoint)p;

//js代码运行
- (NSString *)runsJS:(NSString *)aJSString;


@end

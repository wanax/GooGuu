//
//  FinancalModelChartViewController.h
//  估股
//
//  Created by Xcode on 13-8-1.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <math.h>
#import "CorePlot-CocoaTouch.h"
#import "DrawChartTool.h"

@class CQMFloatingController;

//数据点个数
#define NUM 10

//绘图空间与绘图view底部距离
#define GRAPAHBOTTOMPAD 0.0f
//绘图空间与绘图view顶部的距离
#define GRAPAHTOPPAD 0.0f
//绘图view与self.view顶部距离
#define HOSTVIEWTOPPAD 0.0f
//绘图view与self.view底部距离
#define HOSTVIEWBOTTOMPAD 0.0f

#define DrawXYAxis [DrawChartTool drawXYAxisIn:graph toPlot:plotSpace withXRANGEBEGIN:XRANGEBEGIN XRANGELENGTH:XRANGELENGTH YRANGEBEGIN:YRANGEBEGIN YRANGELENGTH:YRANGELENGTH XINTERVALLENGTH:XINTERVALLENGTH XORTHOGONALCOORDINATE:XORTHOGONALCOORDINATE XTICKSPERINTERVAL:XTICKSPERINTERVAL YINTERVALLENGTH:YINTERVALLENGTH YORTHOGONALCOORDINATE:YORTHOGONALCOORDINATE YTICKSPERINTERVAL:YTICKSPERINTERVAL]

@interface FinancalModelChartViewController : UIViewController<CPTPieChartDataSource,UIWebViewDelegate>{
    //x轴起点
    float XRANGEBEGIN;
    //x轴在屏幕可视范围内的范围
    float XRANGELENGTH;
    //y轴起点
    float YRANGEBEGIN;
    //y轴在屏幕可视范围内的范围
    float YRANGELENGTH;
    
    //x轴屏幕范围内大坐标间距
    float XINTERVALLENGTH;
    //x轴坐标的原点（x轴在y轴上的坐标）
    float XORTHOGONALCOORDINATE;
    //x轴每两个大坐标间小坐标个数
    float XTICKSPERINTERVAL;
    
    float YINTERVALLENGTH;
    float YORTHOGONALCOORDINATE;
    float YTICKSPERINTERVAL;
   
}

@property (nonatomic,retain) UIButton *button;
@property (nonatomic,retain) NSMutableArray *points;
@property (nonatomic,retain) NSString *jsonForChart;

@property (nonatomic,retain) CPTBarPlot *barPlot;

@property (nonatomic,retain) UIWebView *webView;

@property (nonatomic,retain) CPTXYGraph * graph ;
@property (nonatomic,retain) CPTGraphHostingView *hostView;
@property (nonatomic,retain) CPTXYPlotSpace *plotSpace;














@end

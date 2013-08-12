//
//  DahonValuationViewController.h
//  估股
//
//  Created by Xcode on 13-8-8.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <math.h>
#import "CorePlot-CocoaTouch.h"
#import "DrawChartTool.h"

#define DrawXYAxis [DrawChartTool drawXYAxisIn:graph toPlot:plotSpace withXRANGEBEGIN:XRANGEBEGIN XRANGELENGTH:XRANGELENGTH YRANGEBEGIN:YRANGEBEGIN YRANGELENGTH:YRANGELENGTH XINTERVALLENGTH:XINTERVALLENGTH XORTHOGONALCOORDINATE:XORTHOGONALCOORDINATE XTICKSPERINTERVAL:XTICKSPERINTERVAL YINTERVALLENGTH:YINTERVALLENGTH YORTHOGONALCOORDINATE:YORTHOGONALCOORDINATE YTICKSPERINTERVAL:YTICKSPERINTERVAL to:self isY:YES]

@interface DahonValuationViewController : UIViewController<CPTScatterPlotDataSource,CPTScatterPlotDelegate,CPTAxisDelegate>{
    //x轴起点
    long XRANGEBEGIN;
    //x轴在屏幕可视范围内的范围
    long XRANGELENGTH;
    //y轴起点
    double YRANGEBEGIN;
    //y轴在屏幕可视范围内的范围
    double YRANGELENGTH;
    
    //x轴屏幕范围内大坐标间距
    long XINTERVALLENGTH;
    //x轴坐标的原点（x轴在y轴上的坐标）
    double XORTHOGONALCOORDINATE;
    //x轴每两个大坐标间小坐标个数
    long XTICKSPERINTERVAL;
    
    double YINTERVALLENGTH;
    double YORTHOGONALCOORDINATE;
    double YTICKSPERINTERVAL;
    
    
    CPTXYGraph * graph ;
}

@property (nonatomic,retain) id jsonData;
@property (nonatomic,retain) id dateArr;
@property (nonatomic,retain) id chartData;

@property (nonatomic,retain) CPTScatterPlot * daHonLinePlot;

//绘图view
@property (nonatomic,retain) CPTXYGraph * graph ;
@property (nonatomic,retain) CPTGraphHostingView *hostView;
@property (nonatomic,retain) CPTXYPlotSpace *plotSpace;











@end

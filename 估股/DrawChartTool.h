//
//  DrawChartTool.h
//  估股
//
//  Created by Xcode on 13-8-1.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface DrawChartTool : NSObject

@property (nonatomic,retain) id standIn;

//添加绘图上方功能按钮
-(UIButton *)addButtonToView:(UIView *)view withTitle:(NSString *)title Tag:(NSInteger)tag frame:(CGRect)rect andFun:(SEL)fun;
//从新数据中提取xy轴中的坐标数据，长度，起始点，间隔点等
+(NSDictionary *)getXYAxisRangeFromxArr:(NSArray *)xArr andyArr:(NSArray *)yArr ToWhere:(BOOL)isDrag;
//通过基本坐标数据绘制xy坐标
+(void)drawXYAxisIn:(CPTXYGraph *)graph toPlot:(CPTXYPlotSpace *)plotSpace withXRANGEBEGIN:(float)XRANGEBEGIN XRANGELENGTH:(float)XRANGELENGTH  YRANGEBEGIN:(float)YRANGEBEGIN YRANGELENGTH:(float)YRANGELENGTH XINTERVALLENGTH:(float)XINTERVALLENGTH XORTHOGONALCOORDINATE:(float)XORTHOGONALCOORDINATE XTICKSPERINTERVAL:(float)XTICKSPERINTERVAL YINTERVALLENGTH:(float)YINTERVALLENGTH YORTHOGONALCOORDINATE:(float)YORTHOGONALCOORDINATE YTICKSPERINTERVAL:(float)YTICKSPERINTERVAL;













@end

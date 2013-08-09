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

typedef enum {
    
    FinancalModel,//金融模型
    DragabelModel,//可调整参数模型
    DahonModel//大行数据
    
} ChartType;

@property (nonatomic,retain) id standIn;

-(UILabel *)addLabelToView:(UIView *)view withTile:(NSString *)title Tag:(NSInteger)tag frame:(CGRect)rect fontSize:(float)size;
//添加绘图上方功能按钮
-(UIButton *)addButtonToView:(UIView *)view withTitle:(NSString *)title Tag:(NSInteger)tag frame:(CGRect)rect andFun:(SEL)fun;
//从新数据中提取xy轴中的坐标数据，长度，起始点，间隔点等
+(NSDictionary *)getXYAxisRangeFromxArr:(NSArray *)xArr andyArr:(NSArray *)yArr fromWhere:(ChartType)tag;

//通过基本坐标数据绘制xy坐标
+(void)drawXYAxisIn:(CPTXYGraph *)graph toPlot:(CPTXYPlotSpace *)plotSpace withXRANGEBEGIN:(long)XRANGEBEGIN XRANGELENGTH:(long)XRANGELENGTH  YRANGEBEGIN:(double)YRANGEBEGIN YRANGELENGTH:(double)YRANGELENGTH XINTERVALLENGTH:(long)XINTERVALLENGTH XORTHOGONALCOORDINATE:(long)XORTHOGONALCOORDINATE XTICKSPERINTERVAL:(long)XTICKSPERINTERVAL YINTERVALLENGTH:(double)YINTERVALLENGTH YORTHOGONALCOORDINATE:(double)YORTHOGONALCOORDINATE YTICKSPERINTERVAL:(double)YTICKSPERINTERVAL to:(id)delegate  isY:(BOOL)isY;













@end

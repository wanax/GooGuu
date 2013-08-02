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

-(UIButton *)addButtonToView:(UIView *)view withTitle:(NSString *)title frame:(CGRect)rect andFun:(SEL)fun;


+(void)drawXYAxisIn:(CPTXYGraph *)graph toPlot:(CPTXYPlotSpace *)plotSpace withXRANGEBEGIN:(float)XRANGEBEGIN XRANGELENGTH:(float)XRANGELENGTH  YRANGEBEGIN:(float)YRANGEBEGIN YRANGELENGTH:(float)YRANGELENGTH XINTERVALLENGTH:(float)XINTERVALLENGTH XORTHOGONALCOORDINATE:(float)XORTHOGONALCOORDINATE XTICKSPERINTERVAL:(float)XTICKSPERINTERVAL YINTERVALLENGTH:(float)YINTERVALLENGTH YORTHOGONALCOORDINATE:(float)YORTHOGONALCOORDINATE YTICKSPERINTERVAL:(float)YTICKSPERINTERVAL;
@end

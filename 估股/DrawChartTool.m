//
//  DrawChartTool.m
//  估股
//
//  Created by Xcode on 13-8-1.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "DrawChartTool.h"
#import "Utiles.h"

@implementation DrawChartTool

@synthesize standIn;

- (void)dealloc
{
    [standIn release];
    [super dealloc];
}

-(UIButton *)addButtonToView:(UIView *)view withTitle:(NSString *)title frame:(CGRect)rect andFun:(SEL)fun{
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=rect;
    [button setTitle:title forState:UIControlStateNormal];
    button.backgroundColor=[Utiles colorWithHexString:@"#323232"];
    button.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    [button addTarget:standIn action:fun forControlEvents:UIControlEventTouchDown];
    [view addSubview:button];
    return button;
    
}

+(NSDictionary *)getXYAxisRangeFromxArr:(NSArray *)xArr andyArr:(NSArray *)yArr{
    
    NSComparator cmptr = ^(id obj1, id obj2){
        if ([obj1 floatValue] > [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 floatValue] < [obj2 floatValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    NSArray *sortXArr=[xArr sortedArrayUsingComparator:cmptr];
    NSArray *sortYArr=[yArr sortedArrayUsingComparator:cmptr];
    
    float xMax=[[sortXArr lastObject] floatValue];
    float xMin=[[sortXArr objectAtIndex:0] floatValue];
    float xTap=(xMax-xMin)/[sortXArr count];
    float yMax=[[sortYArr lastObject] floatValue];
    float yMin=[[sortYArr objectAtIndex:0] floatValue];
    float yTap=(yMax-yMin)/[sortYArr count];
    
    float xLowBound=xMin-xTap;
    float xUpBound=xMax+xTap;
    float yLowBound=yMin-yTap;
    float yUpBound=yMax+yTap;
    
    float xBegin=xLowBound;
    float xLength=xUpBound-xLowBound;
    
    float yBegin=yLowBound;
    float yLength=yUpBound-yLowBound;
    
    float xInterval=xLength/6;
    float xOrigin=yMin;
    
    float yInterval=yLength/8;
    float yOrigin=xLength/7+xBegin;
   
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithFloat:xBegin],@"xBegin",
            [NSNumber numberWithFloat:xLength],@"xLength",
            [NSNumber numberWithFloat:xInterval],@"xInterval",
            [NSNumber numberWithFloat:xOrigin],@"xOrigin",
            [NSNumber numberWithFloat:yBegin],@"yBegin",
            [NSNumber numberWithFloat:yLength],@"yLength",
            [NSNumber numberWithFloat:yInterval],@"yInterval",
            [NSNumber numberWithFloat:yOrigin],@"yOrigin",
            nil];
    
}

+(void)drawXYAxisIn:(CPTXYGraph *)graph toPlot:(CPTXYPlotSpace *)plotSpace withXRANGEBEGIN:(float)XRANGEBEGIN XRANGELENGTH:(float)XRANGELENGTH YRANGEBEGIN:(float)YRANGEBEGIN YRANGELENGTH:(float)YRANGELENGTH XINTERVALLENGTH:(float)XINTERVALLENGTH XORTHOGONALCOORDINATE:(float)XORTHOGONALCOORDINATE XTICKSPERINTERVAL:(float)XTICKSPERINTERVAL YINTERVALLENGTH:(float)YINTERVALLENGTH YORTHOGONALCOORDINATE:(float)YORTHOGONALCOORDINATE YTICKSPERINTERVAL:(float)YTICKSPERINTERVAL{
    
    CPTMutableTextStyle *textStyle = [CPTTextStyle textStyle];
    textStyle.color                   = [CPTColor grayColor];
    textStyle.fontSize                = 16.0f;
    textStyle.textAlignment           = CPTTextAlignmentCenter;
    graph.titleTextStyle           = textStyle;
    graph.titleDisplacement        = CGPointMake(0.0f, -20.0f);
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    /*NSLog(@"\nXRANGEBEGIN%f\nXRANGELENGTH%f\nXORTHOGONALCOORDINATE%f\nXTICKSPERINTERVAL%f\nYRANGEBEGIN%f\nYRANGELENGTH%f\nYORTHOGONALCOORDINATE%f\nYTICKSPERINTERVAL%f\n",XRANGEBEGIN,XRANGELENGTH,XORTHOGONALCOORDINATE,XTICKSPERINTERVAL,YRANGEBEGIN,YRANGELENGTH,YORTHOGONALCOORDINATE,YINTERVALLENGTH);*/
    
    //设置x，y坐标范围
    plotSpace.xRange=[CPTPlotRange plotRangeWithLocation:
                      CPTDecimalFromCGFloat(XRANGEBEGIN)
                                                  length:CPTDecimalFromCGFloat(XRANGELENGTH)];
    plotSpace.yRange=[CPTPlotRange plotRangeWithLocation:
                      CPTDecimalFromCGFloat(YRANGEBEGIN)  length:CPTDecimalFromCGFloat(YRANGELENGTH)];
    
    //绘制坐标系
    CPTXYAxisSet *axisSet=(CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x=axisSet.xAxis;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor colorWithComponentRed:30/255.0 green:211/255.0 blue:155/255.0 alpha:1.0];
    
    x.majorIntervalLength=CPTDecimalFromFloat(XINTERVALLENGTH);
    x.orthogonalCoordinateDecimal=CPTDecimalFromFloat(XORTHOGONALCOORDINATE);
    x.minorTicksPerInterval=XTICKSPERINTERVAL;
    x.minorTickLineStyle = lineStyle;
    
    CPTXYAxis *y=axisSet.yAxis;
    y.majorIntervalLength=CPTDecimalFromFloat(YINTERVALLENGTH);
    y.orthogonalCoordinateDecimal=CPTDecimalFromFloat(YORTHOGONALCOORDINATE);
    y.minorTicksPerInterval=YTICKSPERINTERVAL;
    y.minorTickLineStyle = lineStyle;
    
}


















@end

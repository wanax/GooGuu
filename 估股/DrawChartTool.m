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

-(UIButton *)addButtonToView:(UIView *)view withTitle:(NSString *)title Tag:(NSInteger)tag frame:(CGRect)rect andFun:(SEL)fun{
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=rect;
    [button setTitle:title forState:UIControlStateNormal];
    button.tag=tag;
    button.backgroundColor=[Utiles colorWithHexString:@"#323232"];
    button.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    [button addTarget:standIn action:fun forControlEvents:UIControlEventTouchDown];
    [view addSubview:button];
    return button;
    
}

+(NSDictionary *)getXYAxisRangeFromxArr:(NSArray *)xArr andyArr:(NSArray *)yArr ToWhere:(BOOL)isDrag{
    
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
    
    NSInteger xMax=[[sortXArr lastObject] integerValue];
    NSInteger xMin=[[sortXArr objectAtIndex:0] integerValue];
    NSInteger xTap=1;
    float yMax=[[sortYArr lastObject] floatValue];
    float yMin=[[sortYArr objectAtIndex:0] floatValue];
    float yTap=(yMax-yMin)/[sortYArr count];
    
    float xLowBound=xMin-2;
    float xUpBound=xMax+xTap;
    float yLowBound=0.0f;
    //不可拖动柱状图y轴应从0起
    if(isDrag){
        yLowBound=yMin-2*yTap;
    }else{
        yLowBound=0-2.5*yTap;
    }
    
    float yUpBound=yMax+3*yTap;
    
    float xBegin=xLowBound;
    float xLength=xUpBound-xLowBound;
    
    float yBegin=yLowBound;
    float yLength=yUpBound-yLowBound;
    
    float xInterval=1;
    float xOrigin=yLowBound+2.5*yTap;
    
    float yInterval=0;
    float yOrigin=xBegin+2;
   
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

+(void)drawXYAxisIn:(CPTXYGraph *)graph toPlot:(CPTXYPlotSpace *)plotSpace withXRANGEBEGIN:(float)XRANGEBEGIN XRANGELENGTH:(float)XRANGELENGTH YRANGEBEGIN:(float)YRANGEBEGIN YRANGELENGTH:(float)YRANGELENGTH XINTERVALLENGTH:(float)XINTERVALLENGTH XORTHOGONALCOORDINATE:(float)XORTHOGONALCOORDINATE XTICKSPERINTERVAL:(float)XTICKSPERINTERVAL YINTERVALLENGTH:(float)YINTERVALLENGTH YORTHOGONALCOORDINATE:(float)YORTHOGONALCOORDINATE YTICKSPERINTERVAL:(float)YTICKSPERINTERVAL to:(id)delegate isY:(BOOL)isY{
    
    CPTMutableTextStyle *textStyle = [CPTTextStyle textStyle];
    textStyle.color                   = [CPTColor grayColor];
    textStyle.fontSize                = 14.0f;
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
    lineStyle.miterLimit = 50.0f;
    lineStyle.lineWidth = 1.5;
    lineStyle.lineColor = [CPTColor colorWithComponentRed:20/255.0 green:46/255.0 blue:108/255.0 alpha:1.0];
    
    x.majorIntervalLength=CPTDecimalFromFloat(XINTERVALLENGTH);
    x.orthogonalCoordinateDecimal=CPTDecimalFromFloat(XORTHOGONALCOORDINATE);
    x.minorTicksPerInterval=XTICKSPERINTERVAL;
    x.minorTickLineStyle = lineStyle;
    x.majorTickLineStyle=lineStyle;
    //x.axisTitle=[[CPTAxisTitle alloc] initWithText:@"here" textStyle:[CPTTextStyle textStyle]];
    x.axisLineStyle=lineStyle;
    x.delegate=delegate;
    
    lineStyle.lineColor = [CPTColor colorWithComponentRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0];
    lineStyle.lineWidth = 1.0;
    if(!isY){
        lineStyle.lineWidth=0.0;
    }
    CPTXYAxis *y=axisSet.yAxis;
    y.majorIntervalLength=CPTDecimalFromFloat(YINTERVALLENGTH);
    y.orthogonalCoordinateDecimal=CPTDecimalFromFloat(YORTHOGONALCOORDINATE);
    y.minorTicksPerInterval=YTICKSPERINTERVAL;
    y.minorTickLineStyle = lineStyle;
    y.axisLineStyle=lineStyle;
    y.delegate=delegate;
    
}


















@end

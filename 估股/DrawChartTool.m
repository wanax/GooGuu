//
//  DrawChartTool.m
//  估股
//
//  Created by Xcode on 13-8-1.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "DrawChartTool.h"
#import "UIButton+BGColor.h"

@implementation DrawChartTool

@synthesize standIn;

- (void)dealloc
{
    [standIn release];standIn=nil;
    [super dealloc];
}

-(UILabel *)addLabelToView:(UIView *)view withTitle:(NSString *)title Tag:(NSInteger)tag frame:(CGRect)rect fontSize:(float)size color:(NSString *)color textColor:(NSString *)txtColor location:(NSTextAlignment)location{
    
    UILabel *label=[[UILabel alloc] initWithFrame:rect];
    [label setText:title];
    [label setTextColor:[Utiles colorWithHexString:txtColor]];
    [label setTextAlignment:location];
    [label setFont:[UIFont fontWithName:@"Heiti SC" size:size]];
    label.tag=tag;
    label.backgroundColor=[Utiles colorWithHexString:color];
    //[[label layer] setBorderColor:[[UIColor blackColor] CGColor]];
    //[[label layer] setBorderWidth:1.0];
    [view addSubview:label];
    return [label autorelease];
    
}

-(CGSize)getLabelSizeFromString:(NSString *)str font:(NSString *)font fontSize:(float)fontSize{
    CGSize size = CGSizeMake(320,2000);
    return [str sizeWithFont:[UIFont fontWithName:font size:fontSize] constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
}

-(UIButton *)addButtonToView:(UIView *)view withTitle:(NSString *)title Tag:(NSInteger)tag frame:(CGRect)rect andFun:(SEL)fun withType:(UIButtonType)buttonType andColor:(NSString *)color textColor:(NSString *)txtColor{
    
    UIButton *button=[UIButton buttonWithType:buttonType];
    button.frame=rect;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[Utiles colorWithHexString:txtColor] forState:UIControlStateNormal];
    //[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    button.tag=tag;
    if(color){
        if (buttonType==UIButtonTypeCustom) {
            [button setBackgroundColor:[Utiles colorWithHexString:color]];
        }else if(buttonType==UIButtonTypeRoundedRect){
            [button setBackgroundColorString:color forState:UIControlStateNormal];
        }
    }else{
        [button setBackgroundColor:[UIColor clearColor]];
    }
  
    button.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:12.0f];
    [button addTarget:standIn action:fun forControlEvents:UIControlEventTouchDown];
    [view addSubview:button];
    return button;
    
}
NSComparator cmptr = ^(id obj1, id obj2){
    if ([obj1 floatValue] > [obj2 floatValue]) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if ([obj1 floatValue] < [obj2 floatValue]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};
+(NSDictionary *)getMaxMinMidFromArr:(NSArray *)arr{
    NSArray *sortArr=[arr sortedArrayUsingComparator:cmptr];
    double max=[[sortArr lastObject] doubleValue];
    double min=[[sortArr objectAtIndex:0] doubleValue];
    double mid=(max+min)/2;
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:max],@"max",[NSNumber numberWithDouble:min],@"min",[NSNumber numberWithDouble:mid],@"mid", nil];
    return dic;
}

+(NSDictionary *)getXYAxisRangeFromxArr:(NSArray *)xArr andyArr:(NSArray *)yArr fromWhere:(ChartType)tag{
   
    NSArray *sortXArr=[xArr sortedArrayUsingComparator:cmptr];
    NSArray *sortYArr=[yArr sortedArrayUsingComparator:cmptr];

    NSInteger xMax=[[sortXArr lastObject] integerValue];
    NSInteger xMin=[[sortXArr objectAtIndex:0] integerValue];
    //NSInteger xTap=1;
    double yMax=[[sortYArr lastObject] doubleValue];
    double yMin=[[sortYArr objectAtIndex:0] doubleValue];
    double yTap=0.0;
    if(tag==DahonModel){
       yTap=(yMax-yMin);
    }else{
       yTap=(yMax-yMin)/[sortYArr count]; 
    }
    
    long xLowBound=xMin-1;
    long xUpBound=xMax+1;
  
    double yLowBound=0.0;
    if(yMin>0){
        if(tag==DahonModel){
            yLowBound=yMin-0.2*(yMax-yMin);
        }else if(tag==DragabelModel){
            yLowBound=0-6*yTap;
        }else
            yLowBound=0-4*yTap;
    }else{
        if(tag==DahonModel){
            yLowBound=yMin-0.2*(yMax-yMin);
        }else if(tag==DragabelModel){
           yLowBound=yMin-6*yTap;
        }else
            yLowBound=yMin-4*yTap;
    }
    double yUpBound=0.0;
    if(tag==DahonModel){
        yUpBound=yMax+0.2*yTap;
    }else 
        yUpBound=yMax+4*yTap;
    
    long xBegin=xLowBound;
    long xLength=xUpBound-xLowBound;
    
    double yBegin=yLowBound;
    double yLength=yUpBound-yLowBound;
    
    long xInterval=1;
    double xOrigin=0.0f;
 
    double yInterval=0;
    double yOrigin=xBegin+2;
    
    if(tag==DahonModel){
        xOrigin=yMin;
        yInterval=0.5*yTap;
        yOrigin=xBegin;
    }
   
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithLong:xBegin],@"xBegin",
            [NSNumber numberWithLong:xLength],@"xLength",
            [NSNumber numberWithLong:xInterval],@"xInterval",
            [NSNumber numberWithDouble:xOrigin],@"xOrigin",
            [NSNumber numberWithDouble:yBegin],@"yBegin",
            [NSNumber numberWithDouble:yLength],@"yLength",
            [NSNumber numberWithDouble:yInterval],@"yInterval",
            [NSNumber numberWithDouble:yOrigin],@"yOrigin",
            nil];
    
}

+(void)drawXYAxisIn:(CPTXYGraph *)graph toPlot:(CPTXYPlotSpace *)plotSpace withXRANGEBEGIN:(long)XRANGEBEGIN XRANGELENGTH:(long)XRANGELENGTH YRANGEBEGIN:(double)YRANGEBEGIN YRANGELENGTH:(double)YRANGELENGTH XINTERVALLENGTH:(long)XINTERVALLENGTH XORTHOGONALCOORDINATE:(double)XORTHOGONALCOORDINATE XTICKSPERINTERVAL:(long)XTICKSPERINTERVAL YINTERVALLENGTH:(double)YINTERVALLENGTH YORTHOGONALCOORDINATE:(double)YORTHOGONALCOORDINATE YTICKSPERINTERVAL:(double)YTICKSPERINTERVAL to:(id)delegate isY:(BOOL)isY isX:(BOOL)isX{

    CPTMutableTextStyle *textStyle = [CPTTextStyle textStyle];
    textStyle.color                   = [CPTColor grayColor];
    textStyle.fontSize                = 14.0f;
    textStyle.textAlignment           = CPTTextAlignmentCenter;
    graph.titleTextStyle           = textStyle;
    graph.titleDisplacement        = CGPointMake(0.0f, -20.0f);
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    /*NSLog(@"\nXRANGEBEGIN%f\nXRANGELENGTH%f\nXORTHOGONALCOORDINATE%f\nXTICKSPERINTERVAL%f\nYRANGEBEGIN%f\nYRANGELENGTH%f\nYORTHOGONALCOORDINATE%f\nYTICKSPERINTERVAL%f\n",XRANGEBEGIN,XRANGELENGTH,XORTHOGONALCOORDINATE,XTICKSPERINTERVAL,YRANGEBEGIN,YRANGELENGTH,YORTHOGONALCOORDINATE,YINTERVALLENGTH);*/
    
    //设置x，y坐标范围
    plotSpace.xRange=[CPTPlotRange plotRangeWithLocation:CPTDecimalFromLong(XRANGEBEGIN)
                                                  length:CPTDecimalFromLong(XRANGELENGTH)];
    plotSpace.yRange=[CPTPlotRange plotRangeWithLocation:
                      CPTDecimalFromCGFloat(YRANGEBEGIN)  length:CPTDecimalFromCGFloat(YRANGELENGTH)];
    //plotSpace.allowsUserInteraction=YES;
    
    //绘制坐标系
    CPTXYAxisSet *axisSet=(CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x=axisSet.xAxis;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 1.5;
    lineStyle.lineCap=kCGLineCapButt;
    lineStyle.lineColor = [CPTColor colorWithComponentRed:112/255.0 green:124/255.0 blue:4/255.0 alpha:1.0];
    if(!isX){
        lineStyle.lineWidth=0;
    }
    x.axisLineStyle=lineStyle;
    x.majorIntervalLength=CPTDecimalFromLong(XINTERVALLENGTH);
    x.orthogonalCoordinateDecimal=CPTDecimalFromDouble(XORTHOGONALCOORDINATE);
    x.minorTicksPerInterval=XTICKSPERINTERVAL;
    //lineStyle.lineWidth=1.0;
    x.minorTickLineStyle = lineStyle;
    x.majorTickLineStyle=lineStyle;
    x.delegate=delegate;
    
    //lineStyle.lineColor = [CPTColor colorWithComponentRed:112/255.0 green:196/255.0 blue:64/255.0 alpha:1.0];
    lineStyle.lineWidth = 1.0;
    if(!isY){
        lineStyle.lineWidth=0.0;
    }
    CPTXYAxis *y=axisSet.yAxis;
    y.axisLineStyle=lineStyle;
    y.majorIntervalLength=CPTDecimalFromFloat(YINTERVALLENGTH);
    y.orthogonalCoordinateDecimal=CPTDecimalFromFloat(YORTHOGONALCOORDINATE);
    y.minorTicksPerInterval=YTICKSPERINTERVAL;    
    y.majorTickLength=15000.0;
    lineStyle.lineWidth=1.0;
    y.majorTickLineStyle=lineStyle;
    y.minorTickLineStyle = lineStyle;
    y.delegate=delegate;
    
}


















@end

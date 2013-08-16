//
//  DahonValuationViewController.m
//  估股
//
//  Created by Xcode on 13-8-8.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "DahonValuationViewController.h"
#import "DrawChartTool.h"
#import "XYZAppDelegate.h"
#import "MBProgressHUD.h"

@interface DahonValuationViewController ()

@end

@implementation DahonValuationViewController

@synthesize oneMonth;
@synthesize threeMonth;
@synthesize sixMonth;
@synthesize oneYear;

@synthesize daHonLinePlot;
@synthesize historyLinePlot;

@synthesize jsonData;
@synthesize dateArr;
@synthesize chartData;
@synthesize daHonDataDic;
@synthesize indexDateMap;
@synthesize daHonIndexSets;

@synthesize graph;
@synthesize hostView;
@synthesize plotSpace;

static NSString * DAHON_DATALINE_IDENTIFIER =@"dahon_dataline_identifier";
static NSString * HISTORY_DATALINE_IDENTIFIER =@"history_dataline_identifier";

- (void)dealloc
{
    SAFE_RELEASE(daHonIndexSets);
    SAFE_RELEASE(indexDateMap);
    SAFE_RELEASE(daHonDataDic);
    SAFE_RELEASE(oneMonth);
    SAFE_RELEASE(oneYear);
    SAFE_RELEASE(threeMonth);
    SAFE_RELEASE(sixMonth);
    SAFE_RELEASE(historyLinePlot);
    SAFE_RELEASE(daHonLinePlot);
    SAFE_RELEASE(dateArr);
    SAFE_RELEASE(chartData);
    SAFE_RELEASE(jsonData);
    
    SAFE_RELEASE(graph);
    SAFE_RELEASE(hostView);
    SAFE_RELEASE(plotSpace);
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initChart];
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    id com=delegate.comInfo;
    [MBProgressHUD showHUDAddedTo:self.hostView animated:YES];
	[self.view setBackgroundColor:[Utiles colorWithHexString:@"#EFEBD9"]];
    DrawChartTool *tool=[[DrawChartTool alloc] init];
    tool.standIn=self;
    [tool addLabelToView:self.view withTile:[com objectForKey:@"companyname"] Tag:6 frame:CGRectMake(0,0,480,40) fontSize:18.0 color:@"#007ab7"];
    [tool addButtonToView:self.view withTitle:@"返回" Tag:5 frame:CGRectMake(384,265,96,35) andFun:@selector(backTo:) withType:UIButtonTypeCustom andColor:@"#145d5e"];
    oneMonth=[tool addButtonToView:self.view withTitle:@"一个月" Tag:1 frame:CGRectMake(0,265,96,35) andFun:@selector(changeDateInter:) withType:UIButtonTypeCustom andColor:@"#705C32"];
    threeMonth=[tool addButtonToView:self.view withTitle:@"三个月" Tag:2 frame:CGRectMake(96,265,96,35) andFun:@selector(changeDateInter:) withType:UIButtonTypeCustom andColor:@"#705C32"];
    sixMonth=[tool addButtonToView:self.view withTitle:@"六个月" Tag:3 frame:CGRectMake(192,265,96,35) andFun:@selector(changeDateInter:) withType:UIButtonTypeCustom andColor:@"#705C32"];
    oneYear=[tool addButtonToView:self.view withTitle:@"一年" Tag:4 frame:CGRectMake(288,265,96,35) andFun:@selector(changeDateInter:) withType:UIButtonTypeCustom andColor:@"#705C32"];
    [oneMonth setEnabled:NO];
    [threeMonth setEnabled:NO];
    [sixMonth setEnabled:NO];
    [oneYear setEnabled:NO];
    SAFE_RELEASE(tool);
}

-(void)changeDateInter:(UIButton *)bt{
    bt.showsTouchWhenHighlighted=YES;
    if(bt.tag==1){
        XRANGELENGTH=22;
    }else if(bt.tag==2){
        XRANGELENGTH=65;
    }else if(bt.tag==3){
        XRANGELENGTH=130;
    }else if(bt.tag==4){
        XRANGELENGTH=260;
    }
    [self setXYAxis];
}

-(void)initChart{
    XRANGEBEGIN=-10;
    XRANGELENGTH=50;
    XINTERVALLENGTH=50;
    //初始化图形视图
    @try {
        graph=[[CPTXYGraph alloc] initWithFrame:CGRectZero];
        CPTTheme *theme=[CPTTheme themeNamed:kCPTSlateTheme];
        [graph applyTheme:theme];
        
        hostView=[[ CPTGraphHostingView alloc ] initWithFrame :CGRectMake(0,40,SCREEN_WIDTH,220) ];
        [self.view addSubview:hostView];
        [hostView setHostedGraph : graph ];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
    graph . paddingLeft = 0.0f ;
    graph . paddingRight = 0.0f ;
    graph . paddingTop = 0 ;
    graph . paddingBottom = 0 ;
    
    graph.title=@"大行估值";
    //绘制图形空间
    plotSpace=(CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction=YES;
    [self.hostView setAllowPinchScaling:NO];
    DrawXYAxisWithoutXAxisOrYAxis;
    [self addScatterChart];
}


-(void)initData{

    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    id comInfo=delegate.comInfo;
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[comInfo objectForKey:@"stockcode"],@"stockcode",[comInfo objectForKey:@"marketname"],@"marketname", nil];
    [Utiles getNetInfoWithPath:@"GetStockHistoryData" andParams:params besidesBlock:^(id resObj){
       
        self.chartData=[[resObj objectForKey:@"stockHistoryData"] objectForKey:@"data"];
        self.dateArr=[Utiles sortDateArr:self.chartData];
        self.daHonDataDic=[resObj objectForKey:@"dahonData"];
        NSMutableDictionary *tempDic=[[NSMutableDictionary alloc] init];
        @try {
            for(int i=0;i<[self.dateArr count];i++){
                [tempDic setValue:[NSNumber numberWithInt:i] forKey:[self.dateArr objectAtIndex:i]];
            }
            NSMutableDictionary *tempMap=[[NSMutableDictionary alloc] init];
            for(id key in daHonDataDic){
                [tempMap setValue:key forKey:[tempDic objectForKey:key]];
            }
            self.indexDateMap=tempMap;
            self.daHonIndexSets=[self.indexDateMap allKeys];
            SAFE_RELEASE(tempDic);
            SAFE_RELEASE(tempMap);
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        
        
        [self setXYAxis];
        [oneMonth setEnabled:YES];
        [threeMonth setEnabled:YES];
        [sixMonth setEnabled:YES];
        [oneYear setEnabled:YES];
        [MBProgressHUD hideHUDForView:self.hostView animated:YES];
        
    }];
}

-(void)setXYAxis{
    NSMutableArray *xTmp=[[NSMutableArray alloc] init];
    NSMutableArray *yTmp=[[NSMutableArray alloc] init];
    int n=0;
    for(id obj in self.dateArr){
        [xTmp addObject:[NSNumber numberWithInt:n++]];
    }
    for(id obj in self.chartData){
        [yTmp addObject:[[self.chartData objectForKey:obj] objectForKey:@"close"]];
    }
    
    NSDictionary *xyDic=[DrawChartTool getXYAxisRangeFromxArr:xTmp andyArr:yTmp fromWhere:DahonModel];
    XORTHOGONALCOORDINATE=[[xyDic objectForKey:@"xOrigin"] doubleValue];
    YRANGEBEGIN=[[xyDic objectForKey:@"yBegin"] doubleValue];
    YRANGELENGTH=[[xyDic objectForKey:@"yLength"] doubleValue];
    YORTHOGONALCOORDINATE=[[xyDic objectForKey:@"yOrigin"] doubleValue];
    YINTERVALLENGTH=[[xyDic objectForKey:@"yInterval"] doubleValue];
    plotSpace.globalYRange=[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(YRANGEBEGIN) length:CPTDecimalFromDouble(YRANGELENGTH)];
    plotSpace.globalXRange=[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(XRANGEBEGIN) length:CPTDecimalFromDouble(300)];
    DrawXYAxisWithoutXAxisOrYAxis;
    [graph reloadData];
}



-(void)backTo:(UIButton *)bt{
    bt.showsTouchWhenHighlighted=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}


//散点数据源委托实现
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{

    
    if([(NSString *)plot.identifier isEqualToString:HISTORY_DATALINE_IDENTIFIER]){
        return [self.chartData count];
    }else if([(NSString *)plot.identifier isEqualToString:DAHON_DATALINE_IDENTIFIER]){
        return [self.daHonDataDic count];
    }

}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger) index{
    
    NSNumber *num=nil;
    
    if([(NSString *)plot.identifier isEqualToString:HISTORY_DATALINE_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
  
        if([key isEqualToString:@"x"]){
            num=[NSNumber numberWithInt:index] ;
        }else if([key isEqualToString:@"y"]){
            num=[[self.chartData valueForKey:[self.dateArr objectAtIndex:index]] objectForKey:@"close"];
        }
        
    }else if([(NSString *)plot.identifier isEqualToString:DAHON_DATALINE_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
        NSInteger trueIndex=[[self.daHonIndexSets objectAtIndex:index] intValue];
        if([key isEqualToString:@"x"]){
            num=[NSNumber numberWithInt:trueIndex];
        }else if([key isEqualToString:@"y"]){
            num=[[self.chartData valueForKey:[self.dateArr objectAtIndex:trueIndex]] objectForKey:@"close"];
        }
    }
    return  num;
}

#pragma mark -
#pragma mark Scatter Plot Methods Delegate
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx{
    NSNumber *trueIndex=[NSNumber numberWithInt:[[self.daHonIndexSets objectAtIndex:idx] intValue]];
    NSString *date=[self.indexDateMap objectForKey:trueIndex];
    id data=[self.daHonDataDic objectForKey:date];
    NSString *msg=[[NSString alloc] init];
    for(id obj in data){
        msg=[msg stringByAppendingFormat:@"%@:%@",[obj objectForKey:@"dahonName"],[obj objectForKey:@"desc"]];
    }
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
    alert.alertViewStyle=UIAlertViewStyleDefault;
    [alert show];
    SAFE_RELEASE(alert);
    
}

#pragma mark -
#pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    if(axis.coordinate==CPTCoordinateX){
        
        NSNumberFormatter * formatter   = (NSNumberFormatter *)axis.labelFormatter;
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        //[formatter setPositiveFormat:@"0.00%;0.00%;-0.00%"];
        [formatter setPositiveFormat:@"##"];
        //CGFloat labelOffset             = axis.labelOffset;
        NSMutableSet * newLabels        = [NSMutableSet set];
        static CPTTextStyle * positiveStyle = nil;
        for (NSDecimalNumber * tickLocation in locations) {
            CPTTextStyle *theLabelTextStyle;
            
            CPTMutableTextStyle * newStyle = [axis.labelTextStyle mutableCopy];
            positiveStyle  = newStyle;
            
            theLabelTextStyle = positiveStyle;
            
            NSString * labelString      = [formatter stringForObjectValue:tickLocation];
            NSString *str=nil;
            if([self.dateArr count]>10){
                @try {
                    if([labelString intValue]<=[self.dateArr count]&&[labelString intValue]>=0){
                        str=[self.dateArr objectAtIndex:[labelString intValue]];
                    }else{
                        str=@"";
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"%@",exception);
                }
            }
        
            CPTTextLayer * newLabelLayer= [[CPTTextLayer alloc] initWithText:str style:theLabelTextStyle];
            [newLabelLayer sizeToFit];
            CPTAxisLabel * newLabel     = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
            newLabel.tickLocation       = tickLocation.decimalValue;
            newLabel.offset             =  0;
            //newLabel.rotation     = labelOffset;
            [newLabels addObject:newLabel];
        }
        
        axis.axisLabels = newLabels;
    }else{
        NSNumberFormatter * formatter   = (NSNumberFormatter *)axis.labelFormatter;
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        //[formatter setPositiveFormat:@"0.00%;0.00%;-0.00%"];
        [formatter setPositiveFormat:@"##.##"];
        NSMutableSet * newLabels        = [NSMutableSet set];
        static CPTTextStyle * positiveStyle = nil;
        for (NSDecimalNumber * tickLocation in locations) {
            CPTTextStyle *theLabelTextStyle;
            
            CPTMutableTextStyle * newStyle = [axis.labelTextStyle mutableCopy];
            positiveStyle  = newStyle;
            
            theLabelTextStyle = positiveStyle;
            
            NSString * labelString      = [formatter stringForObjectValue:tickLocation];
            CPTTextLayer * newLabelLayer= [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
            [newLabelLayer sizeToFit];
            CPTAxisLabel * newLabel     = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
            newLabel.tickLocation       = tickLocation.decimalValue;
            newLabel.offset             = 10;
            [newLabels addObject:newLabel];
        }
        
        axis.axisLabels = newLabels;
        
    }
    
    
    return NO;
}

-(void)addScatterChart{

    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    //修改折线图线段样式,创建可调整数据线段
    historyLinePlot=[[CPTScatterPlot alloc] init];
    lineStyle.miterLimit=2.0f;
    lineStyle.lineWidth=2.0f;
    lineStyle.lineColor=[CPTColor colorWithComponentRed:134/255.0 green:6/255.0 blue:156 alpha:0.8];
    historyLinePlot.dataLineStyle=lineStyle;
    historyLinePlot.identifier=HISTORY_DATALINE_IDENTIFIER;
    historyLinePlot.labelOffset=5;
    historyLinePlot.dataSource=self;
    historyLinePlot.delegate=self;
    
    daHonLinePlot=[[CPTScatterPlot alloc] init];
    lineStyle.miterLimit=0.0f;
    lineStyle.lineWidth=0.0f;
    lineStyle.lineColor=[CPTColor clearColor];
    daHonLinePlot.dataLineStyle=lineStyle;
    daHonLinePlot.identifier=DAHON_DATALINE_IDENTIFIER;
    daHonLinePlot.labelOffset=5;
    daHonLinePlot.dataSource=self;
    daHonLinePlot.delegate=self;
    
    CPTMutableLineStyle * symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor colorWithComponentRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:0.5];
    symbolLineStyle.lineWidth = 2.0;
    
    CPTPlotSymbol * plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor: [CPTColor colorWithComponentRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:0.5]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(20, 20);
    
    daHonLinePlot.plotSymbol = plotSymbol;
   
    [graph addPlot:historyLinePlot];
    [graph addPlot:daHonLinePlot];

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        self.hostView.frame=CGRectMake(0,40,480,225);
    }
}
-(NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    
    return YES;
}










@end

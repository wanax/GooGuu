//
//  DahonValuationViewController.m
//  估股
//
//  Created by Xcode on 13-8-8.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "DahonValuationViewController.h"
#import "CommonlyMacros.h"
#import "Utiles.h"
#import "DrawChartTool.h"
#import "XYZAppDelegate.h"
#import "JSONKit.h"
#import "MBProgressHUD.h"

@interface DahonValuationViewController ()

@end

@implementation DahonValuationViewController

@synthesize daHonLinePlot;

@synthesize jsonData;
@synthesize dateArr;
@synthesize chartData;

@synthesize graph;
@synthesize hostView;
@synthesize plotSpace;

static NSString * DAHON_DATALINE_IDENTIFIER =@"dahon_dataline_identifier";

- (void)dealloc
{
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
    [MBProgressHUD showHUDAddedTo:self.hostView animated:YES];
	[self.view setBackgroundColor:[Utiles colorWithHexString:@"#EFEBD9"]];
    DrawChartTool *tool=[[DrawChartTool alloc] init];
    tool.standIn=self;
    [tool addButtonToView:self.view withTitle:@"返回" Tag:5 frame:CGRectMake(400,0,80,40) andFun:@selector(backTo:)];
    [tool addButtonToView:self.view withTitle:@"一个月" Tag:1 frame:CGRectMake(75.5,260,80,40) andFun:@selector(changeDateInter:)];
    [tool addButtonToView:self.view withTitle:@"三个月" Tag:2 frame:CGRectMake(158.5,260,80,40) andFun:@selector(changeDateInter:)];
    [tool addButtonToView:self.view withTitle:@"六个月" Tag:3 frame:CGRectMake(241.5,260,80,40) andFun:@selector(changeDateInter:)];
    [tool addButtonToView:self.view withTitle:@"一年" Tag:4 frame:CGRectMake(324.5,260,80,40) andFun:@selector(changeDateInter:)];
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
    XRANGEBEGIN=0;
    XRANGELENGTH=50;
    YRANGEBEGIN=0;
    YRANGELENGTH=20;
    XINTERVALLENGTH=50;
    XORTHOGONALCOORDINATE=5;
    XTICKSPERINTERVAL=0;
    YINTERVALLENGTH=5;
    YORTHOGONALCOORDINATE =11.0;
    YTICKSPERINTERVAL =0;
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
    DrawXYAxis;
    [self addScatterChart];
}


-(void)initData{

    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    id comInfo=delegate.comInfo;
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[comInfo objectForKey:@"stockcode"],@"stockcode",[comInfo objectForKey:@"marketname"],@"marketname", nil];
    [Utiles getNetInfoWithPath:@"GetStockHistoryData" andParams:params besidesBlock:^(id resObj){
       
        self.chartData=[[resObj objectForKey:@"stockHistoryData"] objectForKey:@"data"];
        self.dateArr=[Utiles sortDateArr:self.chartData];

        [self setXYAxis];
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
    DrawXYAxis;
    [graph reloadData];
}



-(void)backTo:(UIButton *)bt{
    bt.showsTouchWhenHighlighted=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}


//散点数据源委托实现
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{

    return [self.chartData count];

}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger) index{
    
    NSNumber *num=nil;
    
    if([(NSString *)plot.identifier isEqualToString:DAHON_DATALINE_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
  
        if([key isEqualToString:@"x"]){
            num=[NSNumber numberWithInt:index] ;
        }else if([key isEqualToString:@"y"]){
            num=[[self.chartData valueForKey:[self.dateArr objectAtIndex:index]] objectForKey:@"close"];
        }
        
    }
    return  num;
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
            if([labelString intValue]<230&&[labelString intValue]>=0){
                str=[self.dateArr objectAtIndex:[labelString intValue]];
            }else{
                str=@"";
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
        CGFloat labelOffset             = axis.labelOffset;
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
            newLabel.offset             =  0;
            //newLabel.rotation     = labelOffset;
            [newLabels addObject:newLabel];
        }
        
        axis.axisLabels = newLabels;
        
    }
    
    
    return NO;
}

-(void)addScatterChart{

    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    //修改折线图线段样式,创建可调整数据线段
    daHonLinePlot=[[CPTScatterPlot alloc] init];
    lineStyle.miterLimit=2.0f;
    lineStyle.lineWidth=2.0f;
    lineStyle.lineColor=[CPTColor whiteColor];
    daHonLinePlot.dataLineStyle=lineStyle;
    daHonLinePlot.identifier=DAHON_DATALINE_IDENTIFIER;
    //forecastLinePlot.labelOffset=5;
    daHonLinePlot.dataSource=self;//需实现委托
    daHonLinePlot.delegate=self;
   
    [graph addPlot:daHonLinePlot];

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        self.hostView.frame=CGRectMake(0,40,480,220);
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

//
//  Chart3ViewController.m
//  Chart1.3
//
//  Created by Xcode on 13-4-15.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  公司详细页图表绘制

#import "ChartViewController.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "math.h"
#import "JSONKit.h"
#import "Utiles.h"
#import <AddressBook/AddressBook.h>
#import "ModelViewController.h"
#import "MHTabBarController.h"
#import "MBProgressHUD.h"
#import "XYZAppDelegate.h"
#import "TSPopoverController.h"
#import "PrettyNavigationController.h"
#import "CQMFloatingController.h"
#import "DrawChartTool.h"
#import "ModelClassViewController.h"
#import "CommonlyMacros.h"
#import "DiscountRateViewController.h"



@interface ChartViewController ()

@end

@implementation ChartViewController

@synthesize forecastPoints=_forecastPoints;
@synthesize forecastDefaultPoints=_forecastDefaultPoints;
@synthesize hisPoints=_hisPoints;
@synthesize standard=_standard;

@synthesize jsonForChart=_jsonForChart;

@synthesize forecastDefaultLinePlot;
@synthesize forecastLinePlot;
@synthesize historyLinePlot;
@synthesize barPlot;

@synthesize linkage;
@synthesize isAddGesture;

@synthesize industryClass=_industryClass;
@synthesize yAxisUnit;
@synthesize modelClassViewController;
@synthesize hostView;
@synthesize plotSpace;
@synthesize graph;

@synthesize webView;
@synthesize priceLabel;


static NSString * FORECAST_DATALINE_IDENTIFIER =@"forecast_dataline_identifier";
static NSString * FORECAST_DEFAULT_DATALINE_IDENTIFIER =@"forecast_default_dataline_identifier";
static NSString * HISTORY_DATALINE_IDENTIFIER =@"history_dataline_identifier";
static NSString * COLUMNAR_DATALINE_IDENTIFIER =@"columnar_dataline_identifier";


- (void)dealloc
{
    [yAxisUnit release];yAxisUnit=nil;
    [modelClassViewController release];modelClassViewController=nil;
    [graph release];graph=nil;
    [plotSpace release];plotSpace=nil;
    [hostView release];hostView=nil;
    
    [_forecastDefaultPoints release];_forecastDefaultPoints=nil;
    [_forecastPoints release];_forecastPoints=nil;
    [_hisPoints release];_hisPoints=nil;
    [_jsonForChart release];_jsonForChart=nil;
    [_industryClass release];_industryClass=nil;
    [_standard release];_standard=nil;
    
    [forecastLinePlot release];forecastLinePlot=nil;
    [forecastDefaultLinePlot release];forecastDefaultLinePlot=nil;
    [historyLinePlot release];historyLinePlot=nil;
    [barPlot release];barPlot=nil;
    
    [webView release];webView=nil;
    [priceLabel release];priceLabel=nil;
    
    [super dealloc];
}
-(void)viewDidDisappear:(BOOL)animated{
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    linkage=YES;
    self.modelClassViewController=[[ModelClassViewController alloc] init];
    self.modelClassViewController.delegate=self;

    webView=[[UIWebView alloc] init];
    webView.delegate=self;    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"c" ofType:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath: path]]];
  
    self.forecastPoints=[[NSMutableArray alloc] init];
    self.hisPoints=[[NSMutableArray alloc] init];
    self.forecastDefaultPoints=[[NSMutableArray alloc] init];
    self.standard=[[NSMutableArray alloc] init];
    
    //初始化图形视图
    @try {
        graph=[[CPTXYGraph alloc] initWithFrame:CGRectZero];
        CPTTheme *theme=[CPTTheme themeNamed:kCPTSlateTheme];
        [graph applyTheme:theme];
        
        hostView=[[ CPTGraphHostingView alloc ] initWithFrame :CGRectMake(0,40,SCREEN_WIDTH,280) ];
        [self.view addSubview:hostView];
        [hostView setHostedGraph : graph ];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }

    graph . paddingLeft = 0.0f ;
    graph . paddingRight = 0.0f ;
    graph . paddingTop = GRAPAHTOPPAD ;
    graph . paddingBottom = GRAPAHBOTTOMPAD ;

    //绘制图形空间
    plotSpace=(CPTXYPlotSpace *)graph.defaultPlotSpace;
    
    DrawXYAxis;

    DrawChartTool *tool=[[DrawChartTool alloc] init];
    tool.standIn=self;
    priceLabel=[tool addLabelToView:self.view withTile:@"拖动计算股价" Tag:11 frame:CGRectMake(0,0,160,40) fontSize:16.0];
    [tool addButtonToView:self.view withTitle:@"保存" Tag:1 frame:CGRectMake(160,0,80,40) andFun:@selector(saveData:)];
    [tool addButtonToView:self.view withTitle:@"点动" Tag:2 frame:CGRectMake(240,0,80,40) andFun:@selector(changeButton:)];
    [tool addButtonToView:self.view withTitle:@"行业选择" Tag:3 frame:CGRectMake(320,0,80,40) andFun:@selector(selectIndustry:forEvent:)];
    [tool addButtonToView:self.view withTitle:@"返回" Tag:4 frame:CGRectMake(400,0,80,40) andFun:@selector(backTo:)];
    [self addScatterChart];
    [tool release];

}
-(void)saveData:(UIButton *)bt{
    NSLog(@"save");
}

-(void)changeButton:(UIButton *)bt{
    bt.showsTouchWhenHighlighted=YES;
    if(linkage){
        [bt setTitle:@"联动" forState:UIControlStateNormal];
        [self addBarChart];
        linkage=NO;
    }else{
        [bt setTitle:@"点动" forState:UIControlStateNormal];
        [self addScatterChart];
        linkage=YES;
    }
}


-(void)selectIndustry:(UIButton *)sender forEvent:(UIEvent*)event{
    
    CQMFloatingController *floatingController = [CQMFloatingController sharedFloatingController];
    floatingController.frameSize=CGSizeMake(280,280);
    floatingController.frameColor=[Utiles colorWithHexString:@"#8cb990"];
	[floatingController presentWithContentViewController:modelClassViewController
												animated:YES];
}

-(void)backTo:(UIButton *)bt{    
    bt.showsTouchWhenHighlighted=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addBarChart{
    
    if(![graph plotWithIdentifier:COLUMNAR_DATALINE_IDENTIFIER]){

        barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor colorWithComponentRed:153/255.0 green:100/255.0 blue:49/255.0 alpha:0.3] horizontalBars:NO];
        barPlot.baseValue  = CPTDecimalFromFloat(XORTHOGONALCOORDINATE);
        barPlot.dataSource = self;
        barPlot.barOffset  = CPTDecimalFromFloat(-0.5f);
        barPlot.fill=[CPTFill fillWithColor:[CPTColor colorWithComponentRed:174/255.0 green:10/255.0 blue:148/255.0 alpha:0.3]];
        barPlot.identifier = COLUMNAR_DATALINE_IDENTIFIER;
        barPlot.barWidth=CPTDecimalFromFloat(0.5f);
        [graph addPlot:barPlot];
        linkage=NO;
        [barPlot release];
    }
   
}



-(void)webViewDidFinishLoad:(UIWebView *)webView{

    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    id comInfo=delegate.comInfo;
    [MBProgressHUD showHUDAddedTo:self.hostView animated:YES];
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[comInfo objectForKey:@"stockcode"],@"stockCode", nil];
    [Utiles getNetInfoWithPath:@"CompanyModel" andParams:params besidesBlock:^(id resObj){
        
        self.jsonForChart=[resObj JSONString];
        self.jsonForChart=[self.jsonForChart stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\\\\\""];
        self.jsonForChart=[self.jsonForChart stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];


        id resTmp=[self getObjectDataFromJsFun:@"initData" byData:self.jsonForChart];
        self.modelClassViewController.jsonData=resTmp;
        self.industryClass=resTmp;
      
        id chartData=[self getObjectDataFromJsFun:@"returnChartData" byData:[[[self.industryClass objectForKey:@"listMain"] objectAtIndex:0] objectForKey:@"id"]];
        
        [self divideData:chartData];
        self.yAxisUnit=[chartData objectForKey:@"unit"];
        graph.title=[NSString stringWithFormat:@"%@(单位:%@)",[chartData objectForKey:@"title"],[chartData objectForKey:@"unit"]];
        [self setXYAxis];
        [MBProgressHUD hideHUDForView:self.hostView animated:YES];
        if(!isAddGesture){
            //手势添加
            UIPanGestureRecognizer *panGr=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewPan:)];
            [hostView addGestureRecognizer:panGr];
            [panGr release];
            isAddGesture=YES;
        }
        
        
    }];

    
}

-(void)toldYouClassChanged:(NSString *)driverId andIndustry:(NSString *)industry{
    
    if([industry isEqualToString:@"discount"]){
        
        DiscountRateViewController *rateViewController=[[DiscountRateViewController alloc] init];
        rateViewController.view.frame=CGRectMake(0,40,480,320);
        rateViewController.jsonData=self.jsonForChart;
        [self presentViewController:rateViewController animated:YES completion:nil];
        SAFE_RELEASE(rateViewController);
    }else{
        id chartData=[self getObjectDataFromJsFun:@"returnChartData" byData:driverId];
        [self divideData:chartData];
        self.yAxisUnit=[chartData objectForKey:@"unit"];
        graph.title=[NSString stringWithFormat:@"%@(单位:%@)",[chartData objectForKey:@"title"],[chartData objectForKey:@"unit"]];
        [self setXYAxis];
    }
    
}

-(void)divideData:(id)sourceData{
    [self.hisPoints removeAllObjects];
    [self.forecastDefaultPoints removeAllObjects];
    [self.forecastPoints removeAllObjects];
    //构造折点数据键值对 key：年份 value：估值 方便后面做临近折点的判断
    NSMutableDictionary *mutableObj=nil;
    for(id obj in [sourceData objectForKey:@"array"]){
        mutableObj=[[NSMutableDictionary alloc] initWithDictionary:obj];
        if([[mutableObj objectForKey:@"h"] boolValue]){
            [self.hisPoints addObject:mutableObj];
        }else{
            [self.forecastDefaultPoints addObject:[[mutableObj mutableCopy] autorelease]];
        }
    }
    for(id obj in [sourceData objectForKey:@"arraynew"]){
        mutableObj=[[NSMutableDictionary alloc] initWithDictionary:obj];
        [self.forecastPoints addObject:mutableObj];
    }
    //历史数据与预测数据线拼接
    [self.forecastPoints insertObject:[self.hisPoints lastObject] atIndex:0];
    [self.forecastDefaultPoints insertObject:[self.hisPoints lastObject] atIndex:0];
    SAFE_RELEASE(mutableObj);
}


-(id)getObjectDataFromJsFun:(NSString *)funName byData:(NSString *)data{
    NSString *arg=[[NSString alloc] initWithFormat:@"%@(\"%@\")",funName,data];
    NSString *re=[self.webView stringByEvaluatingJavaScriptFromString:arg];
    re=[re stringByReplacingOccurrencesOfString:@",]" withString:@"]"];
    SAFE_RELEASE(arg);
    return [re objectFromJSONString];    
}

-(void)viewPan:(UIPanGestureRecognizer *)tapGr
{
    CGPoint now=[tapGr locationInView:self.view];
    CGPoint change=[tapGr translationInView:self.view];
    CGPoint coordinate=[self CoordinateTransformRealToAbstract:now];
    
    if(tapGr.state==UIGestureRecognizerStateBegan){
        [self.standard removeAllObjects];
        for(id obj in self.forecastPoints){
            [self.standard addObject:[obj objectForKey:@"v"]];
        }
        
    }else if(tapGr.state==UIGestureRecognizerStateEnded){
        [self.standard removeAllObjects];
        
        for(id obj in self.forecastPoints){
            double v = [[obj objectForKey:@"v"] doubleValue];
            [self.standard addObject:[NSNumber numberWithDouble:v]];
        }
        //结束拖动重绘坐标轴 适应新尺寸
        [self setXYAxis];
    }
    //手势变化并且接近折点旁边
    if([tapGr state]==UIGestureRecognizerStateChanged){

        coordinate.x=(int)(coordinate.x+0.5);
        coordinate.x=(int)(coordinate.x+0.5);

        int subscript=coordinate.x-XRANGEBEGIN-[self.hisPoints count]-1;        
        subscript=subscript<0?0:subscript;
        subscript=subscript>=[self.forecastPoints count]-1?[self.forecastPoints count]-1:subscript;
        NSAssert(subscript<=[self.forecastPoints count]-1&&coordinate.x>=0,@"over bounds");
        
        if(linkage){            
            double l4 = YRANGELENGTH*change.y/hostView.frame.size.height/ (1 - exp(-2));

            double l7 = 2 / ([[[self.forecastPoints objectAtIndex:subscript] objectForKey:@"y"] doubleValue]);
            int i=0;
            for(id obj in self.forecastPoints){
                double v = [[obj objectForKey:@"v"] doubleValue];
                v =[[self.standard objectAtIndex:i] doubleValue]- l4 * (1 - exp(-l7 * i++));
                [obj setObject:[NSNumber numberWithDouble:v] forKey:@"v"];
            }
            
            [self setStockPrice];
            [graph reloadData];
            
        }else{
            
            double changeD=-YRANGELENGTH*change.y/hostView.frame.size.height;
            double v=[[self.standard objectAtIndex:subscript] doubleValue]+changeD;
            [[self.forecastPoints objectAtIndex:subscript] setObject:[NSNumber numberWithDouble:v] forKey:@"v"];
            
            [self setStockPrice];
            [graph reloadData];
            
        }
        
    }
    
}


-(void)setStockPrice{
    
    NSString *jsonPrice=[self.forecastPoints JSONString];
    jsonPrice=[jsonPrice stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *arg1=[[NSString alloc] initWithFormat:@"chartCalu(\"%@\")",jsonPrice];
    //传入数据注意格式调用，html文件的key值应与此key值对应
    NSString *re1=[self.webView stringByEvaluatingJavaScriptFromString:arg1];
    SAFE_RELEASE(arg1);
    [self.priceLabel setText:[re1 substringToIndex:5]];
}



#pragma mark -
#pragma mark Line Data Source Delegate


// 添加数据标签
-( CPTLayer *)dataLabelForPlot:( CPTPlot *)plot recordIndex:( NSUInteger )index
{
    // 定义一个白色的 TextStyle
    static CPTMutableTextStyle *whiteText = nil ;
    if ( !whiteText ) {
        whiteText = [[ CPTMutableTextStyle alloc ] init ];
        whiteText.color=[CPTColor colorWithComponentRed:152/255.0 green:251/255.0 blue:152/255.0 alpha:1.0];
    }

    // 定义一个 TextLayer
    CPTTextLayer *newLayer = nil ;
    NSString * identifier=( NSString *)[plot identifier];
    if ([identifier isEqualToString : FORECAST_DATALINE_IDENTIFIER]) {
        newLayer=[[CPTTextLayer alloc] initWithText:[self formatTrans:index from:self.forecastPoints] style:whiteText];
    }else if([identifier isEqualToString : HISTORY_DATALINE_IDENTIFIER]){        
        newLayer=[[CPTTextLayer alloc] initWithText:[self formatTrans:index from:self.hisPoints] style:whiteText];        
    }
    return newLayer;
}
-(NSString *)formatTrans:(NSUInteger)index from:(NSMutableArray *)arr{
    NSString *numberString =nil;
    if([self.yAxisUnit isEqualToString:@"%"]){
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterPercentStyle];
        numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:[[[arr objectAtIndex:index] objectForKey:@"v"] floatValue]]];
        SAFE_RELEASE(formatter);
    }else{
        numberString=[[[arr objectAtIndex:index] objectForKey:@"v"] stringValue];
        if(numberString.length>4){
            numberString=[numberString substringToIndex:4];
        }
    }
    return numberString;
}



//散点数据源委托实现
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    
    if([(NSString *)plot.identifier isEqualToString:FORECAST_DEFAULT_DATALINE_IDENTIFIER]){
        return [self.forecastDefaultPoints count];
    }else if([(NSString *)plot.identifier isEqualToString:HISTORY_DATALINE_IDENTIFIER]){
        return [self.hisPoints count];
    }else if([(NSString *)plot.identifier isEqualToString:FORECAST_DATALINE_IDENTIFIER]){
        return [self.forecastPoints count];
    }else{
        return [self.forecastPoints count];
    }
    
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger) index{

    NSNumber *num=nil;

    if([(NSString *)plot.identifier isEqualToString:HISTORY_DATALINE_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
   
        if([key isEqualToString:@"x"]){
            num=[[self.hisPoints objectAtIndex:index] valueForKey:@"y"];
        }else if([key isEqualToString:@"y"]){
            num=[[self.hisPoints objectAtIndex:index] valueForKey:@"v"];
        }

    }else if([(NSString *)plot.identifier isEqualToString:FORECAST_DATALINE_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
        
        if([key isEqualToString:@"x"]){
            num=[[self.forecastPoints objectAtIndex:index] valueForKey:@"y"];
        }else if([key isEqualToString:@"y"]){
            num=[[self.forecastPoints objectAtIndex:index] valueForKey:@"v"];
        }

    }else if([(NSString *)plot.identifier isEqualToString:FORECAST_DEFAULT_DATALINE_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
        
        if([key isEqualToString:@"x"]){
            num=[[self.forecastDefaultPoints objectAtIndex:index] valueForKey:@"y"];
        }else if([key isEqualToString:@"y"]){
            num=[[self.forecastDefaultPoints objectAtIndex:index] valueForKey:@"v"];
        }        
    }else if([(NSString *)plot.identifier isEqualToString:COLUMNAR_DATALINE_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
        
        if([key isEqualToString:@"x"]){
            num=[NSNumber numberWithDouble:[[[self.forecastPoints objectAtIndex:index] valueForKey:@"y"] doubleValue]+0.5];
        }else if([key isEqualToString:@"y"]){
            num=[[self.forecastPoints objectAtIndex:index] valueForKey:@"v"];
        }
        
    }
    
    return  num;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer

{
    return YES;
}

//空间坐标转换:实际坐标转化自定义坐标
-(CGPoint)CoordinateTransformRealToAbstract:(CGPoint)point{
    
    float viewWidth=hostView.frame.size.width;
    float viewHeight=hostView.frame.size.height;
    
    point.y=point.y-HOSTVIEWTOPPAD;
    
    float coordinateX=(XRANGELENGTH*point.x)/viewWidth+XRANGEBEGIN;
    float coordinateY=YRANGELENGTH-((YRANGELENGTH*point.y)/(viewHeight-GRAPAHBOTTOMPAD-GRAPAHTOPPAD))+YRANGEBEGIN;
    
    return CGPointMake(coordinateX,coordinateY);
}
//空间坐标转换:自定义坐标转化实际坐标
-(CGPoint)CoordinateTransformAbstractToReal:(CGPoint)point{
    
    float viewWidth=hostView.frame.size.width;
    float viewHeight=hostView.frame.size.height;
    
    float coordinateX=(point.x-XRANGEBEGIN)*viewWidth/XRANGELENGTH;
    float coordinateY=(-1)*(point.y-YRANGEBEGIN-YRANGELENGTH)*(viewHeight-GRAPAHBOTTOMPAD-GRAPAHTOPPAD)/YRANGELENGTH;
    
    return CGPointMake(coordinateX,coordinateY);
    
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
            CPTTextLayer * newLabelLayer= [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
            [newLabelLayer sizeToFit];
            CPTAxisLabel * newLabel     = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
            newLabel.tickLocation       = tickLocation.decimalValue;
            newLabel.offset             =  0;
            newLabel.rotation     = 5.5;
            [newLabels addObject:newLabel];
        }
        
        axis.axisLabels = newLabels;
    }else{

        
    }
    
    
    return NO;
}


-(void)setXYAxis{
    NSMutableArray *xTmp=[[NSMutableArray alloc] init];
    NSMutableArray *yTmp=[[NSMutableArray alloc] init];
    for(id obj in self.hisPoints){
        [xTmp addObject:[obj objectForKey:@"y"]];
        [yTmp addObject:[obj objectForKey:@"v"]];
    }
    for(id obj in self.forecastPoints){
        [xTmp addObject:[obj objectForKey:@"y"]];
        [yTmp addObject:[obj objectForKey:@"v"]];
    }

    NSDictionary *xyDic=[DrawChartTool getXYAxisRangeFromxArr:xTmp andyArr:yTmp fromWhere:DragabelModel];
    XRANGEBEGIN=[[xyDic objectForKey:@"xBegin"] floatValue];
    XRANGELENGTH=[[xyDic objectForKey:@"xLength"] floatValue];
    XORTHOGONALCOORDINATE=[[xyDic objectForKey:@"xOrigin"] floatValue];
    XINTERVALLENGTH=[[xyDic objectForKey:@"xInterval"] floatValue];
    YRANGEBEGIN=[[xyDic objectForKey:@"yBegin"] floatValue];
    YRANGELENGTH=[[xyDic objectForKey:@"yLength"] floatValue];
    YORTHOGONALCOORDINATE=[[[self.hisPoints lastObject] objectForKey:@"y"] floatValue];
    YINTERVALLENGTH=[[xyDic objectForKey:@"yInterval"] floatValue];
    DrawXYAxis;
    SAFE_RELEASE(xTmp);
    SAFE_RELEASE(yTmp);
    [graph reloadData];
}

-(void)addScatterChart{
   
    linkage=YES;
    if([graph plotWithIdentifier:COLUMNAR_DATALINE_IDENTIFIER]){
        [graph removePlot:barPlot];
    }
    
    if(!([graph plotWithIdentifier:FORECAST_DATALINE_IDENTIFIER]&&[graph plotWithIdentifier:FORECAST_DEFAULT_DATALINE_IDENTIFIER])){
        
        //y. labelingPolicy = CPTAxisLabelingPolicyNone ;
        CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
        //修改折线图线段样式,创建可调整数据线段
        forecastLinePlot=[[[CPTScatterPlot alloc] init] autorelease];
        lineStyle.miterLimit=2.0f;
        lineStyle.lineWidth=2.0f;
        lineStyle.lineColor=[CPTColor whiteColor];
        forecastLinePlot.dataLineStyle=lineStyle;
        forecastLinePlot.identifier=FORECAST_DATALINE_IDENTIFIER;
        //forecastLinePlot.labelOffset=5;
        forecastLinePlot.dataSource=self;//需实现委托
        //forecastLinePlot.delegate=self;
        
        //创建默认对比数据线
        lineStyle.lineColor=[CPTColor grayColor];
        forecastDefaultLinePlot = [[CPTScatterPlot alloc] init];
        forecastDefaultLinePlot.dataLineStyle = lineStyle;
        forecastDefaultLinePlot.identifier = FORECAST_DEFAULT_DATALINE_IDENTIFIER;
        forecastDefaultLinePlot.dataSource = self;
        
        
        //创建历史数据线段
        lineStyle.lineColor=[CPTColor redColor];
        historyLinePlot = [[CPTScatterPlot alloc] init];
        historyLinePlot.dataLineStyle = lineStyle;
        historyLinePlot.identifier = HISTORY_DATALINE_IDENTIFIER;
        historyLinePlot.dataSource = self;
     
        // Add plot symbols: 表示数值的符号的形状
        //
        CPTMutableLineStyle * symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = [CPTColor colorWithComponentRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:0.5];
        symbolLineStyle.lineWidth = 2.0;
        
        CPTPlotSymbol * plotSymbol = [CPTPlotSymbol diamondPlotSymbol];
        plotSymbol.fill          = [CPTFill fillWithColor: [CPTColor colorWithComponentRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:0.5]];
        plotSymbol.lineStyle     = symbolLineStyle;
        plotSymbol.size          = CGSizeMake(10, 10);
        
        forecastLinePlot.plotSymbol = plotSymbol;
        historyLinePlot.plotSymbol=plotSymbol;
        
        [graph addPlot:forecastDefaultLinePlot];
        [graph addPlot:historyLinePlot];
        [graph addPlot:forecastLinePlot];
        
        [forecastLinePlot release];
        [forecastDefaultLinePlot release];
        [historyLinePlot release];
        
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        //[self.navigationController.navigationBar setHidden:YES];
        //self.hostView.frame=CGRectMake(0,HOSTVIEWTOPPAD,320,480-HOSTVIEWBOTTOMPAD-HOSTVIEWTOPPAD);
    } else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        self.hostView.frame=CGRectMake(0,40,SCREEN_HEIGHT,260);
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

















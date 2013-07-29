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

@interface ChartViewController ()

@end

@implementation ChartViewController

@synthesize forecastPoints=_forecastPoints;
@synthesize forecastDefaultPoints=_forecastDefaultPoints;
@synthesize hisPoints=_hisPoints;
@synthesize dividingPoints=_dividingPoints;
@synthesize standard=_standard;

@synthesize jsonForChart=_jsonForChart;

@synthesize forecastDefaultLinePlot;
@synthesize forecastLinePlot;
@synthesize historyLinePlot;
@synthesize dividingLinePlot;
@synthesize barPlot;

@synthesize linkage;

@synthesize industryClass=_industryClass;
//@synthesize context;
@synthesize hostView;
@synthesize reverseDic;

@synthesize webView;
@synthesize priceLabel;

static NSString * FORECAST_DATALINE_IDENTIFIER =@"forecast_dataline_identifier";
static NSString * FORECAST_DEFAULT_DATALINE_IDENTIFIER =@"forecast_default_dataline_identifier";
static NSString * HISTORY_DATALINE_IDENTIFIER =@"history_dataline_identifier";
static NSString * DIVIDING_DATALINE_IDENTIFIER =@"dividing_dataline_identifier";
static NSString * COLUMNAR_DATALINE_IDENTIFIER =@"columnar_dataline_identifier";


- (void)dealloc
{
    [hostView release];hostView=nil;
    [reverseDic release];reverseDic=nil;
    
    [_forecastDefaultPoints release];_forecastDefaultPoints=nil;
    [_forecastPoints release];_forecastPoints=nil;
    [_hisPoints release];_hisPoints=nil;
    [_dividingPoints release];_dividingPoints=nil;
    [_jsonForChart release];_jsonForChart=nil;
    [_industryClass release];_industryClass=nil;
    [_standard release];_standard=nil;
    
    [forecastLinePlot release];forecastLinePlot=nil;
    [forecastDefaultLinePlot release];forecastDefaultLinePlot=nil;
    [historyLinePlot release];historyLinePlot=nil;
    [dividingLinePlot release];dividingLinePlot=nil;
    [barPlot release];barPlot=nil;
    
    [webView release];webView=nil;
    [priceLabel release];priceLabel=nil;
    
    [super dealloc];
}



-(void)applicationDidFinishLaunching:(UIApplication *)application{
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
    linkage=YES;
    
    webView=[[UIWebView alloc] init];
    webView.delegate=self;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"calu" ofType:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath: path]]];

    
    self.forecastPoints=[[NSMutableArray alloc] init];
    self.hisPoints=[[NSMutableArray alloc] init];
    self.dividingPoints=[[NSMutableArray alloc] init];
    self.forecastDefaultPoints=[[NSMutableArray alloc] init];
    self.standard=[[NSMutableArray alloc] init];
    
    reverseDic=[[NSMutableDictionary alloc] init];
    NSUInteger i;
    for(i=3;i<NUM;i++){
        id x=[NSNumber numberWithFloat:0];
        id y=[NSNumber numberWithFloat:3];
        [reverseDic setObject:y forKey:[NSString stringWithFormat:@"%.0f",[x floatValue]]];
        [self.forecastPoints addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x,@"x",y,@"y",nil]];
    }
    
    
    for(i=0;i<3;i++){
        id x=[NSNumber numberWithFloat:0];
        id y=[NSNumber numberWithFloat:0];
        [self.hisPoints addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x,@"x",y,@"y",nil]];
    }
    
    for(i=0;i<10;i++){
        id x=[NSNumber numberWithFloat:12.0];
        id y=[NSNumber numberWithFloat:0.1*i];
        [self.dividingPoints addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x,@"x",y,@"y",nil]];
    }
    
    //初始化图形视图
    @try {
        graph=[[CPTXYGraph alloc] initWithFrame:CGRectZero];
        CPTTheme *theme=[CPTTheme themeNamed:kCPTDarkGradientTheme];
        [graph applyTheme:theme];
        
        hostView=[[ CPTGraphHostingView alloc ] initWithFrame :CGRectMake(0,HOSTVIEWTOPPAD,320,480-HOSTVIEWBOTTOMPAD-HOSTVIEWTOPPAD) ];
        [self.view addSubview:hostView];
        
        [hostView setHostedGraph : graph ];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
    // CPGraph 四边不留白
    graph . paddingLeft = 0.0f ;
    graph . paddingRight = 0.0f ;
    graph . paddingTop = GRAPAHTOPPAD ;
    graph . paddingBottom = GRAPAHBOTTOMPAD ;
    // 绘图区 4 边留白
    graph . plotAreaFrame . paddingLeft = 0.0 ;
    graph . plotAreaFrame . paddingTop = 0.0 ;
    graph . plotAreaFrame . paddingRight = 0.0 ;
    graph . plotAreaFrame . paddingBottom = 00.0 ;
    
    graph.title=@"股票估值";
    CPTMutableTextStyle *textStyle = [CPTTextStyle textStyle];
    textStyle.color                   = [CPTColor grayColor];
    textStyle.fontSize                = 16.0f;
    textStyle.textAlignment           = CPTTextAlignmentCenter;
    graph.titleTextStyle           = textStyle;
    graph.titleDisplacement        = CGPointMake(0.0f, -20.0f);
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    
    
    //绘制图形空间
    CPTXYPlotSpace *plotSpace=(CPTXYPlotSpace *)graph.defaultPlotSpace;
    //plotSpace.allowsUserInteraction=YES;
    
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
    lineStyle.lineColor = [CPTColor colorWithComponentRed:255/255.0 green:211/255.0 blue:155/255.0 alpha:1.0];
    
    x.majorIntervalLength=CPTDecimalFromFloat(XINTERVALLENGTH);
    x.orthogonalCoordinateDecimal=CPTDecimalFromFloat(XORTHOGONALCOORDINATE);
    x.minorTicksPerInterval=XTICKSPERINTERVAL;
    x.minorTickLineStyle = lineStyle;
    
    CPTXYAxis *y=axisSet.yAxis;
    y.majorIntervalLength=CPTDecimalFromFloat(YINTERVALLENGTH);
    y.orthogonalCoordinateDecimal=CPTDecimalFromFloat(YORTHOGONALCOORDINATE);
    y.minorTicksPerInterval=YTICKSPERINTERVAL;
    y.minorTickLineStyle = lineStyle;
    
    
    priceLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,160,40)];
    priceLabel.text=@"here";
    [self.view addSubview:priceLabel];
    
    UIButton *scatterButton=[UIButton buttonWithType:UIButtonTypeCustom];
    scatterButton.frame=CGRectMake(160,0,80,40);
    [scatterButton setTitle:@"联动" forState:UIControlStateNormal];
    scatterButton.backgroundColor=[Utiles colorWithHexString:@"#323232"];
    scatterButton.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    [scatterButton addTarget:self action:@selector(addScatterChart:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:scatterButton];
    [scatterButton release];
    
    UIButton *barButton=[UIButton buttonWithType:UIButtonTypeCustom];
    barButton.frame=CGRectMake(240,0,80,40);
    [barButton setTitle:@"点动" forState:UIControlStateNormal];
    barButton.backgroundColor=[Utiles colorWithHexString:@"#323232"];
    barButton.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    [barButton addTarget:self action:@selector(addBarChart:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:barButton];
    [barButton release];
    
    UIButton *backButton=[UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame=CGRectMake(320,0,80,40);
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    backButton.backgroundColor=[Utiles colorWithHexString:@"#323232"];
    backButton.titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:14.0f];
    [backButton addTarget:self action:@selector(backTo:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:backButton];
    [backButton release];
    
    [self addScatterChart:scatterButton];
    
    //手势添加
    UIPanGestureRecognizer *panGr=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewPan:)];
    [hostView addGestureRecognizer:panGr];
    [panGr release];
    

}

-(void)backTo:(UIButton *)bt{
    
    bt.showsTouchWhenHighlighted=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)addBarChart:(UIButton *)bt{

    bt.showsTouchWhenHighlighted=YES;
    
    if(![graph plotWithIdentifier:COLUMNAR_DATALINE_IDENTIFIER]){

        // First bar plot
        barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor colorWithComponentRed:105/255.0 green:195/255.0 blue:228/255.0 alpha:1.0] horizontalBars:NO];
        barPlot.baseValue  = CPTDecimalFromString(@"0");
        barPlot.dataSource = self;
        barPlot.barOffset  = CPTDecimalFromFloat(-0.5f);
        barPlot.identifier = COLUMNAR_DATALINE_IDENTIFIER;
        barPlot.barWidthsAreInViewCoordinates=0.1f;
        [graph addPlot:barPlot];
        linkage=NO;
        [barPlot release];
    }
   
}

-(void)addScatterChart:(UIButton *)bt{

    bt.showsTouchWhenHighlighted=YES;
    
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
        forecastLinePlot.dataSource=self;//需实现委托
        
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
        
        
        //创建分隔线段
        lineStyle.lineColor=[CPTColor grayColor];
        dividingLinePlot = [[CPTScatterPlot alloc] init];
        dividingLinePlot.dataLineStyle = lineStyle;
        dividingLinePlot.identifier =DIVIDING_DATALINE_IDENTIFIER;
        dividingLinePlot.dataSource = self;
        
        
        // Add plot symbols: 表示数值的符号的形状
        //
        CPTMutableLineStyle * symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = [CPTColor colorWithComponentRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1.0];
        symbolLineStyle.lineWidth = 2.0;
        
        CPTPlotSymbol * plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        //plotSymbol.fill          = [CPTFill fillWithColor: [CPTColor colorWithComponentRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:1.0]];
        plotSymbol.lineStyle     = symbolLineStyle;
        plotSymbol.size          = CGSizeMake(1.8, 1.8);
        
        forecastLinePlot.plotSymbol = plotSymbol;
        historyLinePlot.plotSymbol=plotSymbol;
        
        
        // Animate in the new plot: 淡入动画
        forecastLinePlot.opacity = 0.0f;
        historyLinePlot.opacity=0.0f;
        CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        fadeInAnimation.duration            = 3.0f;
        fadeInAnimation.removedOnCompletion = NO;
        fadeInAnimation.fillMode            = kCAFillModeForwards;
        fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
        [forecastLinePlot addAnimation:fadeInAnimation forKey:@"shadowOffset"];
        [historyLinePlot addAnimation:fadeInAnimation forKey:@"shadowOffset"];
        [dividingLinePlot addAnimation:fadeInAnimation forKey:@"shadowOffset"];
        
        [graph addPlot:forecastLinePlot];
        [graph addPlot:forecastDefaultLinePlot];    
        [graph addPlot:historyLinePlot];
        [graph addPlot:dividingLinePlot];
        
        
        [forecastDefaultLinePlot release];
        [forecastLinePlot release];
        [historyLinePlot release];
        [dividingLinePlot release];
        
    }
 
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *clientUrl = @"http://www.googuu.net/services/data/companyModel/getData.do?stockCode=03331";
    
    [MBProgressHUD showHUDAddedTo:self.hostView animated:YES];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:clientUrl]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.jsonForChart=[operation responseString];
        self.jsonForChart=[self.jsonForChart stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\\\\\""];
        self.jsonForChart=[self.jsonForChart stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        
        //获取股票种类
        NSString *arg=[[NSString alloc] initWithFormat:@"initData(\"%@\")",self.jsonForChart];        
        NSString *re=[self.webView stringByEvaluatingJavaScriptFromString:arg];

        re=[re stringByReplacingOccurrencesOfString:@",]" withString:@"]"];

        self.industryClass=[re objectFromJSONString];

        //获取对应折线信息,将历史数据与预测数据分组
        [self.hisPoints removeAllObjects];
        [self.forecastDefaultPoints removeAllObjects];
        [self.forecastPoints removeAllObjects];
        //构造折点数据键值对 key：年份 value：估值 方便后面做临近折点的判断
        [self.reverseDic removeAllObjects];
        arg=[NSString stringWithFormat:@"returnChartData(\"%@\")",@"1362"];
        re=[self.webView stringByEvaluatingJavaScriptFromString:arg];
        re=[re stringByReplacingOccurrencesOfString:@",]" withString:@"]"];
        id charData=[re objectFromJSONString];
        NSMutableDictionary *mutableObj=nil;
        for(id obj in charData){
            
            mutableObj=[[NSMutableDictionary alloc] initWithDictionary:obj];
            
            if([[mutableObj objectForKey:@"h"] boolValue]){
                [self.hisPoints addObject:mutableObj];
            }else{
                [self.forecastPoints addObject:mutableObj];
                [self.forecastDefaultPoints addObject:[[mutableObj mutableCopy] autorelease]];
                [reverseDic setObject:[mutableObj objectForKey:@"v"] forKey:[NSString stringWithFormat:@"%.0f",[[mutableObj objectForKey:@"y"] floatValue]]];
            }
            
        }
        [mutableObj release];
        [reverseDic setObject:[[self.hisPoints objectAtIndex:[self.hisPoints count]-1] objectForKey:@"v"] forKey:[NSString stringWithFormat:@"%.0f",[[[self.hisPoints objectAtIndex:[self.hisPoints count]-1] objectForKey:@"y"] floatValue]]];
        [self.forecastPoints insertObject:[self.hisPoints objectAtIndex:[self.hisPoints count]-1] atIndex:0];
        [self.forecastDefaultPoints insertObject:[self.hisPoints objectAtIndex:[self.hisPoints count]-1] atIndex:0];
        [graph reloadData];
        [MBProgressHUD hideHUDForView:self.hostView animated:YES];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
    }];
    [operation start];
    
    
    
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
        
        newLayer=[[[CPTTextLayer alloc] initWithText:[[[NSString alloc] initWithFormat:@"%0.2f",[[[self.forecastPoints objectAtIndex:index] objectForKey:@"v"] doubleValue]] autorelease] style:whiteText] autorelease];
        
    }else if([identifier isEqualToString : HISTORY_DATALINE_IDENTIFIER]){
        
        newLayer=[[[CPTTextLayer alloc] initWithText:[[[NSString alloc] initWithFormat:@"%0.2f",[[[self.hisPoints objectAtIndex:index] objectForKey:@"v"] doubleValue]] autorelease] style:whiteText] autorelease];
        
    }
    return newLayer;
}



//散点数据源委托实现
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    
    if([(NSString *)plot.identifier isEqualToString:DIVIDING_DATALINE_IDENTIFIER]){
        return [self.dividingPoints count];
    }else if([(NSString *)plot.identifier isEqualToString:FORECAST_DEFAULT_DATALINE_IDENTIFIER]){
        return [self.forecastDefaultPoints count];
    }else if([(NSString *)plot.identifier isEqualToString:HISTORY_DATALINE_IDENTIFIER]){
        return [self.hisPoints count];
    }else if([(NSString *)plot.identifier isEqualToString:FORECAST_DATALINE_IDENTIFIER]){
        return [self.forecastPoints count];
    }else if([(NSString *)plot.identifier isEqualToString:COLUMNAR_DATALINE_IDENTIFIER]){
        return [self.forecastPoints count];
    }
    
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger) index{

    NSNumber *num=nil;
    

    if([(NSString *)plot.identifier isEqualToString:DIVIDING_DATALINE_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
        num=[[self.dividingPoints objectAtIndex:index] valueForKey:key];
        

    }else if([(NSString *)plot.identifier isEqualToString:HISTORY_DATALINE_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
        //num=[[self.hisPoints objectAtIndex:index] valueForKey:key];
        
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


-(void)viewPan:(UIPanGestureRecognizer *)tapGr
{
    CGPoint now=[tapGr locationInView:self.view];
    
    CGPoint change=[tapGr translationInView:self.view];
    

    if(change.x<-FINGERCHANGEDISTANCE){
        
        [(MHTabBarController *)self.parentViewController.parentViewController setSelectedIndex:2 animated:YES];
        
    }else if(change.x>FINGERCHANGEDISTANCE){
        
        [(MHTabBarController *)self.parentViewController.parentViewController setSelectedIndex:0 animated:YES];
        
    }

    
    else{
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
        }
        //手势变化并且接近折点旁边
        if([tapGr state]==UIGestureRecognizerStateChanged&&[self isNearByThePoint:now]){
          
            //[reverseDic removeAllObjects];
            coordinate.x=(int)(coordinate.x+0.5);
            coordinate.x=(int)(coordinate.x+0.5);
            
            coordinate.x=coordinate.x>=23?22:coordinate.x;
            coordinate.x=coordinate.x<=11?12:coordinate.x;
            
            NSAssert(coordinate.x<23&&coordinate.x>11,@"coordiante.x must less than 23");
            
            if(linkage){

                //NSLog(@"%@",[self.forecastPoints JSONString]);
                double l4 = YRANGELENGTH*change.y/hostView.frame.size.height/ (1 - exp(-2));
                //double l5 = [[[self.hisPoints objectAtIndex:[self.hisPoints count]-1] objectForKey:@"y"] doubleValue];
                double l7 = 2 / ([[[self.forecastPoints objectAtIndex:(coordinate.x-XRANGEBEGIN-[self.hisPoints count])] objectForKey:@"y"] doubleValue]);
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
                double v=[[self.standard objectAtIndex:(coordinate.x-XRANGEBEGIN-3)] doubleValue]+changeD;
                [[self.forecastPoints objectAtIndex:(coordinate.x-XRANGEBEGIN-3)] setObject:[NSNumber numberWithDouble:v] forKey:@"v"];
                
                [self setStockPrice];
                [graph reloadData];
                
            }
            
        }
    }
   
    
}


-(void)setStockPrice{

    NSString *jsonPrice=[self.forecastPoints JSONString];
    jsonPrice=[jsonPrice stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *arg1=[[NSString alloc] initWithFormat:@"chartCalu(\"%@\")",jsonPrice];
    //传入数据注意格式调用，html文件的key值应与此key值对应
    NSString *re1=[self.webView stringByEvaluatingJavaScriptFromString:arg1];
    [self.priceLabel setText:[re1 substringWithRange:NSMakeRange(0, 5)]];
}


//判断手指触摸点是否在折点旁边
-(BOOL)isNearByThePoint:(CGPoint)p{
    
    //从手指触摸点的实际坐标得到抽象坐标
    /*CGPoint abstractCoordinate=[self CoordinateTransformRealToAbstract:p];
    //获取临近坐标点
    int acX=(int)(abstractCoordinate.x+0.5);
    //判断临近坐标点是否存在折点，存在则取出
    float acY=[[reverseDic objectForKey:[NSString stringWithFormat:@"%d",acX]] floatValue];
    
    //构造临近坐标折点，并转化为实际屏幕坐标点
    CGPoint temp=[self CoordinateTransformAbstractToReal:CGPointMake([[NSNumber numberWithInt:acX] floatValue], acY)];
    //计算临近坐标点与手指触摸点的距离
    double distance=sqrt(pow((p.x-temp.x),2)+pow((p.y-temp.y),2));
    
    //NSLog(@"%f",distance);
    //return distance>50?NO:YES;*/
    return  YES;
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    //NSLog(@"chart willAnimateRotationToInterfaceOrientation");
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        //[self.navigationController.navigationBar setHidden:YES];
        //self.hostView.frame=CGRectMake(0,HOSTVIEWTOPPAD,320,480-HOSTVIEWBOTTOMPAD-HOSTVIEWTOPPAD);
    } else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        self.hostView.frame=CGRectMake(20,40,480,320);
    }
}

-(NSUInteger)supportedInterfaceOrientations{

    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    return NO;
}


@end

















//
//  FinancalModelChartViewController.m
//  估股
//
//  Created by Xcode on 13-8-1.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "FinancalModelChartViewController.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "math.h"
#import <AddressBook/AddressBook.h>
#import "MBProgressHUD.h"
#import "XYZAppDelegate.h"
#import "TSPopoverController.h"
#import "PrettyNavigationController.h"
#import "CQMFloatingController.h"
#import "DrawChartTool.h"
#import "ModelClassViewController.h"
#import "ModelClassGrade2ViewController.h"


@interface FinancalModelChartViewController ()

@end

@implementation FinancalModelChartViewController

static NSString * BAR_IDENTIFIER =@"bar_identifier";

@synthesize comInfo;
@synthesize colorArr;
@synthesize points;
@synthesize jsonForChart;
@synthesize barPlot;
@synthesize yAxisUnit;
@synthesize webView;
@synthesize graph;
@synthesize hostView;
@synthesize plotSpace;
@synthesize modelRatioViewController;
@synthesize modelChartViewController;
@synthesize modelOtherViewController;
@synthesize financalTitleLabel;

- (void)dealloc
{
    SAFE_RELEASE(colorArr);
    SAFE_RELEASE(financalTitleLabel);
    SAFE_RELEASE(comInfo);
    [yAxisUnit release];yAxisUnit=nil;
    [modelRatioViewController release];modelRatioViewController=nil;
    [modelChartViewController release];modelChartViewController=nil;
    [modelOtherViewController release];modelOtherViewController=nil;
    [hostView release];hostView=nil;
    [points release];points=nil;
    [jsonForChart release];jsonForChart=nil;
    [barPlot release];barPlot=nil;
    [webView release];webView=nil;
    [graph release];graph=nil;
    [plotSpace release];plotSpace=nil;
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
    [self.view setBackgroundColor:[Utiles colorWithHexString:@"#F2EFE1"]];
    
    colorArr=@[@"e92058",@"b700b7",@"216dcb",@"13bbca",@"65d223",@"f09c32",@"f15a38"];
    
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    comInfo=delegate.comInfo;
    self.modelRatioViewController=[[ModelClassGrade2ViewController alloc] init];
    self.modelRatioViewController.delegate=self;
    self.modelChartViewController=[[ModelClassGrade2ViewController alloc] init];
    self.modelChartViewController.delegate=self;
    self.modelOtherViewController=[[ModelClassGrade2ViewController alloc] init];
    self.modelOtherViewController.delegate=self;
    self.modelRatioViewController.classTitle=@"财务比例";
    self.modelChartViewController.classTitle=@"财务图表";
    self.modelOtherViewController.classTitle=@"其它指标";
    
    webView=[[UIWebView alloc] init];
    webView.delegate=self;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"c" ofType:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath: path]]];    
    self.points=[[NSMutableArray alloc] init];
    
    [self initFinancalModelViewComponents];
    [self initBarChart];

}

-(void)initFinancalModelViewComponents{
    UIImageView *topBar=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dragChartBar"]];
    topBar.frame=CGRectMake(0,0,SCREEN_HEIGHT,40);
    [self.view addSubview:topBar];
    DrawChartTool *tool=[[DrawChartTool alloc] init];
    tool.standIn=self;
    
    UILabel *nameLabel=[tool addLabelToView:self.view withTitle:[NSString stringWithFormat:@"%@\n(%@.%@)",comInfo[@"companyname"],comInfo[@"stockcode"],comInfo[@"marketname"]] Tag:11 frame:CGRectMake(65,0,100, 40) fontSize:12.0 color:nil textColor:@"#3e2000" location:NSTextAlignmentCenter];
    nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
    nameLabel.numberOfLines = 0;
    
    financalTitleLabel=[tool addLabelToView:self.view withTitle:@"" Tag:11 frame:CGRectMake(0,40,SCREEN_HEIGHT,30) fontSize:12.0 color:nil textColor:@"#63573d" location:NSTextAlignmentCenter];
    
    
    [tool addButtonToView:self.view withTitle:@"财务比例" Tag:FinancialRatio frame:CGRectMake(165,5,100,31) andFun:@selector(selectIndustry:forEvent:) withType:UIButtonTypeRoundedRect andColor:@"#FFFEFE" textColor:@"#000000" normalBackGroundImg:@"ratioBt" highBackGroundImg:@"selectedRatioBt"];
    [tool addButtonToView:self.view withTitle:@"财务图表" Tag:FinancialChart frame:CGRectMake(265,5,100,31) andFun:@selector(selectIndustry:forEvent:) withType:UIButtonTypeRoundedRect andColor:@"#FFFEFE" textColor:@"#000000" normalBackGroundImg:@"chartBt" highBackGroundImg:@"selectedChartBt"];
    [tool addButtonToView:self.view withTitle:@"其它指标" Tag:FinancialOther frame:CGRectMake(365,5,100,31) andFun:@selector(selectIndustry:forEvent:) withType:UIButtonTypeRoundedRect andColor:@"#FFFEFE" textColor:@"#000000" normalBackGroundImg:@"otherBt" highBackGroundImg:@"selectedChartBt"];
    
    [tool addButtonToView:self.view withTitle:@"返回" Tag:FinancialBack frame:CGRectMake(10,5,50,32) andFun:@selector(backTo:) withType:UIButtonTypeCustom andColor:nil textColor:@"#FFFEFE" normalBackGroundImg:@"backBt" highBackGroundImg:nil];

    [tool release];
}

-(void)initBarChart{
    //初始化图形视图
    @try {
        graph=[[CPTXYGraph alloc] initWithFrame:CGRectZero];
        //CPTTheme *theme=[CPTTheme themeNamed:kCPTPlainWhiteTheme];
        //[graph applyTheme:theme];
        graph.fill=[CPTFill fillWithImage:[CPTImage imageWithCGImage:[UIImage imageNamed:@"discountBack"].CGImage]];
        //graph.cornerRadius  = 15.0f;        
        hostView=[[ CPTGraphHostingView alloc ] initWithFrame :CGRectMake(10,70,SCREEN_HEIGHT-20,220)];
        [self.view addSubview:hostView];
        [hostView setHostedGraph : graph ];
        hostView.collapsesLayers = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
    graph . paddingLeft = 0.0f ;
    graph . paddingRight = 0.0f ;
    graph . paddingTop = 0 ;
    graph . paddingBottom = 0 ;

    //绘制图形空间
    plotSpace=(CPTXYPlotSpace *)graph.defaultPlotSpace;
    DrawXYAxisWithoutYAxis;
    [self initBarPlot];
}

#pragma mark -
#pragma Button Clicked Methods

-(void)selectIndustry:(UIButton *)sender forEvent:(UIEvent*)event{
    
    sender.showsTouchWhenHighlighted=YES;
	CQMFloatingController *floatingController = [CQMFloatingController sharedFloatingController];
    floatingController.frameSize=CGSizeMake(280,280);
    floatingController.frameColor=[Utiles colorWithHexString:@"#e26b17"];
    if(sender.tag==FinancialRatio){
        [floatingController presentWithContentViewController:modelRatioViewController
                                                    animated:YES];
    }else if(sender.tag==FinancialChart){
        [floatingController presentWithContentViewController:modelChartViewController
                                                    animated:YES];
    }else if(sender.tag==FinancialOther){
        [floatingController presentWithContentViewController:modelOtherViewController
                                                    animated:YES];
    }
    
}

-(void)backTo:(UIButton *)bt{
    
    bt.showsTouchWhenHighlighted=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(id)getObjectDataFromJsFun:(NSString *)funName byData:(NSString *)data{
    NSString *arg=[[NSString alloc] initWithFormat:@"%@(\"%@\")",funName,data];
    NSString *re=[self.webView stringByEvaluatingJavaScriptFromString:arg];
    re=[re stringByReplacingOccurrencesOfString:@",]" withString:@"]"];
    SAFE_RELEASE(arg);
    return [re objectFromJSONString];
}

#pragma mark -
#pragma mark ModelClass Methods Delegate
-(void)modelClassChanged:(NSString *)driverId{
    
    id temp=[self getObjectDataFromJsFun:@"returnChartData" byData:driverId];
    NSMutableArray *tempHisPoints=[[NSMutableArray alloc] init];
    for(id obj in temp[@"array"]){
        if([obj[@"h"] boolValue]){
            [tempHisPoints addObject:obj];
        }
    }
    self.points=tempHisPoints;
    self.yAxisUnit=temp[@"unit"];
    NSDictionary *pointData=[Utiles unitConversionData:[(self.points)[0][@"v"] stringValue] andUnit:self.yAxisUnit];
    self.financalTitleLabel.text=[NSString stringWithFormat:@"%@(单位:%@)",temp[@"title"],pointData[@"unit"]];
    [self setXYAxis];
    barPlot.baseValue=CPTDecimalFromFloat(XORTHOGONALCOORDINATE);
    [graph reloadData];
    SAFE_RELEASE(tempHisPoints);
    
}

#pragma mark -
#pragma mark Web Didfinished CallBack
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [MBProgressHUD showHUDAddedTo:self.hostView animated:YES];
    //[MBProgressHUD showHUDAddedTo:self.hostView animated:YES];
    NSDictionary *params=@{@"stockCode": comInfo[@"stockcode"]};
    [Utiles getNetInfoWithPath:@"CompanyModel" andParams:params besidesBlock:^(id resObj){
        
        self.jsonForChart=[resObj JSONString];
        self.jsonForChart=[self.jsonForChart stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\\\\\""];
        self.jsonForChart=[self.jsonForChart stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        
        //获取金融模型种类
        id transObj=[self getObjectDataFromJsFun:@"initFinancialData" byData:self.jsonForChart];
        
        self.modelRatioViewController.jsonData=transObj;
        self.modelChartViewController.jsonData=transObj;
        self.modelOtherViewController.jsonData=transObj;
        self.modelRatioViewController.indicator=@"listRatio";
        self.modelChartViewController.indicator=@"listChart";
        self.modelOtherViewController.indicator=@"listOther";
        
        [self modelClassChanged:transObj[@"listRatio"][0][@"id"]];
        barPlot.baseValue=CPTDecimalFromFloat(XORTHOGONALCOORDINATE);
        [MBProgressHUD hideHUDForView:self.hostView animated:YES];

    }];
    
    
}


#pragma mark -
#pragma mark Bar Data Source Delegate

// 添加数据标签
-( CPTLayer *)dataLabelForPlot:( CPTPlot *)plot recordIndex:( NSUInteger )index
{
    static CPTMutableTextStyle *whiteText = nil ;
    if ( !whiteText ) {
        whiteText = [[ CPTMutableTextStyle alloc ] init ];
        whiteText.color=[CPTColor blackColor];
        whiteText.fontSize=9.0;
        whiteText.fontName=@"Heiti SC";
    }

    CPTTextLayer *newLayer = nil ;
    NSString *numberString =nil;
    if([self.yAxisUnit isEqualToString:@"%"]){
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterPercentStyle];
        numberString = [formatter stringFromNumber:@([(self.points)[index][@"v"] floatValue])];
        SAFE_RELEASE(formatter);
    }else{
        numberString=[(self.points)[index][@"v"] stringValue];
        NSDictionary *pointData=[Utiles unitConversionData:numberString andUnit:self.yAxisUnit];
        numberString=pointData[@"result"];
    }
    newLayer=[[CPTTextLayer alloc] initWithText:numberString style:whiteText];
    return [newLayer autorelease];
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    return [self.points count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger) index{
    
    NSNumber *num=nil;
    
    if([(NSString *)plot.identifier isEqualToString:BAR_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
        
        if([key isEqualToString:@"x"]){
            num=@([(self.points)[index][@"y"] intValue]);
        }else if([key isEqualToString:@"y"]){
            num=@([(self.points)[index][@"v"] floatValue]);
        }
        
    }
    
    return num;
}

#pragma mark -
#pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    if(axis.coordinate==CPTCoordinateX){
        
        NSNumberFormatter * formatter   = (NSNumberFormatter *)axis.labelFormatter;
        // axis.fillMode=@"132";
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        //[formatter setPositiveFormat:@"0.00%;0.00%;-0.00%"];
        [formatter setPositiveFormat:@"##"];
        //CGFloat labelOffset             = axis.labelOffset;
        NSMutableSet * newLabels        = [NSMutableSet set];
        static CPTTextStyle * positiveStyle = nil;
        for (NSDecimalNumber * tickLocation in locations) {
            CPTTextStyle *theLabelTextStyle;
            
            CPTMutableTextStyle * newStyle = [axis.labelTextStyle mutableCopy];
            newStyle.fontSize=11.0;
            newStyle.fontName=@"Heiti SC";
            newStyle.color=[CPTColor colorWithComponentRed:153/255.0 green:129/255.0 blue:64/255.0 alpha:1.0];
            positiveStyle  = newStyle;
            
            theLabelTextStyle = positiveStyle;
            
            NSString * labelString      = [formatter stringForObjectValue:tickLocation];
            labelString=[Utiles yearFilled:labelString];
            CPTTextLayer * newLabelLayer= [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
            CPTAxisLabel * newLabel     = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
            newLabel.tickLocation       = tickLocation.decimalValue;
            newLabel.offset             = 3.0;
            //newLabel.rotation     = 5.5;
            //newLabel.font=[UIFont fontWithName:@"Heiti SC" size:13.0];
            [newLabels addObject:newLabel];
            SAFE_RELEASE(newLabel);
            SAFE_RELEASE(newLabelLayer);
        }
        
        axis.axisLabels = newLabels;
    }else{
        
    }
    
    
    return NO;
}

-(void)initBarPlot{
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.miterLimit=0.0f;
    lineStyle.lineWidth=0.0f;
    lineStyle.lineColor=[CPTColor colorWithComponentRed:87/255.0 green:168/255.0 blue:9/255.0 alpha:1.0];
    barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor colorWithComponentRed:134/255.0 green:171/255.0 blue:125/255.0 alpha:1.0] horizontalBars:NO];
    barPlot. dataSource = self ;
    barPlot.delegate=self;
    barPlot.lineStyle=lineStyle;
    barPlot.fill=[CPTFill fillWithColor:[Utiles cptcolorWithHexString:colorArr[arc4random()%7] andAlpha:0.6]];
    // 图形向右偏移： 0.25
    barPlot.barOffset = CPTDecimalFromFloat(0.0f) ;
    // 在 SDK 中， barCornerRadius 被 cornerRadius 替代
    barPlot.barCornerRadius=3.0;
    barPlot.barWidth=CPTDecimalFromFloat(1.0f);
    barPlot.barWidthScale=0.5f;
    barPlot.labelOffset=0;
    barPlot.identifier = BAR_IDENTIFIER;
    barPlot.opacity=0.0f;
    
    
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 3.0f;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = @1.0f;
    [barPlot addAnimation:fadeInAnimation forKey:@"shadowOffset"];
    // 添加图形到绘图空间
    [graph addPlot :barPlot toPlotSpace :plotSpace];
}

-(void)setXYAxis{
    NSMutableArray *xTmp=[[NSMutableArray alloc] init];
    NSMutableArray *yTmp=[[NSMutableArray alloc] init];
    for(id obj in self.points){
        [xTmp addObject:obj[@"y"]];
        [yTmp addObject:obj[@"v"]];
    }
    NSDictionary *xyDic=[DrawChartTool getXYAxisRangeFromxArr:xTmp andyArr:yTmp fromWhere:FinancalModel];
    XRANGEBEGIN=[xyDic[@"xBegin"] floatValue];
    XRANGELENGTH=[xyDic[@"xLength"] floatValue];
    XORTHOGONALCOORDINATE=[xyDic[@"xOrigin"] floatValue];
    XINTERVALLENGTH=[xyDic[@"xInterval"] floatValue];
    YRANGEBEGIN=[xyDic[@"yBegin"] floatValue];
    YRANGELENGTH=[xyDic[@"yLength"] floatValue];
    YORTHOGONALCOORDINATE=[xyDic[@"yOrigin"] floatValue];
    YINTERVALLENGTH=[xyDic[@"yInterval"] floatValue];
    DrawXYAxisWithoutYAxis;
    SAFE_RELEASE(xTmp);
    SAFE_RELEASE(yTmp);
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        self.hostView.frame=CGRectMake(10,70,SCREEN_HEIGHT-20,220);
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
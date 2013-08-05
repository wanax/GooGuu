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
#import "JSONKit.h"
#import "Utiles.h"
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


@synthesize points;
@synthesize jsonForChart;
@synthesize barPlot;
@synthesize webView;
@synthesize graph;
@synthesize hostView;
@synthesize plotSpace;
@synthesize modelRatioViewController;
@synthesize modelChartViewController;
@synthesize modelOtherViewController;

- (void)dealloc
{
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
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    self.modelRatioViewController=[[ModelClassGrade2ViewController alloc] init];
    self.modelRatioViewController.delegate=self;
    self.modelChartViewController=[[ModelClassGrade2ViewController alloc] init];
    self.modelChartViewController.delegate=self;
    self.modelOtherViewController=[[ModelClassGrade2ViewController alloc] init];
    self.modelOtherViewController.delegate=self;
    
    XRANGEBEGIN=9.0;
    XRANGELENGTH=14.0;
    YRANGEBEGIN=-0.3;
    YRANGELENGTH=0.9;
    
    XINTERVALLENGTH=3.0;
    XORTHOGONALCOORDINATE=0.0;
    XTICKSPERINTERVAL=0;
    
    YINTERVALLENGTH= 0.1;
    YORTHOGONALCOORDINATE =11.0;
    YTICKSPERINTERVAL =0;
    
    webView=[[UIWebView alloc] init];
    webView.delegate=self;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"c" ofType:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath: path]]];
    
    self.points=[[NSMutableArray alloc] init];
	
    //初始化图形视图
    @try {
        graph=[[CPTXYGraph alloc] initWithFrame:CGRectZero];
        CPTTheme *theme=[CPTTheme themeNamed:kCPTSlateTheme];
        [graph applyTheme:theme];
        graph.cornerRadius  = 0.0f;
        
        hostView=[[ CPTGraphHostingView alloc ] initWithFrame :CGRectMake(0,40,480,280)];
        [self.view addSubview:hostView];
        [hostView setHostedGraph : graph ];
        hostView.collapsesLayers = YES;
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
    
    graph . paddingLeft = 0.0f ;
    graph . paddingRight = 0.0f ;
    graph . paddingTop = GRAPAHTOPPAD ;
    graph . paddingBottom = 20 ;

    
    graph.title=@"金融模型";
    //绘制图形空间
    plotSpace=(CPTXYPlotSpace *)graph.defaultPlotSpace;
    //plotSpace.allowsUserInteraction=YES;
    
    DrawXYAxis;
    [self initBarPlot];
    DrawChartTool *tool=[[DrawChartTool alloc] init];
    tool.standIn=self;
    [tool addButtonToView:self.view withTitle:@"财务比例" Tag:1 frame:CGRectMake(160,0,80,40) andFun:@selector(selectIndustry:forEvent:)];
    [tool addButtonToView:self.view withTitle:@"财务图表" Tag:2 frame:CGRectMake(240,0,80,40) andFun:@selector(selectIndustry:forEvent:)];
    [tool addButtonToView:self.view withTitle:@"其它指标" Tag:3 frame:CGRectMake(320,0,80,40) andFun:@selector(selectIndustry:forEvent:)];
    [tool addButtonToView:self.view withTitle:@"返回" Tag:4 frame:CGRectMake(400,0,80,40) andFun:@selector(backTo:)];
    [tool release];
    
}

#pragma mark -
#pragma Button Clicked Methods

-(void)selectIndustry:(UIButton *)sender forEvent:(UIEvent*)event{

    sender.showsTouchWhenHighlighted=YES;
	CQMFloatingController *floatingController = [CQMFloatingController sharedFloatingController];
    floatingController.frameSize=CGSizeMake(280,280);
    floatingController.frameColor=[Utiles colorWithHexString:@"#8cb990"];
    if(sender.tag==1){
        [floatingController presentWithContentViewController:modelRatioViewController
                                                    animated:YES];
    }else if(sender.tag==2){
        [floatingController presentWithContentViewController:modelChartViewController
                                                    animated:YES];
    }else if(sender.tag==3){
        [floatingController presentWithContentViewController:modelOtherViewController
                                                    animated:YES];
    }
	
}

-(void)backTo:(UIButton *)bt{
    
    bt.showsTouchWhenHighlighted=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark -
#pragma mark ModelClass Methods Delegate
-(void)modelClassChanged:(NSString *)driverId{

    NSString *arg=[[NSString alloc] initWithFormat:@"returnChartData(\"%@\")",driverId];
    NSString *re=[self.webView stringByEvaluatingJavaScriptFromString:arg];
    re=[re stringByReplacingOccurrencesOfString:@",]" withString:@"]"];
    id temp=[re objectFromJSONString];

    self.points=[temp objectForKey:@"array"];
    graph.title=[temp objectForKey:@"title"];    
    [self setXYAxis];
    barPlot.baseValue=CPTDecimalFromFloat(XORTHOGONALCOORDINATE);
    [graph reloadData];
    
}

#pragma mark -
#pragma mark Web Didfinished CallBack
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    id comInfo=delegate.comInfo;
    //[MBProgressHUD showHUDAddedTo:self.hostView animated:YES];
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[comInfo objectForKey:@"stockcode"],@"stockCode", nil];
    [Utiles getNetInfoWithPath:@"CompanyModel" andParams:params besidesBlock:^(id resObj){
        
        self.jsonForChart=[resObj JSONString];
        self.jsonForChart=[self.jsonForChart stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\\\\\""];
        self.jsonForChart=[self.jsonForChart stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        
        //获取金融模型种类
        NSString *arg=[[NSString alloc] initWithFormat:@"initFinancialData(\"%@\")",self.jsonForChart];
        NSString *re=[self.webView stringByEvaluatingJavaScriptFromString:arg];
        re=[re stringByReplacingOccurrencesOfString:@",]" withString:@"]"];
        id transObj=[re objectFromJSONString];
        self.modelRatioViewController.jsonData=transObj;
        self.modelChartViewController.jsonData=transObj;
        self.modelOtherViewController.jsonData=transObj;
        self.modelRatioViewController.indicator=@"listRatio";
        self.modelChartViewController.indicator=@"listChart";
        self.modelOtherViewController.indicator=@"listOther";
        
        arg=[[NSString alloc] initWithFormat:@"returnChartData(\"%@\")",@"4278"];
        re=[self.webView stringByEvaluatingJavaScriptFromString:arg];
        re=[re stringByReplacingOccurrencesOfString:@",]" withString:@"]"];
        id temp=[re objectFromJSONString];
        self.points=[temp objectForKey:@"array"];
        graph.title=[temp objectForKey:@"title"];
        
        [graph reloadData];
        
    }];
    
    
}

#pragma mark -
#pragma mark Bar Methods Delegate
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx{
    
}



#pragma mark -
#pragma mark Bar Data Source Delegate

//散点数据源委托实现
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    
    if([(NSString *)plot.identifier isEqualToString:BAR_IDENTIFIER]){
        return [self.points count];
    }
    
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger) index{
    
    NSNumber *num=nil;
    
    if([(NSString *)plot.identifier isEqualToString:BAR_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
        
        if([key isEqualToString:@"x"]){
            num=[NSNumber numberWithInt:[[[self.points objectAtIndex:index] objectForKey:@"y"] intValue]];
        }else if([key isEqualToString:@"y"]){
            num=[NSNumber numberWithFloat:[[[self.points objectAtIndex:index] objectForKey:@"v"] floatValue]];
        }
        
    }
    
    return num;
}


-(void)initBarPlot{
    barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor colorWithComponentRed:134/255.0 green:171/255.0 blue:125/255.0 alpha:1.0] horizontalBars:NO];
    barPlot. dataSource = self ;
    barPlot.delegate=self;
    barPlot.fill=[CPTFill fillWithColor:[CPTColor colorWithComponentRed:134/255.0 green:171/255.0 blue:125/255.0 alpha:1.0]];
    // 图形向右偏移： 0.25
    barPlot.barOffset = CPTDecimalFromFloat(0.0f) ;
    // 在 SDK 中， barCornerRadius 被 cornerRadius 替代
    barPlot.barWidth=CPTDecimalFromFloat(1.0f);
    barPlot.barWidthScale=0.5f;
    barPlot. identifier = BAR_IDENTIFIER;
    barPlot.opacity = 0.0f;
    barPlot.opacity=0.0f;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 3.0f;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
    [barPlot addAnimation:fadeInAnimation forKey:@"shadowOffset"];
    // 添加图形到绘图空间
    [graph addPlot :barPlot toPlotSpace :plotSpace];
}

-(void)setXYAxis{
    NSMutableArray *xTmp=[[NSMutableArray alloc] init];
    NSMutableArray *yTmp=[[NSMutableArray alloc] init];
    for(id obj in self.points){
        [xTmp addObject:[obj objectForKey:@"y"]];
        [yTmp addObject:[obj objectForKey:@"v"]];
    }
    NSDictionary *xyDic=[DrawChartTool getXYAxisRangeFromxArr:xTmp andyArr:yTmp ToWhere:NO];
    XRANGEBEGIN=[[xyDic objectForKey:@"xBegin"] floatValue];
    XRANGELENGTH=[[xyDic objectForKey:@"xLength"] floatValue];
    XORTHOGONALCOORDINATE=[[xyDic objectForKey:@"xOrigin"] floatValue];
    XINTERVALLENGTH=[[xyDic objectForKey:@"xInterval"] floatValue];
    YRANGEBEGIN=[[xyDic objectForKey:@"yBegin"] floatValue];
    YRANGELENGTH=[[xyDic objectForKey:@"yLength"] floatValue];
    YORTHOGONALCOORDINATE=[[xyDic objectForKey:@"yOrigin"] floatValue];
    YINTERVALLENGTH=[[xyDic objectForKey:@"yInterval"] floatValue];
    DrawXYAxis;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        self.hostView.frame=CGRectMake(0,40,480,280);
        //self.graph.frame=CGRectMake(0,40,480,280);
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

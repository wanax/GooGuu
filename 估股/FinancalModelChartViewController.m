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
@synthesize modelClassViewController;

- (void)dealloc
{
    [modelClassViewController release];modelClassViewController=nil;
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
    self.modelClassViewController=[[ModelClassViewController alloc] init];
    XRANGEBEGIN=9.0;
    XRANGELENGTH=14.0;
    YRANGEBEGIN=-0.3;
    YRANGELENGTH=0.9;
    
    XINTERVALLENGTH=3.0;
    XORTHOGONALCOORDINATE=0.0;
    XTICKSPERINTERVAL=2;
    
    YINTERVALLENGTH= 0.1;
    YORTHOGONALCOORDINATE =11.0;
    YTICKSPERINTERVAL =2;
    
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
        
        hostView=[[ CPTGraphHostingView alloc ] initWithFrame :CGRectMake(0,40,480,280) ];
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
    
    graph.title=@"金融模型";
    //绘制图形空间
    plotSpace=(CPTXYPlotSpace *)graph.defaultPlotSpace;
    //plotSpace.allowsUserInteraction=YES;
    
    DrawXYAxis;
    [self initBarPlot];
    DrawChartTool *tool=[[DrawChartTool alloc] init];
    tool.standIn=self;
    [tool addButtonToView:self.view withTitle:@"行业选择" frame:CGRectMake(320,0,80,40) andFun:@selector(selectIndustry:forEvent:)];
    [tool addButtonToView:self.view withTitle:@"返回" frame:CGRectMake(400,0,80,40) andFun:@selector(backTo:)];
    [tool release];
    
}

#pragma mark -
#pragma Button Clicked Methods

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

#pragma mark -
#pragma mark ModelClassGrade2 Methods Delegate
-(void)modelClassChanged:(NSString *)value{
    
    NSLog(@"here");
    
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
        self.modelClassViewController.jsonData=[re objectFromJSONString];
        
        
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
        return 1;
    }
    
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger) index{
    
    NSNumber *num=nil;
    
    if([(NSString *)plot.identifier isEqualToString:BAR_IDENTIFIER]){
        
        NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
        
        if([key isEqualToString:@"x"]){
            num=[NSNumber numberWithInt:13];
        }else if([key isEqualToString:@"y"]){
            num=[NSNumber numberWithFloat:0.5];
        }
        
    }
    
    return num;
}


-(void)initBarPlot{
    barPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor colorWithComponentRed:153/255.0 green:100/255.0 blue:49/255.0 alpha:1.0] horizontalBars:NO];
    barPlot.baseValue  = CPTDecimalFromString(@"0");;
    barPlot. dataSource = self ;
    barPlot.delegate=self;
    // 柱子的起始基线：即最下沿的 y 坐标
    barPlot. baseValue = CPTDecimalFromString ( @"0" );
    barPlot.fill=[CPTFill fillWithColor:[CPTColor colorWithComponentRed:153/255.0 green:100/255.0 blue:49/255.0 alpha:1.0]];
    // 图形向右偏移： 0.25
    barPlot.barOffset = CPTDecimalFromFloat(0.0f) ;
    // 在 SDK 中， barCornerRadius 被 cornerRadius 替代
    barPlot.barWidth=CPTDecimalFromFloat(1.0f);
    barPlot.barWidthScale=0.5f;
    barPlot. identifier = BAR_IDENTIFIER;
    // 添加图形到绘图空间
    [graph addPlot :barPlot toPlotSpace :plotSpace];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        self.hostView.frame=CGRectMake(0,40,480,320);
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

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
#import "Toast+UIView.h"
#import "UIButton+BGColor.h"

@interface DahonValuationViewController ()

@end

@implementation DahonValuationViewController

@synthesize oneMonth;
@synthesize threeMonth;
@synthesize sixMonth;
@synthesize oneYear;
@synthesize lastMarkBt;
@synthesize titleLabel;

@synthesize daHonLinePlot;
@synthesize gooGuuLinePlot;
@synthesize historyLinePlot;

@synthesize jsonData;
@synthesize comInfo;
@synthesize dateArr;
@synthesize chartData;
@synthesize daHonIndexDateMap;
@synthesize daHonDataDic;
@synthesize daHonIndexSets;
@synthesize gooGuuIndexDateMap;
@synthesize gooGuuDataDic;
@synthesize gooGuuIndexSets;

@synthesize graph;
@synthesize hostView;
@synthesize plotSpace;

static NSString * DAHON_DATALINE_IDENTIFIER =@"dahon_dataline_identifier";
static NSString * GOOGUU_DATALINE_IDENTIFIER =@"googuu_dataline_identifier";
static NSString * HISTORY_DATALINE_IDENTIFIER =@"history_dataline_identifier";

- (void)dealloc
{
    SAFE_RELEASE(titleLabel);
    SAFE_RELEASE(lastMarkBt);
    SAFE_RELEASE(comInfo);
    SAFE_RELEASE(daHonIndexSets);
    SAFE_RELEASE(daHonIndexDateMap);
    SAFE_RELEASE(daHonDataDic);
    SAFE_RELEASE(gooGuuIndexDateMap);
    SAFE_RELEASE(gooGuuDataDic);
    SAFE_RELEASE(gooGuuIndexSets);
    SAFE_RELEASE(oneMonth);
    SAFE_RELEASE(oneYear);
    SAFE_RELEASE(threeMonth);
    SAFE_RELEASE(sixMonth);
    SAFE_RELEASE(historyLinePlot);
    SAFE_RELEASE(daHonLinePlot);
    SAFE_RELEASE(gooGuuLinePlot);
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
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    comInfo=delegate.comInfo;
    [self initData];
    [self initChart];
    [MBProgressHUD showHUDAddedTo:self.hostView animated:YES];
	[self.view setBackgroundColor:[Utiles colorWithHexString:@"#F6F1E6"]];
    [self initDahonViewComponents];
}

-(void)initDahonViewComponents{
    DrawChartTool *tool=[[DrawChartTool alloc] init];
    tool.standIn=self;
    UIImageView *topBar=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dragChartBar"]];
    topBar.frame=CGRectMake(0,0,SCREEN_HEIGHT,40);
    [self.view addSubview:topBar];
    //公司名称
    [tool addLabelToView:self.view withTitle:[NSString stringWithFormat:@"%@\n(%@.%@)",[comInfo objectForKey:@"companyname"],[comInfo objectForKey:@"stockcode"],[comInfo objectForKey:@"marketname"]] Tag:6 frame:CGRectMake(70,0,340,40) fontSize:18.0 color:nil textColor:@"#F9F8F6" location:NSTextAlignmentCenter];
    
    titleLabel=[tool addLabelToView:self.view withTitle:@"" Tag:6 frame:CGRectMake(0,40,480,30) fontSize:11.0 color:nil textColor:@"#63573d" location:NSTextAlignmentCenter];
    
    [tool addButtonToView:self.view withTitle:@"返回" Tag:5 frame:CGRectMake(15,5,54,30) andFun:@selector(backTo:) withType:UIButtonTypeCustom andColor:nil textColor:@"#FFFEFE" normalBackGroundImg:@"backBt" highBackGroundImg:nil];
    [tool addButtonToView:self.view withTitle:@"刷新" Tag:6 frame:CGRectMake(406,5,54,30) andFun:@selector(reflash:) withType:UIButtonTypeCustom andColor:nil textColor:@"#000000" normalBackGroundImg:@"reflashBt" highBackGroundImg:nil];
    
    oneMonth=[tool addButtonToView:self.view withTitle:@"一个月" Tag:OneMonth frame:CGRectMake(145,272,40,22) andFun:@selector(changeDateInter:) withType:UIButtonTypeCustom andColor:nil textColor:@"#e97a31" normalBackGroundImg:nil highBackGroundImg:nil];
    [oneMonth.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:10.0]];
    threeMonth=[tool addButtonToView:self.view withTitle:@"三个月" Tag:ThreeMonth frame:CGRectMake(195,272,40,22) andFun:@selector(changeDateInter:) withType:UIButtonTypeCustom andColor:nil textColor:@"#e97a31" normalBackGroundImg:nil highBackGroundImg:nil];
    [threeMonth.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:10.0]];
    sixMonth=[tool addButtonToView:self.view withTitle:@"六个月" Tag:SixMonth frame:CGRectMake(245,272,40,22) andFun:@selector(changeDateInter:) withType:UIButtonTypeCustom andColor:nil textColor:@"#e97a31" normalBackGroundImg:nil highBackGroundImg:nil];
    [sixMonth.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:10.0]];
    oneYear=[tool addButtonToView:self.view withTitle:@"一年" Tag:OneYear frame:CGRectMake(295,272,40,22) andFun:@selector(changeDateInter:) withType:UIButtonTypeCustom andColor:nil textColor:@"#FFFEFE" normalBackGroundImg:@"monthChoosenBt" highBackGroundImg:nil];
    [oneYear.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:10.0]];
    lastMarkBt=oneYear;
    [oneMonth setEnabled:NO];
    [threeMonth setEnabled:NO];
    [sixMonth setEnabled:NO];
    [oneYear setEnabled:NO];
    SAFE_RELEASE(tool);
    SAFE_RELEASE(topBar);
}

-(void)changeDateInter:(UIButton *)bt{
    bt.showsTouchWhenHighlighted=YES;
    int count=[self.dateArr count];
    if(bt.tag==OneMonth){
        [self changeBtState:oneMonth];
        XRANGEBEGIN=count-24;
        XRANGELENGTH=24;
        XINTERVALLENGTH=4.5;
    }else if(bt.tag==ThreeMonth){
        [self changeBtState:threeMonth];
        XRANGEBEGIN=count-60;
        XRANGELENGTH=59;
        XINTERVALLENGTH=10.7;
    }else if(bt.tag==SixMonth){
        [self changeBtState:sixMonth];
        XRANGEBEGIN=count-130;
        XRANGELENGTH=129;
        XINTERVALLENGTH=23;
    }else if(bt.tag==OneYear){
        [self changeBtState:oneYear];
        XRANGEBEGIN=count-269;
        XRANGELENGTH=269;
        XINTERVALLENGTH=50;
    }
    [self setXYAxis];
}

-(void)changeBtState:(UIButton *)nowBt{
    [lastMarkBt setBackgroundImage:nil forState:UIControlStateNormal];
    [lastMarkBt.titleLabel setTextColor:[Utiles colorWithHexString:@"#e97a31"]];
    [nowBt setBackgroundImage:[UIImage imageNamed:@"monthChoosenBt"] forState:UIControlStateNormal];
    [nowBt setTitleColor:[Utiles colorWithHexString:@"#FFFEFE"] forState:UIControlStateNormal];
    CATransition *transition=[CATransition animation];
    transition.duration=0.3f;
    transition.fillMode=kCAFillRuleNonZero;
    transition.type=kCATransitionMoveIn;
    transition.subtype=kCATransitionFromTop;
    [nowBt.layer addAnimation:transition forKey:@"animation"];
    transition.type=kCATransitionFade;
    transition.subtype=kCATransitionFromTop;
    [lastMarkBt.layer addAnimation:transition forKey:@"animation"];
    lastMarkBt=nowBt;
}

-(void)initChart{
    //初始化图形视图
    @try {
        graph=[[CPTXYGraph alloc] initWithFrame:CGRectZero];
        //CPTTheme *theme=[CPTTheme themeNamed:kCPTPlainWhiteTheme];
        //[graph applyTheme:theme];
        graph.fill=[CPTFill fillWithImage:[CPTImage imageWithCGImage:[UIImage imageNamed:@"discountBack"].CGImage]];
        
        hostView=[[ CPTGraphHostingView alloc ] initWithFrame :CGRectMake(20,80,SCREEN_WIDTH-20,180) ];
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
    
    //graph.title=@"大行估值";
    [titleLabel setText:@"大行估值"];
    //绘制图形空间
    plotSpace=(CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction=YES;
    [self.hostView setAllowPinchScaling:YES];
    DrawXYAxisWithoutXAxisOrYAxis;
    [self addScatterChart];
}


-(void)initData{

    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[comInfo objectForKey:@"stockcode"],@"stockcode",[comInfo objectForKey:@"marketname"],@"marketname", nil];
    [Utiles getNetInfoWithPath:@"GetStockHistoryData" andParams:params besidesBlock:^(id resObj){
        NSNumberFormatter * formatter   = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setPositiveFormat:@"##.##"];
        @try {
            self.chartData=[[resObj objectForKey:@"stockHistoryData"] objectForKey:@"data"];
            id info=[[resObj objectForKey:@"stockHistoryData"] objectForKey:@"info"];
            NSString *open=[formatter stringForObjectValue:[info objectForKey:@"open"]==nil?@"":[info objectForKey:@"open"]];
            NSString *close=[formatter stringForObjectValue:[info objectForKey:@"close"]==nil?@"":[info objectForKey:@"close"]];
            NSString *high=[formatter stringForObjectValue:[info objectForKey:@"high"]==nil?@"":[info objectForKey:@"high"]];
            NSString *low=[formatter stringForObjectValue:[info objectForKey:@"low"]==nil?@"":[info objectForKey:@"low"]];
            NSString *volume=[NSString stringWithFormat:@"%@",[info objectForKey:@"volume"]==nil?@"":[info objectForKey:@"volume"]];
            NSString *indicator=[NSString stringWithFormat:@"昨开盘:%@ 昨收盘:%@ 最高价:%@ 最低价:%@ 成交量:%@",open,close,high,low,volume];
            [titleLabel setText:indicator];
            
            self.dateArr=[Utiles sortDateArr:self.chartData];
            self.daHonDataDic=[resObj objectForKey:@"dahonData"];
            self.gooGuuDataDic=[resObj objectForKey:@"googuuData"];
            
            [self setDateMap];
            
            int count=[self.dateArr count];
            XRANGEBEGIN=count-269;
            XRANGELENGTH=269;
            XINTERVALLENGTH=50;
            
            SAFE_RELEASE(formatter);
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

-(void)setDateMap{
    
    NSMutableDictionary *tempDic=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[self.dateArr count];i++){
        [tempDic setValue:[NSNumber numberWithInt:i] forKey:[self.dateArr objectAtIndex:i]];
    }
    
    self.daHonIndexDateMap=[self dateRestruct:tempDic keys:[Utiles sortDateArr:[self.daHonDataDic allKeys]]];
    self.daHonIndexSets=[self.daHonIndexDateMap allKeys];
    
    self.gooGuuIndexDateMap=[self dateRestruct:tempDic keys:[Utiles sortDateArr:[self.gooGuuDataDic allKeys]]];
    self.gooGuuIndexSets=[self.gooGuuIndexDateMap allKeys];
    
    SAFE_RELEASE(tempDic);

}

-(NSMutableDictionary *)dateRestruct:(NSMutableDictionary *)tempDic keys:(NSArray *)keys{
    NSMutableDictionary *tempMap=[[NSMutableDictionary alloc] init];
    NSMutableArray *scoreCounter=[[NSMutableArray alloc] init];
    NSArray *dates=[Utiles sortDateArr:[tempDic allKeys]];
    BOOL isAdd=NO;
    for(id key in keys){
        if([dates containsObject:key]){
            [tempMap setValue:key forKey:[NSString stringWithFormat:@"%@",[tempDic objectForKey:key]]];
            [scoreCounter addObject:[tempDic objectForKey:key]];
        }else{            
            for(int n=[scoreCounter count]==0?0:[[scoreCounter lastObject] intValue];n<[dates count];n++){
                if([Utiles isDate1:[dates objectAtIndex:n] beforeThanDate2:key]){
                    continue;
                }else{
                    [tempMap setValue:key forKey:[NSString stringWithFormat:@"%d",n]];
                    [scoreCounter addObject:[NSNumber numberWithInt:n-1]];
                    isAdd=YES;
                    break;
                }
            }
            if(!isAdd){
                [tempMap setValue:key forKey:[NSString stringWithFormat:@"%d",[dates count]-1]];
            }
        }
        
    }
    SAFE_RELEASE(scoreCounter);
    return [tempMap autorelease];    
}

-(void)setXYAxis{

    [self lineShowWithAnimation];
    NSMutableArray *xTmp=[[NSMutableArray alloc] init];
    NSMutableArray *yTmp=[[NSMutableArray alloc] init];
    int n=0;
    for(id obj in self.dateArr){
        [xTmp addObject:[NSNumber numberWithInt:n++]];
    }
    for(id obj in self.chartData){
        [yTmp addObject:[[self.chartData objectForKey:obj] objectForKey:@"close"]];
    }
    @try {
        NSDictionary *xyDic=[DrawChartTool getXYAxisRangeFromxArr:xTmp andyArr:yTmp fromWhere:DahonModel];
        XORTHOGONALCOORDINATE=[[xyDic objectForKey:@"xOrigin"] doubleValue];
        YRANGEBEGIN=[[xyDic objectForKey:@"yBegin"] doubleValue];
        YRANGELENGTH=[[xyDic objectForKey:@"yLength"] doubleValue];
        YORTHOGONALCOORDINATE=[[xyDic objectForKey:@"yOrigin"] doubleValue];
        YINTERVALLENGTH=[[xyDic objectForKey:@"yInterval"] doubleValue];
        plotSpace.globalYRange=[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(YRANGEBEGIN) length:CPTDecimalFromDouble(YRANGELENGTH)];
        plotSpace.globalXRange=[CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-30) length:CPTDecimalFromDouble(300)];
        DrawXYAxisWithoutXAxisOrYAxis;
        [graph reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }
}

-(void)reflash:(UIButton *)bt{
    [MBProgressHUD showHUDAddedTo:self.hostView animated:YES];
    [MBProgressHUD hideHUDForView:self.hostView animated:YES];
}

-(void)backTo:(UIButton *)bt{
    bt.showsTouchWhenHighlighted=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}


//散点数据源委托实现
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    int count=0;
    if([(NSString *)plot.identifier isEqualToString:HISTORY_DATALINE_IDENTIFIER]){
        if(self.chartData){
            count=[self.chartData count];
        }else{
            count=0;
        }
        
    }else if([(NSString *)plot.identifier isEqualToString:DAHON_DATALINE_IDENTIFIER]){
        if(self.daHonIndexSets){
            count=[self.daHonIndexSets count];
        }else{
            count=0;
        }
    }else if([(NSString *)plot.identifier isEqualToString:GOOGUU_DATALINE_IDENTIFIER]){
        if(self.gooGuuIndexSets){
            count=[self.gooGuuIndexSets count];
        }else{
            count=0;
        }
    }
    return count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger) index{

    NSNumber *num=nil;
    if([(NSString *)plot.identifier isEqualToString:HISTORY_DATALINE_IDENTIFIER]){
        
        if(index<[self.dateArr count]){
            NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
            @try {
                if([key isEqualToString:@"x"]){
                    num=[NSNumber numberWithInt:index] ;
                }else if([key isEqualToString:@"y"]){
                    num=[[self.chartData valueForKey:[self.dateArr objectAtIndex:index]] objectForKey:@"close"];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
            }
        }
     
    }else if([(NSString *)plot.identifier isEqualToString:DAHON_DATALINE_IDENTIFIER]){
        if(index<[self.daHonIndexSets count]){
            @try {
                NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
                NSInteger trueIndex=[[self.daHonIndexSets objectAtIndex:index] intValue];
                if([key isEqualToString:@"x"]){
                    num=[NSNumber numberWithInt:trueIndex];
                }else if([key isEqualToString:@"y"]){
                    num=[[self.chartData valueForKey:[self.dateArr objectAtIndex:trueIndex]] objectForKey:@"close"];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
            }
        }
    
    }else if([(NSString *)plot.identifier isEqualToString:GOOGUU_DATALINE_IDENTIFIER]){
        if(index<[self.gooGuuIndexSets count]){
            @try {
                NSString *key=(fieldEnum==CPTScatterPlotFieldX?@"x":@"y");
                NSInteger trueIndex=[[self.gooGuuIndexSets objectAtIndex:index] intValue];
                if([key isEqualToString:@"x"]){
                    num=[NSNumber numberWithInt:trueIndex];
                }else if([key isEqualToString:@"y"]){
                    num=[[self.chartData valueForKey:[self.dateArr objectAtIndex:trueIndex]] objectForKey:@"close"];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
            }
        }
        
    }
    return  num;
}

#pragma mark -
#pragma mark Scatter Plot Methods Delegate
-(NSDictionary *)getDataFromDic:(NSDictionary *)dic dateMap:(NSMutableDictionary *)map andArr:(NSArray *)sets byIndex:(NSUInteger)idx{
    
    NSString *msg=[[NSString alloc] init];
    NSString *title=[[NSString alloc] init];
    NSNumber *trueIndex=[NSNumber numberWithInt:[[sets objectAtIndex:idx] intValue]];
    NSString *date=[map objectForKey:[NSString stringWithFormat:@"%@",trueIndex]];
    id data=[dic objectForKey:date];
    title=[NSString stringWithFormat:@"%@",date];
    for(id obj in data){
        msg=[msg stringByAppendingFormat:@"%@:%@\n",[obj objectForKey:@"dahonName"],[obj objectForKey:@"desc"]];
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:msg,@"msg",title,@"title", nil];
}

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx{
    NSDictionary *info=nil;
    NSDictionary *info2=nil;
    if(plot.identifier==GOOGUU_DATALINE_IDENTIFIER){
        info=[self getDataFromDic:self.gooGuuDataDic dateMap:self.gooGuuIndexDateMap andArr:self.gooGuuIndexSets byIndex:idx];
        if([self.daHonIndexSets containsObject:[self.gooGuuIndexSets objectAtIndex:idx]]){
            info2=[self getDataFromDic:self.daHonDataDic dateMap:self.daHonIndexDateMap andArr:self.daHonIndexSets byIndex:idx];
        }
    }else if(plot.identifier==DAHON_DATALINE_IDENTIFIER){
        info=[self getDataFromDic:self.daHonDataDic dateMap:self.daHonIndexDateMap andArr:self.daHonIndexSets byIndex:idx];
    }
    NSString *msg=nil;
    if(info2){
        msg=[NSString stringWithFormat:@"%@%@",[info objectForKey:@"msg"],[info2 objectForKey:@"msg"]];
    }else{
        msg=[NSString stringWithFormat:@"%@",[info objectForKey:@"msg"]];
    }
    [self.view makeToast:msg
                duration:1.5
                position:@"center"
                   title:[info objectForKey:@"title"]
     ];
    
}

#pragma mark -
#pragma mark Axis Delegate Methods

-(BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    if(axis.coordinate==CPTCoordinateX){
        @try {
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
                newStyle.fontSize=11.0;
                newStyle.fontName=@"Heiti SC";
                newStyle.color=[CPTColor colorWithComponentRed:153/255.0 green:129/255.0 blue:64/255.0 alpha:0.8];
                positiveStyle  = newStyle;
                
                theLabelTextStyle = positiveStyle;
                
                NSString * labelString      = [formatter stringForObjectValue:tickLocation];
                NSString *str=nil;
                if([self.dateArr count]>10){
                    @try {
                        if([labelString intValue]<=[self.dateArr count]-1&&[labelString intValue]>=0){
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
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
        }
        
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
            newStyle.fontSize=11.0;
            newStyle.fontName=@"Heiti SC";
            newStyle.color=[CPTColor colorWithComponentRed:153/255.0 green:129/255.0 blue:64/255.0 alpha:0.8];
            positiveStyle  = newStyle;
            
            theLabelTextStyle = positiveStyle;
            
            NSString * labelString      = [formatter stringForObjectValue:tickLocation];
            CPTTextLayer * newLabelLayer= [[CPTTextLayer alloc] initWithText:labelString style:theLabelTextStyle];
            [newLabelLayer sizeToFit];
            CPTAxisLabel * newLabel     = [[CPTAxisLabel alloc] initWithContentLayer:newLabelLayer];
            newLabel.tickLocation       = tickLocation.decimalValue;
            newLabel.offset             = 0;
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
    lineStyle.lineColor=[CPTColor colorWithComponentRed:255/255.0 green:114/255.0 blue:0/255.0 alpha:0.8];
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
    
    gooGuuLinePlot=[[CPTScatterPlot alloc] init];
    lineStyle.miterLimit=0.0f;
    lineStyle.lineWidth=0.0f;
    lineStyle.lineColor=[CPTColor clearColor];
    gooGuuLinePlot.dataLineStyle=lineStyle;
    gooGuuLinePlot.identifier=GOOGUU_DATALINE_IDENTIFIER;
    gooGuuLinePlot.labelOffset=5;
    gooGuuLinePlot.dataSource=self;
    gooGuuLinePlot.delegate=self;
    
    CPTMutableLineStyle * symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor colorWithComponentRed:102/255.0 green:204/255.0 blue:255/255.0 alpha:0.5];
    symbolLineStyle.lineWidth = 2.0;
    
    CPTPlotSymbol * plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill          = [CPTFill fillWithColor: [CPTColor colorWithComponentRed:226/255.0 green:93/255.0 blue:31/255.0 alpha:0.7]];
    plotSymbol.lineStyle     = symbolLineStyle;
    plotSymbol.size          = CGSizeMake(20, 20);
    
    daHonLinePlot.plotSymbol = plotSymbol;
    
    plotSymbol = [CPTPlotSymbol trianglePlotSymbol];
    plotSymbol.lineStyle     = symbolLineStyle;
    symbolLineStyle.lineWidth = 0.0;
    plotSymbol.fill          = [CPTFill fillWithColor:[Utiles cptcolorWithHexString:@"#b2f7b2" andAlpha:0.7]];
    plotSymbol.size          = CGSizeMake(17, 17);
    gooGuuLinePlot.plotSymbol=plotSymbol;
    
    historyLinePlot.opacity = 0.0f;
    daHonLinePlot.opacity = 0.0f;
    gooGuuLinePlot.opacity=0.0f;
    [self lineShowWithAnimation];
   
    [graph addPlot:historyLinePlot];
    [graph addPlot:daHonLinePlot];
    [graph addPlot:gooGuuLinePlot];

}
-(void)lineShowWithAnimation{
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 1.0f;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeBoth;
    fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
    [daHonLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    [historyLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    [gooGuuLinePlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        self.hostView.frame=CGRectMake(10,70,460,195);
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

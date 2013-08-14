//
//  DiscountRateViewController.m
//  估股
//
//  Created by Xcode on 13-8-7.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "DiscountRateViewController.h"
#import "DrawChartTool.h"
#import "XYZAppDelegate.h"


@interface DiscountRateViewController ()

@end

@implementation DiscountRateViewController

@synthesize jsonData;
@synthesize transData;

@synthesize resetBt;
@synthesize saveBt;
@synthesize backBt;

@synthesize companyNameLabel;
@synthesize marketPriceLabel;
@synthesize ggPriceLabel;
@synthesize suggestRateLabel;
@synthesize myRateLabel;
@synthesize unRiskRateLabel;
@synthesize marketBetaLabel;
@synthesize marketPremiumLabel;

@synthesize unRiskRateSlider;
@synthesize marketBetaSlider;
@synthesize marketPremiumSlider;

@synthesize webView;


- (void)dealloc
{
    SAFE_RELEASE(transData);
    SAFE_RELEASE(webView);
    SAFE_RELEASE(companyNameLabel);
    SAFE_RELEASE(jsonData);
    SAFE_RELEASE(resetBt);
    SAFE_RELEASE(saveBt);
    SAFE_RELEASE(backBt);
    SAFE_RELEASE(marketPriceLabel);
    SAFE_RELEASE(ggPriceLabel);
    SAFE_RELEASE(suggestRateLabel);
    SAFE_RELEASE(myRateLabel);
    SAFE_RELEASE(unRiskRateLabel);
    SAFE_RELEASE(marketBetaLabel);
    SAFE_RELEASE(marketPremiumLabel);
    SAFE_RELEASE(unRiskRateSlider);
    SAFE_RELEASE(marketBetaSlider);
    SAFE_RELEASE(marketPremiumSlider);
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
	[self.view setBackgroundColor:[Utiles colorWithHexString:@"#D1AB6D"]];
    self.transData=[[NSMutableArray alloc] init];
    webView=[[UIWebView alloc] init];
    webView.delegate=self;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"c" ofType:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath: path]]];
    
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    id com=delegate.comInfo;
    [self.companyNameLabel setText:[NSString stringWithFormat:@"%@(%@.%@)",[com objectForKey:@"companyname"],[com objectForKey:@"stockcode"],[com objectForKey:@"marketname"]]];
    [self.marketPriceLabel setText:[[com objectForKey:@"marketprice"] stringValue]];
    [self.ggPriceLabel setText:[[com objectForKey:@"googuuprice"] stringValue]];
    ggPrice=[[com objectForKey:@"googuuprice"] floatValue];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [self getObjectDataFromJsFun:@"initData" param:self.jsonData];

    id tempData=[self getObjectDataFromJsFun:@"returnWaccData" param:@""];
    for(id obj in tempData){
        [self.transData addObject:obj];
    }
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"##0.##"];
    myRate=[[[self.transData objectAtIndex:5] objectForKey:@"datanew"] floatValue];
    unRisk=[[[self.transData objectAtIndex:0] objectForKey:@"datanew"] floatValue];
    marketBeta=[[[self.transData objectAtIndex:1] objectForKey:@"datanew"] floatValue];
    marketPremium=[[[self.transData objectAtIndex:2] objectForKey:@"datanew"] floatValue];
    self.myRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:myRate*100]]];
    self.suggestRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:[[[self.transData objectAtIndex:5] objectForKey:@"datanew"] floatValue]*100]]];
    self.unRiskRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:unRisk*100]]];
    self.marketBetaLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:marketBeta]]];
    self.marketPremiumLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:marketPremium*100]]];
    
    [self.marketBetaSlider setMaximumValue:marketBeta+1];
    [self.marketBetaSlider setMinimumValue:marketBeta-1];
    [self.unRiskRateSlider setValue:unRisk*100 animated:YES];
    [self.marketBetaSlider setValue:marketBeta animated:YES];
    [self.marketPremiumSlider setValue:marketPremium*100 animated:YES];
    
    SAFE_RELEASE(formatter);
}

-(IBAction)btClick:(UIButton *)bt{
    bt.showsTouchWhenHighlighted=YES;
    if(bt.tag==1){
        NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:@"##0.##"];
        [self.ggPriceLabel setText:[NSString stringWithFormat:@"%.2f",ggPrice]];
        self.myRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:myRate*100]]];
        self.unRiskRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:unRisk*100]]];
        self.marketBetaLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:marketBeta]]];
        self.marketPremiumLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:marketPremium*100]]];
        [self.unRiskRateSlider setValue:unRisk*100 animated:YES];
        [self.marketBetaSlider setValue:marketBeta animated:YES];
        [self.marketPremiumSlider setValue:marketPremium*100 animated:YES];
        SAFE_RELEASE(formatter);
    }else if(bt.tag==3){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(IBAction)sliderChanged:(UISlider *)slider{
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"##0.##"];
    float progress = slider.value;
    if(slider.tag==1){
        unRiskRateLabel.text = [NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:[NSNumber numberWithFloat:progress]]];
        [self resetValue:progress index:0];
    }else if(slider.tag==2){
        marketBetaLabel.text = [NSString stringWithFormat:@"%.2f", progress];
        [self resetValue:progress index:1];
    }else if(slider.tag==3){
        marketPremiumLabel.text = [NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:[NSNumber numberWithFloat:progress]]];
        [self resetValue:progress index:2];
    }
    SAFE_RELEASE(formatter);
}



-(void)resetValue:(float)progress index:(NSInteger)index{
    NSMutableDictionary * temp=[[NSMutableDictionary alloc] initWithDictionary:[self.transData objectAtIndex:index]];
    if(index!=1){
        progress=progress/100;
    }
    [temp setObject:[NSNumber numberWithFloat:progress] forKey:@"datanew"];
    [self.transData setObject:temp atIndexedSubscript:index];
    //NSLog(@"==============%@-----------------\n",[self.transData JSONString]);
    NSString *jsonForChart=[[self.transData JSONString] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    id tempData=[self getObjectDataFromJsFun:@"chartCaluWacc" param:jsonForChart];
    //NSLog(@"%@",[tempData JSONString]);
    [self.transData removeAllObjects];
    for(id obj in tempData){
        [self.transData addObject:obj];
    }
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"##0.##"];
    self.myRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:[[[self.transData objectAtIndex:5] objectForKey:@"datanew"] floatValue]*100]]];
    self.ggPriceLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[[[self.transData objectAtIndex:6] objectForKey:@"ggPrice"] floatValue]]]];
    SAFE_RELEASE(formatter);
    SAFE_RELEASE(temp);
}

-(id)getObjectDataFromJsFun:(NSString *)funName param:(NSString *)data{
    NSString *arg=[[NSString alloc] initWithFormat:@"%@(\"%@\")",funName,data];
    NSString *re=[self.webView stringByEvaluatingJavaScriptFromString:arg];
    re=[re stringByReplacingOccurrencesOfString:@",]" withString:@"]"];
    SAFE_RELEASE(arg);
    return [re objectFromJSONString];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
    } else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        //self.view.frame=CGRectMake(0,40,SCREEN_HEIGHT,260);
    }
}

-(NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate
{

    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

















@end

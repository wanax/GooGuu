//
//  DiscountRateViewController.m
//  估股
//
//  Created by Xcode on 13-8-7.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "DiscountRateViewController.h"
#import "CommonlyMacros.h"
#import "Utiles.h"
#import "DrawChartTool.h"
#import "XYZAppDelegate.h"
#import "JSONKit.h"

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

    webView=[[UIWebView alloc] init];
    webView.delegate=self;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"c" ofType:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath: path]]];
    
    DrawChartTool *tool=[[DrawChartTool alloc] init];
    tool.standIn=self;
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    id com=delegate.comInfo;
    [self.companyNameLabel setText:[NSString stringWithFormat:@"%@(%@.%@)",[com objectForKey:@"companyname"],[com objectForKey:@"stockcode"],[com objectForKey:@"marketname"]]];
    [self.marketPriceLabel setText:[[com objectForKey:@"marketprice"] stringValue]];
    [self.ggPriceLabel setText:[[com objectForKey:@"googuuprice"] stringValue]];
    
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    NSString *arg=[[NSString alloc] initWithFormat:@"initData(\"%@\")",self.jsonData];
    NSString *re=[self.webView stringByEvaluatingJavaScriptFromString:arg];
    re=[re stringByReplacingOccurrencesOfString:@",]" withString:@"]"];
    arg=[[NSString alloc] initWithFormat:@"returnWaccData()"];
    re=[self.webView stringByEvaluatingJavaScriptFromString:arg];
    self.transData=[re objectFromJSONString];
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    self.suggestRateLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[[[self.transData objectAtIndex:5] objectForKey:@"datanew"] floatValue]]]];
    self.unRiskRateLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[[[self.transData objectAtIndex:0] objectForKey:@"datanew"] floatValue]]]];
    self.marketBetaLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[[[self.transData objectAtIndex:1] objectForKey:@"datanew"] floatValue]]]];
    self.marketPremiumLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[[[self.transData objectAtIndex:2] objectForKey:@"datanew"] floatValue]]]];
}

-(IBAction)btClick:(UIButton *)bt{
    bt.showsTouchWhenHighlighted=YES;
    if(bt.tag==3){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(IBAction)sliderChanged:(UISlider *)slider{
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"##0.##"];
    if(slider.tag==1){
        float progress = slider.value;
        unRiskRateLabel.text = [NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:[NSNumber numberWithFloat:progress]]];
    }else if(slider.tag==2){
        float progress = slider.value;
        marketBetaLabel.text = [NSString stringWithFormat:@"%.2f", progress];
    }else if(slider.tag==3){
        float progress =slider.value;
        marketPremiumLabel.text = [NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:[NSNumber numberWithFloat:progress]]];
    }
    SAFE_RELEASE(formatter);
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

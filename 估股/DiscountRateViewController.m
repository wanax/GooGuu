//
//  DiscountRateViewController.m
//  估股
//
//  Created by Xcode on 13-8-7.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "DiscountRateViewController.h"
#import "DrawChartTool.h"
#import "ChartViewController.h"
#import "XYZAppDelegate.h"


@interface DiscountRateViewController ()

@end

@implementation DiscountRateViewController

@synthesize comInfo;
@synthesize jsonData;
@synthesize valuesStr;
@synthesize defaultTransData;
@synthesize transData;
@synthesize webIsLoaded;

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
@synthesize chartViewController;

- (void)dealloc
{
    SAFE_RELEASE(chartViewController);
    SAFE_RELEASE(valuesStr);
    SAFE_RELEASE(defaultTransData);
    SAFE_RELEASE(comInfo);
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
-(void)viewDidAppear:(BOOL)animated{
    if(webIsLoaded){
        if(![Utiles isBlankString:self.valuesStr]){
            self.valuesStr=[self.valuesStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
            [Utiles getObjectDataFromJsFun:self.webView funName:@"setValues" byData:self.valuesStr shouldTrans:NO];            
        }
        [self adjustChartDataForSaved:[comInfo objectForKey:@"stockcode"] andToken:[Utiles getUserToken]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    webIsLoaded=NO;
	[self.view setBackgroundColor:[Utiles colorWithHexString:@"#D1AB6D"]];
    self.transData=[[NSMutableArray alloc] init];
    
    webView=[[UIWebView alloc] init];
    webView.delegate=self;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"c" ofType:@"html"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath: path]]];
    
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    comInfo=delegate.comInfo;
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    webIsLoaded=YES;
    [Utiles getObjectDataFromJsFun:self.webView funName:@"initData" byData:self.jsonData shouldTrans:YES];
    if(![Utiles isBlankString:self.valuesStr]){
        self.valuesStr=[self.valuesStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        [Utiles getObjectDataFromJsFun:self.webView funName:@"setValues" byData:self.valuesStr shouldTrans:NO];
    }
    id tempData=[Utiles getObjectDataFromJsFun:self.webView funName:@"returnDefaultWaccData" byData:@"" shouldTrans:YES];
    NSMutableArray *tmpArr=[[NSMutableArray alloc] init];
    for(id obj in tempData){
        [tmpArr addObject:[obj mutableCopy]];
    }
    self.defaultTransData=tmpArr;
    SAFE_RELEASE(tmpArr);
    [self adjustChartDataForSaved:[comInfo objectForKey:@"stockcode"] andToken:[Utiles getUserToken]];

}

-(IBAction)btClick:(UIButton *)bt{
    bt.showsTouchWhenHighlighted=YES;
    if(bt.tag==1){
        [self.transData removeAllObjects];
        for(id obj in self.defaultTransData){
            [self.transData addObject:obj];
        }
        [self caluPrice];
        [self updateComponents];
    }else if(bt.tag==2){
        NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[comInfo objectForKey:@"stockcode"],@"stockcode",[comInfo objectForKey:@"companyname"],@"companyname",[self.ggPriceLabel text],@"price", nil];
        NSString *paramStr=[[params JSONString] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        id backInfo=[Utiles getObjectDataFromJsFun:self.webView funName:@"returnSaveDicountData" byData:paramStr shouldTrans:YES];

        params=[NSDictionary dictionaryWithObjectsAndKeys:[Utiles getUserToken],@"token",@"googuu",@"from",[backInfo JSONString],@"data", nil];
        [Utiles postNetInfoWithPath:@"AddModelData" andParams:params besidesBlock:^(id resObj){
            if([resObj objectForKey:@"status"]){
                [Utiles ToastNotification:[resObj objectForKey:@"msg"] andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
            }
        }];
    }else if(bt.tag==3){
        NSString *values=[Utiles getObjectDataFromJsFun:self.webView funName:@"getValues" byData:nil shouldTrans:NO];
        self.chartViewController.valuesStr=values;
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



-(void)adjustChartDataForSaved:(NSString *)stockCode andToken:(NSString*)token{
    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:stockCode,@"stockcode",token,@"token",@"googuu",@"from", nil];
    [Utiles getNetInfoWithPath:@"AdjustedData" andParams:params besidesBlock:^(id resObj){
        if(resObj){
            @try {
                NSMutableArray *tmpArr=[[NSMutableArray alloc] init];
                for(id data in [resObj objectForKey:@"data"]){
                    if([[data objectForKey:@"data"] count]==1){
                        NSDictionary *pie=[NSDictionary dictionaryWithObjectsAndKeys:[data objectForKey:@"itemname"],@"name",[[[data objectForKey:@"data"] objectAtIndex:0] objectForKey:@"v"],@"data",[[[data objectForKey:@"data"] objectAtIndex:0] objectForKey:@"v"],@"datanew",[[[data objectForKey:@"data"] objectAtIndex:0] objectForKey:@"id"],@"id", nil];
                        [tmpArr addObject:pie];
                    }else{
                        NSString *jsonPrice=[[data objectForKey:@"data"] JSONString];
                        jsonPrice=[jsonPrice stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                        [Utiles getObjectDataFromJsFun:self.webView funName:@"chartCalu" byData:jsonPrice shouldTrans:NO];
                    }
                    
                }
                NSString *jsonForChart=[[tmpArr JSONString] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                id tempData=[Utiles getObjectDataFromJsFun:self.webView funName:@"chartCaluWacc" byData:jsonForChart shouldTrans:YES];
                
                [self.transData removeAllObjects];
                for(id obj in tempData){
                    [self.transData addObject:obj];
                }
                [self updateComponents];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
            }
            
        }
    }];
}

-(void)caluPrice{
    NSString *jsonForChart=[[self.transData JSONString] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    id tempData=[Utiles getObjectDataFromJsFun:self.webView funName:@"chartCaluWacc" byData:jsonForChart shouldTrans:YES];
    
    [self.transData removeAllObjects];
    for(id obj in tempData){
        [self.transData addObject:obj];
    }
}

-(void)resetValue:(float)progress index:(NSInteger)index{
    NSMutableDictionary * temp=[[NSMutableDictionary alloc] initWithDictionary:[self.transData objectAtIndex:index]];
    if(index!=1){
        progress=progress/100;
    }
    [temp setObject:[NSNumber numberWithFloat:progress] forKey:@"datanew"];
    [self.transData setObject:temp atIndexedSubscript:index];
    [self caluPrice];
    
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"##0.##"];
    self.myRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:[[[self.transData objectAtIndex:5] objectForKey:@"datanew"] floatValue]*100]]];
    self.ggPriceLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[[[self.transData objectAtIndex:6] objectForKey:@"ggPrice"] floatValue]]]];
    SAFE_RELEASE(formatter);
    SAFE_RELEASE(temp);
}


-(void)updateComponents{
    
    
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"##0.##"];
    
    [self.companyNameLabel setText:[NSString stringWithFormat:@"%@(%@.%@)",[comInfo objectForKey:@"companyname"],[comInfo objectForKey:@"stockcode"],[comInfo objectForKey:@"marketname"]]];
    [self.marketPriceLabel setText:[[comInfo objectForKey:@"marketprice"] stringValue]];
    self.ggPriceLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:[[[self.transData objectAtIndex:6] objectForKey:@"ggPrice"] floatValue]]]];
    ggPrice=[[[self.transData objectAtIndex:6] objectForKey:@"ggPrice"] floatValue];
 
    myRate=[[[self.transData objectAtIndex:5] objectForKey:@"datanew"] floatValue];
    unRisk=[[[self.transData objectAtIndex:0] objectForKey:@"datanew"] floatValue];
    marketBeta=[[[self.transData objectAtIndex:1] objectForKey:@"datanew"] floatValue];
    marketPremium=[[[self.transData objectAtIndex:2] objectForKey:@"datanew"] floatValue];

    self.myRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:myRate*100]]];
    self.suggestRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:[[[self.transData objectAtIndex:5] objectForKey:@"datanew"] floatValue]*100]]];
    self.unRiskRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:unRisk*100]]];
    self.marketBetaLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:[NSNumber numberWithFloat:marketBeta]]];
    self.marketPremiumLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:[NSNumber numberWithFloat:marketPremium*100]]];
    
    [self.marketBetaSlider setMaximumValue:[[[self.transData objectAtIndex:1] objectForKey:@"data"] floatValue]+1];
    [self.marketBetaSlider setMinimumValue:[[[self.transData objectAtIndex:1] objectForKey:@"data"] floatValue]-1];
    [self.unRiskRateSlider setValue:unRisk*100 animated:YES];
    [self.marketBetaSlider setValue:marketBeta animated:YES];
    [self.marketPremiumSlider setValue:marketPremium*100 animated:YES];
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

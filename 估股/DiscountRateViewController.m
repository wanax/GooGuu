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

@synthesize isSaved;
@synthesize comInfo;
@synthesize disCountIsChanged;
@synthesize jsonData;
@synthesize valuesStr;
@synthesize defaultTransData;
@synthesize transData;
@synthesize webIsLoaded;
@synthesize dragChartChangedDriverIds;
@synthesize sourceType;

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
@synthesize defaultUnRiskRateLabel;
@synthesize defaultMarketBetaLabel;
@synthesize defaultMarketPremiumLabel;
@synthesize unRiskRateMinLabel;
@synthesize unRiskRateMaxLabel;
@synthesize marketBetaMinLabel;
@synthesize marketBetaMaxLabel;
@synthesize marketPremiumMinLabel;
@synthesize marketPremiumMaxLabel;

@synthesize unRiskRateSlider;
@synthesize marketBetaSlider;
@synthesize marketPremiumSlider;

@synthesize webView;
@synthesize chartViewController;

- (void)dealloc
{
    SAFE_RELEASE(unRiskRateMinLabel);
    SAFE_RELEASE(unRiskRateMaxLabel);
    SAFE_RELEASE(marketBetaMinLabel);
    SAFE_RELEASE(marketBetaMaxLabel);
    SAFE_RELEASE(marketPremiumMinLabel);
    SAFE_RELEASE(marketPremiumMaxLabel);
    SAFE_RELEASE(defaultUnRiskRateLabel);
    SAFE_RELEASE(defaultMarketBetaLabel);
    SAFE_RELEASE(defaultMarketPremiumLabel);
    SAFE_RELEASE(dragChartChangedDriverIds);
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
-(void)viewDidDisappear:(BOOL)animated{
    self.chartViewController.isShowDiscountView=NO;
    NSString *values=[Utiles getObjectDataFromJsFun:self.webView funName:@"getValues" byData:nil shouldTrans:NO];
    self.chartViewController.valuesStr=values;
    self.chartViewController.disCountIsChanged=self.disCountIsChanged;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    webIsLoaded=NO;
    isSaved=NO;
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

    id tempData=[Utiles getObjectDataFromJsFun:self.webView funName:@"returnDefaultWaccData" byData:@"" shouldTrans:YES];
    NSMutableArray *tmpArr=[[NSMutableArray alloc] init];
    for(id obj in tempData){
        [tmpArr addObject:[obj mutableCopy]];
    }
    self.defaultTransData=tmpArr;
    SAFE_RELEASE(tmpArr);
    if(![Utiles isBlankString:self.valuesStr]){
        self.valuesStr=[self.valuesStr stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
        [Utiles getObjectDataFromJsFun:self.webView funName:@"setValues" byData:self.valuesStr shouldTrans:NO];
        id tempData=[Utiles getObjectDataFromJsFun:self.webView funName:@"returnWaccData" byData:@"" shouldTrans:YES];
        NSMutableArray *tmpArr=[[NSMutableArray alloc] init];
        for(id obj in tempData){
            [tmpArr addObject:[obj mutableCopy]];
        }
        self.transData=tmpArr;
        [self caluPriceWithData:self.transData];
        [self updateComponents];
        SAFE_RELEASE(tmpArr);
    }else{
        [self adjustChartDataForSaved:comInfo[@"stockcode"] andToken:[Utiles getUserToken]];
    }
}

#pragma mark -
#pragma mark Button Action

-(IBAction)btClick:(UIButton *)bt{
    bt.showsTouchWhenHighlighted=YES;
    if(bt.tag==ResetChart){
        self.disCountIsChanged=NO;
        [self.transData removeAllObjects];
        for(id obj in self.defaultTransData){
            [self.transData addObject:obj];
        }
        [self caluPriceWithData:self.transData];
        [self updateComponents];
    }else if(bt.tag==SaveData){
        
        id combinedData=[DrawChartTool changedDataCombinedWebView:self.webView comInfo:comInfo ggPrice:[self.ggPriceLabel text] dragChartChangedDriverIds:self.dragChartChangedDriverIds disCountIsChanged:self.disCountIsChanged];
        
        NSDictionary *params=@{@"token": [Utiles getUserToken],@"from": @"googuu",@"data": [combinedData JSONString]};
        [Utiles postNetInfoWithPath:@"AddModelData" andParams:params besidesBlock:^(id resObj){
            if(resObj[@"status"]){
                [Utiles ToastNotification:resObj[@"msg"] andView:self.chartViewController.view andLoading:NO andIsBottom:NO andIsHide:YES];
                self.disCountIsChanged=NO;
                [saveBt setBackgroundImage:[UIImage imageNamed:@"savedBt"] forState:UIControlStateNormal];
                [saveBt setEnabled:NO];
                isSaved=YES;
            }
        }];
    }else if(bt.tag==BackToSuperView){
        
        if(sourceType==MySavedType){            
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            CATransition *transition=[CATransition animation];
            transition.duration=0.5f;
            transition.fillMode=kCAFillRuleNonZero;
            transition.type=kCATransitionFade;
            transition.subtype=kCATransitionFromTop;
            [self.view removeFromSuperview];
            [self.chartViewController.view.layer addAnimation:transition forKey:@"animation"];
            [self.chartViewController viewDidAppear:YES];
        }
        
    }
}

-(IBAction)sliderChanged:(UISlider *)slider{
    if(isSaved){
        [saveBt setEnabled:YES];
        [saveBt setBackgroundImage:[UIImage imageNamed:@"saveBt"] forState:UIControlStateNormal];
        isSaved=NO;
    }
    self.disCountIsChanged=YES;
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"##0.##"];
    float progress = slider.value;
    if(slider.tag==1){
        unRiskRateLabel.text = [NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:@(progress)]];
        [self resetValue:progress index:0];
    }else if(slider.tag==2){
        marketBetaLabel.text = [NSString stringWithFormat:@"%.2f", progress];
        [self resetValue:progress index:1];
    }else if(slider.tag==3){
        marketPremiumLabel.text = [NSString stringWithFormat:@"%@%%", [formatter stringFromNumber:@(progress)]];
        [self resetValue:progress index:2];
    }
    SAFE_RELEASE(formatter);
}

#pragma mark -
#pragma mark General Methods


-(void)adjustChartDataForSaved:(NSString *)stockCode andToken:(NSString*)token{

    NSDictionary *params=@{@"stockcode": stockCode,@"token": token,@"from": @"googuu"};
    [Utiles getNetInfoWithPath:@"AdjustedData" andParams:params besidesBlock:^(id resObj){
        if(resObj){
            @try {
                NSMutableArray *tmpArr=[[NSMutableArray alloc] init];
                for(id data in resObj[@"data"]){
                    if([data[@"data"] count]==1){
                        NSDictionary *pie=@{@"name": data[@"itemname"],@"data": data[@"data"][0][@"v"],@"datanew": data[@"data"][0][@"v"],@"id": data[@"data"][0][@"id"]};
                        [tmpArr addObject:pie];
                    }else{
                        NSString *jsonPrice=[data[@"data"] JSONString];
                        jsonPrice=[jsonPrice stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                        [Utiles getObjectDataFromJsFun:self.webView funName:@"chartCalu" byData:jsonPrice shouldTrans:NO];
                    }
                    
                }
                [self caluPriceWithData:tmpArr];
                [self updateComponents];
            }
            @catch (NSException *exception) {
                NSLog(@"%@",exception);
            }
            
        }
    }];
}

-(void)caluPriceWithData:(id)obj{
    NSString *jsonForChart=[[obj JSONString] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    id tempData=[Utiles getObjectDataFromJsFun:self.webView funName:@"chartCaluWacc" byData:jsonForChart shouldTrans:YES];
    
    [self.transData removeAllObjects];
    for(id obj in tempData){
        [self.transData addObject:obj];
    }
}

-(void)resetValue:(float)progress index:(NSInteger)index{
    NSMutableDictionary * temp=[[NSMutableDictionary alloc] initWithDictionary:(self.transData)[index]];
    if(index!=1){
        progress=progress/100;
    }
    temp[@"datanew"] = @(progress);
    [self.transData setObject:temp atIndexedSubscript:index];
    [self caluPriceWithData:self.transData];
    
    NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"##0.##"];
    self.myRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:@([(self.transData)[5][@"datanew"] floatValue]*100)]];
    self.ggPriceLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:@([(self.transData)[6][@"ggPrice"] floatValue])]];
    SAFE_RELEASE(formatter);
    SAFE_RELEASE(temp);
}


-(void)updateComponents{

    NSNumberFormatter *formatter=[[NSNumberFormatter alloc] init];
    [formatter setPositiveFormat:@"##0.##"];
    
    [self.companyNameLabel setText:[NSString stringWithFormat:@"%@\n(%@.%@)",comInfo[@"companyname"],comInfo[@"stockcode"],comInfo[@"marketname"]]];
    [self.marketPriceLabel setText:[comInfo[@"marketprice"] stringValue]];
    self.ggPriceLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:@([(self.transData)[6][@"ggPrice"] floatValue])]];
    ggPrice=[(self.transData)[6][@"ggPrice"] floatValue];
 
    myRate=[(self.transData)[5][@"datanew"] floatValue];
    unRisk=[(self.transData)[0][@"datanew"] floatValue];
    marketBeta=[(self.transData)[1][@"datanew"] floatValue];
    marketPremium=[(self.transData)[2][@"datanew"] floatValue];
    float defaultunRisk=[(self.transData)[0][@"data"] floatValue];
    float defaultmarketBeta=[(self.transData)[1][@"data"] floatValue];
    float defaultmarketPremium=[(self.transData)[2][@"data"] floatValue];

    self.defaultUnRiskRateLabel.text=[NSString stringWithFormat:@"无风险利率%@%%",[formatter stringFromNumber:@(defaultunRisk*100)]];
    self.defaultMarketBetaLabel.text=[NSString stringWithFormat:@"市场贝塔值%@",[formatter stringFromNumber:@(defaultmarketBeta)]];
    self.defaultMarketPremiumLabel.text=[NSString stringWithFormat:@"市场溢价%@%%",[formatter stringFromNumber:@(defaultmarketPremium*100)]];
    
    self.myRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:@(myRate*100)]];
    self.suggestRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:@([(self.transData)[5][@"datanew"] floatValue]*100)]];
    self.unRiskRateLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:@(unRisk*100)]];
    self.marketBetaLabel.text=[NSString stringWithFormat:@"%@",[formatter stringFromNumber:@(marketBeta)]];
    self.marketPremiumLabel.text=[NSString stringWithFormat:@"%@%%",[formatter stringFromNumber:@(marketPremium*100)]];
    
    [self.marketPremiumMaxLabel setText:[NSString stringWithFormat:@"%.2f",[(self.transData)[1][@"data"] floatValue]+1]];
    [self.marketPremiumMinLabel setText:[NSString stringWithFormat:@"%.2f",[(self.transData)[1][@"data"] floatValue]-1]];
    [self.marketBetaSlider setMaximumValue:[(self.transData)[1][@"data"] floatValue]+1];
    [self.marketBetaSlider setMinimumValue:[(self.transData)[1][@"data"] floatValue]-1];
    [self.unRiskRateSlider setValue:unRisk*100 animated:YES];
    [self.marketBetaSlider setValue:marketBeta animated:YES];
    [self.marketPremiumSlider setValue:marketPremium*100 animated:YES];
    SAFE_RELEASE(formatter);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
    } else if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)){
        self.view.frame=CGRectMake(0,40,480,280);
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

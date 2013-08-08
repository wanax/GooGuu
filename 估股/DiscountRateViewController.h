//
//  DiscountRateViewController.h
//  估股
//
//  Created by Xcode on 13-8-7.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscountRateViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic,retain) id jsonData;
@property (nonatomic,retain) NSMutableArray *transData;

@property (nonatomic,retain) IBOutlet UIButton *resetBt;
@property (nonatomic,retain) IBOutlet UIButton *saveBt;
@property (nonatomic,retain) IBOutlet UIButton *backBt;

@property (nonatomic,retain) IBOutlet UILabel *companyNameLabel;
@property (nonatomic,retain) IBOutlet UILabel *marketPriceLabel;
@property (nonatomic,retain) IBOutlet UILabel *ggPriceLabel;
@property (nonatomic,retain) IBOutlet UILabel *suggestRateLabel;
@property (nonatomic,retain) IBOutlet UILabel *myRateLabel;
@property (nonatomic,retain) IBOutlet UILabel *unRiskRateLabel;
@property (nonatomic,retain) IBOutlet UILabel *marketBetaLabel;
@property (nonatomic,retain) IBOutlet UILabel *marketPremiumLabel;

@property (nonatomic,retain) IBOutlet UISlider *unRiskRateSlider;
@property (nonatomic,retain) IBOutlet UISlider *marketBetaSlider;
@property (nonatomic,retain) IBOutlet UISlider *marketPremiumSlider;

@property (nonatomic,retain) UIWebView *webView;

-(IBAction)btClick:(UIButton *)bt;
-(IBAction)sliderChanged:(UISlider *)slider;








@end

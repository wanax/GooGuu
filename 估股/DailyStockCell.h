//
//  DailyStockCell.h
//  UIDemo
//
//  Created by Xcode on 13-7-18.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DailyStockCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UIImageView *dailyStockImg;
@property (nonatomic,retain) IBOutlet UILabel *companyNameLabel;
@property (nonatomic,retain) IBOutlet UILabel *communityPriceLabel;
@property (nonatomic,retain) IBOutlet UILabel *gooGuuPriceLabel;
@property (nonatomic,retain) IBOutlet UILabel *marketLabel;
@property (nonatomic,retain) IBOutlet UILabel *marketPriceLabel;
@property (nonatomic,retain) IBOutlet UILabel *tradeLabel;
@property (nonatomic,retain) IBOutlet UILabel *outLookLabel;

@end

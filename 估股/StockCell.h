//
//  StockCell.h
//  UIDemo
//
//  Created by Xcode on 13-7-15.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StockCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UILabel *stockNameLabel;
@property (nonatomic,retain) IBOutlet UIButton *concernBt;

@property (strong, nonatomic) IBOutlet UILabel *belongLabel;
@property (strong, nonatomic) IBOutlet UILabel *gPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;

@property (nonatomic,retain) IBOutlet UILabel *gooGuuPriceLabel;
@property (nonatomic,retain) IBOutlet UILabel *marketPriceLabel;
@property (nonatomic,retain) IBOutlet UILabel *percentLabel;

@end

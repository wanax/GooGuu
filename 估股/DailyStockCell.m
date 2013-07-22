//
//  DailyStockCell.m
//  UIDemo
//
//  Created by Xcode on 13-7-18.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "DailyStockCell.h"

@implementation DailyStockCell

@synthesize dailyStockImg;

- (void)dealloc
{
    [dailyStockImg release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

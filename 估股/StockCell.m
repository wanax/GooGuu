//
//  StockCell.m
//  UIDemo
//
//  Created by Xcode on 13-7-15.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "StockCell.h"

@implementation StockCell

@synthesize stockNameLabel;
@synthesize concernBt;

- (void)dealloc
{
    [stockNameLabel release];
    [concernBt release];
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

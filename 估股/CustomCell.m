//
//  CustomCell.m
//  welcom_demo_1
//
//  Created by Xcode on 13-5-7.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-07 | Wanax | 开机首页默认股票cell

#import "CustomCell.h"

@interface CustomCell ()

@end

@implementation CustomCell

@synthesize topImageView;
@synthesize bottomImageView;
@synthesize nameLabel;
@synthesize belongLabel;
@synthesize gPriceLabel;
@synthesize priceLabel;

@synthesize gooGuuPriceLabel;
@synthesize marketPriceLabel;
@synthesize percentLabel;

@synthesize topImg;
@synthesize bottomImg;
@synthesize name;
@synthesize belong;
@synthesize gPrice;
@synthesize price;

- (void)dealloc
{
    [percentLabel release];
    [gooGuuPriceLabel release];
    [marketPriceLabel release];
    [topImageView release];
    [bottomImageView release];
    [nameLabel release];
    [belong release];
    [gPriceLabel release];
    [priceLabel release];
    [topImg release];
    [bottomImg release];
    [name release];
    [belong release];
    [gPrice release];
    [price release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



- (void)setTopImg:(UIImage *)img {
    if (![img isEqual:topImg]) {
        topImg = [img copy];
        self.topImageView.image = topImg;
    }
}

-(void)setBottomImg:(UIImage *)img{
    if (![img isEqual:bottomImg]) {
        bottomImg = [img copy];
        self.bottomImageView.image = bottomImg;
    }
}



-(void)setName:(NSString *)n {
    if (![n isEqualToString:name]) {
        name = [n copy];
        self.nameLabel.text = name;
    }
    
}

-(void)setBelong:(NSString *)b {
    if (![b isEqualToString:belong]) {
        belong = [b copy];
        self.belongLabel.text = belong;
    }
}

-(void)setGPrice:(NSString *)g{
    if(![g isEqualToString:gPrice]){
        gPrice = [g copy];
        self.gPriceLabel.text = gPrice;
    }
}

-(void)setPrice:(NSString *)p{
    if(![p isEqualToString:price]){
        price=[p copy];
        self.priceLabel.text = price;
    }
}

@end

//
//  Company.h
//  UIDemo
//
//  Created by Xcode on 13-7-9.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Company : NSObject

@property int comId;
@property (nonatomic,copy) NSString *companyName;
@property (nonatomic,copy) NSString *trade;
@property (nonatomic,copy) NSString *market;
@property double communityPrice;
@property double marketPrice;
@property (nonatomic,copy) NSString *companyLogoUrl;
@property (nonatomic,copy) NSString *companyPicUrl;
@property int interestNum;
@property (nonatomic,copy) NSString *stockCode;
@property double googuuPrice;

@end

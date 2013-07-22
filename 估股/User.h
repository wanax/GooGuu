//
//  User.h
//  UIDemo
//
//  Created by Xcode on 13-6-6.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject<NSCoding>

@property (nonatomic) NSInteger id;
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *password;
@property (nonatomic,retain) NSString *email;
@property (nonatomic) NSInteger comId;
@property (nonatomic) NSInteger newId;
@property (nonatomic,retain) NSString *token;

@end

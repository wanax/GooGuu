//
//  ArticleCommentModel.h
//  UIDemo
//
//  Created by Xcode on 13-7-16.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleCommentModel : NSObject

@property (nonatomic,retain) NSString *updateTime;
@property (nonatomic,retain) NSString *author;
@property (nonatomic,retain) NSString *content;
@property (nonatomic,retain) NSString *headerPicUrl;
@property (nonatomic) NSInteger rid;

@end

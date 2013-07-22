//
//  ArticleCommentModel.m
//  UIDemo
//
//  Created by Xcode on 13-7-16.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "ArticleCommentModel.h"

@implementation ArticleCommentModel

@synthesize updateTime;
@synthesize author;
@synthesize content;
@synthesize headerPicUrl;
@synthesize rid;

- (void)dealloc
{
    [updateTime release];
    [author release];
    [content release];
    [headerPicUrl release];
    [super dealloc];
}

@end

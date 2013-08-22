//
//  GooGuuArticleViewController.h
//  UIDemo
//
//  Created by Xcode on 13-7-10.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  Vision History
//  2013-07-10 | Wanax | 估股新闻二级详细咨询页面

#import <UIKit/UIKit.h>

#define FINGERCHANGEDISTANCE 100.0

@interface GooGuuArticleViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic,retain) NSString *articleTitle;
@property (nonatomic,retain) NSString *articleId;
@property (nonatomic,retain) UIWebView *articleWeb;

@end

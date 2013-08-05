//
//  AddCommentViewController.h
//  UIDemo
//
//  Created by Xcode on 13-7-16.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  Vision History
//  2013-07-16 | Wanax | 估股新闻三级添加评论页面

#import <UIKit/UIKit.h>

@interface AddCommentViewController : UIViewController<UITextFieldDelegate>

//评论类型，此页面三种评论公用
typedef enum {
    
    CompanyType,//关于股票公司的评论
    NewsType,//估股新闻中分析报告的评论
    ArticleType//股票公司中分析报告的评论
    
} CommentType;

@property (nonatomic,retain) IBOutlet UITextField *commentField;
@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic,retain) NSString *articleId;
@property CommentType type;


@end

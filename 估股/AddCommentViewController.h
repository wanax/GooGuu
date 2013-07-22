//
//  AddCommentViewController.h
//  UIDemo
//
//  Created by Xcode on 13-7-16.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddCommentViewController : UIViewController<UITextFieldDelegate>

typedef enum {
    
    CompanyType,
    
    ArticleType
    
} CommentType;

@property (nonatomic,retain) IBOutlet UITextField *commentField;
@property (nonatomic,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic,retain) NSString *articleId;
@property CommentType type;


@end

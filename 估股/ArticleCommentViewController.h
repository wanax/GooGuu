//
//  ArticleCommentViewController.h
//  UIDemo
//
//  Created by Xcode on 13-7-16.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"

#define FINGERCHANGEDISTANCE 100.0

@class ArticleCommentModel;

@interface ArticleCommentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate,UIScrollViewDelegate>{
    BOOL nibsRegistered;
}

@property (nonatomic,retain) UITableView *cusTable;
@property (nonatomic,retain) NSString *articleId;
@property (nonatomic,retain) id commentArr;

@end

//
//  AnalyDetailViewController.h
//  估股
//
//  Created by Xcode on 13-7-24.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PrettyToolbar;

@interface AnalyDetailViewController : UIViewController

@property (nonatomic,retain) NSString *articleId;
@property (nonatomic,retain) PrettyToolbar *top;
@property (nonatomic,retain) NSMutableArray *myToolBarItems;

@end

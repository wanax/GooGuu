//
//  GooNewsCell.h
//  UIDemo
//
//  Created by Xcode on 13-6-14.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GooNewsCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (nonatomic,retain) IBOutlet UILabel *timeDiferLabel;
@property (nonatomic,retain) IBOutlet UIImageView *readMarkImg;

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *content;

@end

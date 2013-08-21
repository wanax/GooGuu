//
//  ModelClassGrade2ViewController.h
//  估股
//
//  Created by Xcode on 13-8-2.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModelClassGrade2Delegate <NSObject>
@optional
-(void)modelClassChanged:(NSString *)driverId;
@end

@interface ModelClassGrade2ViewController : UITableViewController

@property (nonatomic,retain) id<ModelClassGrade2Delegate> delegate;

@property (nonatomic,retain) id savedData;
@property (nonatomic,retain) NSString *classTitle;
@property (nonatomic,retain) id jsonData;
@property (nonatomic,retain) NSString *indicator;
@property (nonatomic,retain) id indicatorClass;
@property (nonatomic,retain) NSArray *savedDataName;




@end

//
//  UINavigationControlle+Autorotate.h
//  UIDemo
//
//  Created by Xcode on 13-7-4.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Autorotate)

- (BOOL)shouldAutorotate   ;
- (NSUInteger)supportedInterfaceOrientations;

@end

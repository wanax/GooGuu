//
//  MyGooguuViewController.h
//  UIDemo
//
//  Created by Xcode on 13-6-18.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  我的估股滚动页面

#import <UIKit/UIKit.h>


@class ConcernedViewController;
@class SaveModelViewController;
@class MHTabBarController;

@interface MyGooguuViewController : UIViewController<UIScrollViewDelegate>{
    //左右滑动部分
	UIPageControl *pageControl;
    int currentPage;
    BOOL pageControlUsed;
}

@property (nonatomic,retain) ConcernedViewController *concernedViewController;
@property (nonatomic,retain) SaveModelViewController *saveModelViewControler;

@property (nonatomic,retain) UINavigationController *concernNavViewController;

@property (nonatomic,retain) UIButton *concernButton;
@property (nonatomic,retain) UIButton *saveButton;

@property (retain, nonatomic) UILabel *slidLabel;//用于指示作用

@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic,retain) UIPageControl *pageControl;

@property (nonatomic,retain) MHTabBarController *tabBarController ;


























@end

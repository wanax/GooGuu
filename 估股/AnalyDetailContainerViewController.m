//
//  AnalyDetailContainerViewController.m
//  估股
//
//  Created by Xcode on 13-7-24.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "AnalyDetailContainerViewController.h"
#import "GooGuuArticleViewController.h"
#import "ArticleCommentViewController.h"
#import "MHTabBarController.h"

@interface AnalyDetailContainerViewController ()

@end

@implementation AnalyDetailContainerViewController

@synthesize articleId;

- (void)dealloc
{
    [articleId release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    GooGuuArticleViewController *articleViewController=[[GooGuuArticleViewController alloc] init];
    articleViewController.articleId=self.articleId;
    articleViewController.title=@"研究报告";
    ArticleCommentViewController *articleCommentViewController=[[ArticleCommentViewController alloc] init];
    articleCommentViewController.articleId=self.articleId;
    articleCommentViewController.title=@"评论";
    articleCommentViewController.type=StockCompany;
    MHTabBarController *container=[[MHTabBarController alloc] init];
    NSArray *controllers=[NSArray arrayWithObjects:articleViewController,articleCommentViewController, nil];
    container.viewControllers=controllers;
    [self.view addSubview:container.view];
    [self addChildViewController:container];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

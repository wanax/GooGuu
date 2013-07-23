//
//  AnalysisReportViewController.m
//  UIDemo
//
//  Created by Xcode on 13-5-8.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 股票详细页-股票分析

#import "AnalysisReportViewController.h"
#import "Utiles.h"
#import "JSONKit.h"
#import "XYZAppDelegate.h"
#import "AnalyReportDeatilViewController.h"
#import "UILabel+VerticalAlign.h"
#import "MHTabBarController.h"

@interface AnalysisReportViewController ()

@end

#define FINGERCHANGEDISTANCE 100.0

@implementation AnalysisReportViewController


- (void)dealloc
{
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
    XYZAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    [self.view setBackgroundColor:[Utiles colorWithHexString:@"#EFEBD9"]];

    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:[delegate.comInfo objectForKey:@"stockcode"],@"stockcode", nil];
    [Utiles postNetInfoWithPath:@"CompanyAnalyReportURL" andParams:params besidesBlock:^(id obj){
        if([obj JSONString].length>5){
            id anaModel=[obj objectAtIndex:0];
            AnalyReportDeatilViewController *detail=[[AnalyReportDeatilViewController alloc] initWithNibName:@"AnalyReportDeatilView" bundle:nil];
            [self.view addSubview:detail.view];
            [detail.titleLabel setText:[NSString stringWithFormat:@"%@",[anaModel objectForKey:@"title"]]];
            detail.updataTimeLabel.text=[anaModel objectForKey:@"updatetime"];
            detail.briefLabel.text=[anaModel objectForKey:@"brief"];
            [detail.briefLabel alignTop];
            [detail release];
        }else{
            [Utiles ToastNotification:@"暂无数据" andView:self.view andLoading:NO andIsBottom:NO andIsHide:NO];
        }
    }];
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    
    CGPoint change=[tap translationInView:self.view];
    
    if(change.x<-FINGERCHANGEDISTANCE){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:3 animated:YES];
    }else if(change.x>FINGERCHANGEDISTANCE){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:1 animated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






















@end

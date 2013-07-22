//
//  AnalyReportDeatilViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-11.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "AnalyReportDeatilViewController.h"
#import "UILabel+VerticalAlign.h"

@interface AnalyReportDeatilViewController ()

@end

@implementation AnalyReportDeatilViewController

@synthesize titleLabel;
@synthesize updataTimeLabel;
@synthesize briefLabel;

- (void)dealloc
{
    [titleLabel release];
    [updataTimeLabel release];
    [briefLabel release];
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
    self.titleLabel.text=@"here";
    [self.briefLabel alignTop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


























@end

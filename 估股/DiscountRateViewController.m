//
//  DiscountRateViewController.m
//  估股
//
//  Created by Xcode on 13-8-7.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "DiscountRateViewController.h"

@interface DiscountRateViewController ()

@end

@implementation DiscountRateViewController

@synthesize jsonData;

- (void)dealloc
{
    [jsonData release];jsonData=nil;
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
	[self.view setBackgroundColor:[UIColor blackColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

















@end

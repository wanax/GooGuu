//
//  DahonValuationViewController.m
//  估股
//
//  Created by Xcode on 13-8-8.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "DahonValuationViewController.h"
#import "CommonlyMacros.h"
#import "Utiles.h"
#import "DrawChartTool.h"
#import "XYZAppDelegate.h"
#import "JSONKit.h"

@interface DahonValuationViewController ()

@end

@implementation DahonValuationViewController

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
	[self.view setBackgroundColor:[UIColor blueColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    DrawChartTool *tool=[[DrawChartTool alloc] init];
    tool.standIn=self;
    [tool addButtonToView:self.view withTitle:@"返回" Tag:4 frame:CGRectMake(400,0,80,40) andFun:@selector(backTo:)];
    SAFE_RELEASE(tool);
}
-(NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    
    return YES;
}










@end

//
//  AnalyDetailViewController.m
//  估股
//
//  Created by Xcode on 13-7-24.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "AnalyDetailViewController.h"
#import "UILabel+VerticalAlign.h"
#import "Utiles.h"
#import "PrettyToolbar.h"
#import "AnalyDetailContainerViewController.h"

@interface AnalyDetailViewController ()

@end

@implementation AnalyDetailViewController

@synthesize articleId;
@synthesize top;
@synthesize myToolBarItems;

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
    AnalyDetailContainerViewController *container=[[AnalyDetailContainerViewController alloc] init];
    container.articleId=self.articleId;
    container.view.frame=CGRectMake(0,17,self.view.frame.size.width,self.view.frame.size.height);
    [self.view addSubview:container.view];
    [self addChildViewController:container];
    
    [self addToolBar];
}

-(void)addToolBar{
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    top=[[PrettyToolbar alloc] initWithFrame:CGRectMake(0,0,320,37)];
    UIBarButtonItem *back=[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    myToolBarItems=[[NSMutableArray alloc] init];
    [myToolBarItems addObject:back];
    [top setItems:myToolBarItems];
    [self.view addSubview:top];
    [back release];
    [top release];
    
}

-(void)back:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(NSUInteger)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate{
    return NO;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

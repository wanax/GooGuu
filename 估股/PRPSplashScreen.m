//
//  PRPSplashScreen.h
//  welcom_demo_1
//
//  Created by Xcode on 2013-05-08.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 开机动画

#import "PRPSplashScreen.h"

@interface PRPSplashScreen ()

@end

@implementation PRPSplashScreen

@synthesize splashImage;
@synthesize showsStatusBarOnDismissal;
@synthesize delegate;

- (void)dealloc
{
    [splashImage release];
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
    UIImageView *iv=[[UIImageView alloc] initWithImage:self.splashImage];
    iv.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    iv.contentMode=UIViewContentModeCenter;
    self.view=iv;
    [iv release];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    SEL didAppearSelector=@selector(splashScreenDidAppear:);
    if([self.delegate respondsToSelector:didAppearSelector]){
        [self.delegate splashScreenDidAppear:self];
    }
    [self performSelector:@selector(hide) withObject:nil afterDelay:1];
}

-(void)hide{
    if(self.showsStatusBarOnDismissal){
        UIApplication *app=[UIApplication sharedApplication];
        [app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
    [self dismissModalViewControllerAnimated:YES];
}

-(UIImage *)splashImage{
    if(splashImage==nil){
        self.splashImage=[UIImage imageNamed:@"curst.png"];
    }
    return splashImage;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}











@end

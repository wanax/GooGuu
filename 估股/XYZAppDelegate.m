//
//  XYZAppDelegate.m
//  welcom_demo_1
//
//  Created by chaoxiao zhuang on 13-1-10.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//

#import "XYZAppDelegate.h"
#import "tipViewController.h"
#import "ConcernedViewController.h"
#import "ClientCenterViewController.h"
#import "DBLite.h"
#import "ConcernedViewController.h"
#import "GooNewsViewController.h"
#import "MyGooguuViewController.h"
#import "FinanceToolsViewController.h"
#import "UniverseViewController.h"
#import "ChartViewController.h"
#import "Company.h"
#import "PrettyNavigationController.h"
#import "PrettyTabBarViewController.h"
#import "Reachability.h"
#import "ChartViewController.h"
#import "CommonlyMacros.h"
#import <Crashlytics/Crashlytics.h>


@implementation XYZAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize scrollView;
@synthesize pageControl;
@synthesize loginTimer;
@synthesize comInfo;
@synthesize popoverController;

- (void)dealloc
{
    [popoverController release];
    [loginTimer release];
    [comInfo release];
    [scrollView release];
    [tabBarController release];
    [pageControl release];
    [window release];
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Utiles setConfigureInfoTo:@"userconfigure" forKey:@"stockColorSetting" andContent:[NSString stringWithFormat:@"%d",0]];
    [Crashlytics startWithAPIKey:@"c59317990c405b2f42582cacbe9f4fa9abe1fefb"];
    // Override point for customization after application launch.
    //增加标识，用于判断是否是第一次启动应用...

    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"everLaunched"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"everLaunched"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLaunch"];
    }

    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]) {
        //用户初次使用进入使用引导界面
        tipViewController * startView = [[tipViewController alloc]init];
        self.window.rootViewController = startView;
        [startView release];
        DBLite *tool=[[DBLite alloc] init];
        [tool openSQLiteDB];
        [tool initDB];
        [tool closeDB];
        [tool initDBData];
        [tool release];
    }else {
       
        UITabBarItem *barItem=[[UITabBarItem alloc] initWithTitle:@"最新简报" image:[UIImage imageNamed:@"googuuNewsBar"] tag:1];      
        UITabBarItem *barItem2=[[UITabBarItem alloc] initWithTitle:@"我的估股" image:[UIImage imageNamed:@"myGooGuuBar"] tag:2];        
        UITabBarItem *barItem3=[[UITabBarItem alloc] initWithTitle:@"金融工具" image:[UIImage imageNamed:@"hammer.png"] tag:3];
        UITabBarItem *barItem4=[[UITabBarItem alloc] initWithTitle:@"功能设置" image:[UIImage imageNamed:@"moreAboutBar"] tag:4];
        UITabBarItem *barItem5=[[UITabBarItem alloc] initWithTitle:@"估值模型" image:[UIImage imageNamed:@"companyListBar"] tag:5];
        
        //股票关注
        MyGooguuViewController *myGooGuu=[[MyGooguuViewController alloc] init];
        myGooGuu.tabBarItem=barItem2;
        PrettyNavigationController *myGooGuuNavController=[[PrettyNavigationController alloc] initWithRootViewController:myGooGuu];

        
        //客户设置
        ClientCenterViewController *clientView=[[ClientCenterViewController alloc] init];
        clientView.tabBarItem=barItem4;
        PrettyNavigationController *clientCenterNav=[[PrettyNavigationController alloc] initWithRootViewController:clientView];
        
        
        //估股新闻
        GooNewsViewController *gooNewsViewController=[[GooNewsViewController alloc] init];
        gooNewsViewController.tabBarItem=barItem;
        PrettyNavigationController *gooNewsNavController=[[PrettyNavigationController alloc] initWithRootViewController:gooNewsViewController];
        
        
        //股票列表
        UniverseViewController *universeViewController=[[UniverseViewController alloc] init];
        universeViewController.tabBarItem=barItem5;
        PrettyNavigationController *universeNav=[[PrettyNavigationController alloc] initWithRootViewController:universeViewController];
        
      
        self.tabBarController = [[PrettyTabBarViewController alloc] init];

        self.tabBarController.viewControllers = @[gooNewsNavController,universeNav,myGooGuuNavController, clientCenterNav];
        
        self.window.backgroundColor=[UIColor clearColor];       
        self.window.rootViewController = self.tabBarController;

        
        SAFE_RELEASE(barItem);
        SAFE_RELEASE(barItem2);
        SAFE_RELEASE(barItem3);
        SAFE_RELEASE(barItem4);
        SAFE_RELEASE(barItem5);

        SAFE_RELEASE(myGooGuu);
        SAFE_RELEASE(clientView);
        SAFE_RELEASE(gooNewsNavController);
        SAFE_RELEASE(universeViewController);

        SAFE_RELEASE(myGooGuuNavController);
        SAFE_RELEASE(clientCenterNav);
        SAFE_RELEASE(gooNewsNavController);
        SAFE_RELEASE(universeNav);

    }

    if([Utiles isLogin]){
        
        [self handleTimer:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginKeeping" object:nil];
        loginTimer = [NSTimer scheduledTimerWithTimeInterval: 7000// 当函数正在调用时，及时间隔时间到了 也会忽略此次调用
                                                      target: self
                                                    selector: @selector(handleTimer:)
                                                    userInfo: nil
                                                     repeats: YES];
    }
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    reach.reachableOnWWAN = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [reach startNotifier];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginKeeping:) name:@"LoginKeeping" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelLoginKeeping:) name:@"LogOut" object:nil];
    
    [self.window makeKeyAndVisible];

    return YES;
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        NSLog(@"Reachable");
    }
    else
    {
        NSLog(@"NReachable");
    }
}



-(void)loginKeeping:(NSNotification*)notification{

    loginTimer = [NSTimer scheduledTimerWithTimeInterval: 7000// 当函数正在调用时，及时间隔时间到了 也会忽略此次调用
                                                  target: self
                                                selector: @selector(handleTimer:)
                                                userInfo: nil
                                                 repeats: YES];
}
-(void)cancelLoginKeeping:(NSNotification*)notification{
    [loginTimer invalidate];
}


- (void) handleTimer: (NSTimer *) timer{
    
    NSUserDefaults *userDeaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *params=@{@"username": [[userDeaults objectForKey:@"UserInfo"][@"username"] lowercaseString],@"password": [Utiles md5:[userDeaults objectForKey:@"UserInfo"][@"password"]],@"from": @"googuu"};
    [Utiles getNetInfoWithPath:@"Login" andParams:params besidesBlock:^(id resObj){
    
        if([resObj[@"status"] isEqualToString:@"1"]){
            NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:@"UserToke"];
            [userDefaults setObject:resObj[@"token"] forKey:@"UserToken"];
            
            NSLog(@"%@",resObj[@"token"]);

        }else {
            NSLog(@"%@",resObj[@"msg"]);
        }
        
    }];
    
    
}

/*-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    
    //return UIInterfaceOrientationMaskAllButUpsideDown;
}*/



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end

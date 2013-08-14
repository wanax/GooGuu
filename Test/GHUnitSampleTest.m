//
//  GHUnitSampleTest.m
//  估股
//
//  Created by Xcode on 13-7-26.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "GHUnitSampleTest.h"


@implementation GHUnitSampleTest

- (void)testStrings
{
    GHTestLog(@"plist write test");
    [Utiles setConfigureInfoTo:@"userconfigure" forKey:@"username" andContent:@"dsad"];
    GHTestLog(@"%@",[Utiles getConfigureInfoFrom:@"userconfigure" andKey:@"username" inUserDomain:NO]);
}

-(void)plistTest{
    
    GHTestLog(@"plist write test");
    [Utiles setConfigureInfoTo:@"userconfigure" forKey:@"username" andContent:@"wanax"];
    
}

@end

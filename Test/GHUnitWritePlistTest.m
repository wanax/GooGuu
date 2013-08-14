//
//  WritePlistTest.m
//  估股
//
//  Created by Xcode on 13-7-26.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "GHUnitWritePlistTest.h"


@implementation GHUnitWritePlistTest

-(void)plistTest{
    
    GHTestLog(@"plist write test");
    [Utiles setConfigureInfoTo:@"userconfigure" forKey:@"username" andContent:@"wanax"];
    
}

@end

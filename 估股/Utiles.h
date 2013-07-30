//
//  Utiles.h
//  UIDemo
//
//  Created by Xcode on 13-6-7.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//
//  工具类

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@class MBProgressHUD;
@interface Utiles : NSObject


//字符串转颜色
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

//md5 32位 加密 （小写）
+ (NSString *)md5:(NSString *)str;

+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud;
+ (void)ToastNotification:(NSString *)text andView:(UIView *)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom andIsHide:(BOOL)isHide;

+ (id)getConfigureInfoFrom:(NSString *)fileName andKey:(NSString *)key inUserDomain:(BOOL)isIn;
+(void)setConfigureInfoTo:(NSString *)fileName forKey:(NSString *)key andContent:(NSString *)content;

+(void)getNetInfoWithPath:(NSString *)url andParams:(NSDictionary *)params besidesBlock:(void(^)(id obj))block;
+(void)postNetInfoWithPath:(NSString *)url andParams:(NSDictionary *)params besidesBlock:(void(^)(id obj))block;

+ (BOOL) isBlankString:(NSString *)string;

+(BOOL)stringToBool:(NSString *)string;

+ (NSString *)intervalSinceNow: (NSString *) theDate;










@end

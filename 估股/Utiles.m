//
//  Utiles.m
//  UIDemo
//
//  Created by Xcode on 13-6-7.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "Utiles.h"
#import "GCDiscreetNotificationView.h"
#import "MBProgressHUD.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "JSONKit.h"
#import "CommonlyMacros.h"

@implementation Utiles

#define DEFAULT_VOID_COLOR [UIColor whiteColor]

//字符串转颜色
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    
    if ([cString length] < 6)
        return DEFAULT_VOID_COLOR;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return DEFAULT_VOID_COLOR;
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


//md5 32位 加密 （小写）
+ (NSString *)md5:(NSString *)str {
    
    const char *cStr = [str UTF8String];  
    unsigned char result[32];
    CC_MD5( cStr, strlen(cStr), result );
    
   return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],result[1],result[2],result[3],           
            result[4],result[5],result[6],result[7],            
            result[8],result[9],result[10],result[11],            
            result[12],result[13],result[14],result[15],            
            result[16], result[17],result[18], result[19],            
            result[20], result[21],result[22], result[23],            
            result[24], result[25],result[26], result[27],            
            result[28], result[29],result[30], result[31]];    
}

+ (void)ToastNotification:(NSString *)text andView:(UIView *)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom andIsHide:(BOOL)isHide
{
    GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc] initWithText:text showActivity:isLoading inPresentationMode:isBottom?GCDiscreetNotificationViewPresentationModeBottom:GCDiscreetNotificationViewPresentationModeTop inView:view];
    [notificationView show:YES];
    if(isHide){
        [notificationView hideAnimatedAfter:2.0];
    }
}

+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud
{
    [view addSubview:hud];
    hud.labelText = text;
    //hud.dimBackground = YES;
    hud.square = YES;
    [hud show:YES];
}

+ (id)getConfigureInfoFrom:(NSString *)fileName andKey:(NSString *)key inUserDomain:(BOOL)isIn{
    
    NSDictionary *dictionary=nil;
    if(isIn){
        NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory , NSUserDomainMask , YES );
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* filePath = [NSString stringWithFormat:@"%@/%@.plist",documentsDirectory,fileName];
        dictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    }else{
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
        dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    
    if(key!=nil){
        return [dictionary objectForKey:key];
    }else{
        return dictionary;
    }
    
  
}
+(void)setConfigureInfoTo:(NSString *)fileName forKey:(NSString *)key andContent:(NSString *)content{

    NSMutableDictionary *dTmp;
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory , NSUserDomainMask , YES );
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.plist",documentsDirectory,fileName];
    dTmp=[[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    if(dTmp==nil){
        dTmp=[[NSMutableDictionary alloc] init];
    }
    [dTmp setValue:content forKey:key];
    [dTmp writeToFile:filePath atomically: YES];
    [dTmp release];
  
}


+(void)getNetInfoWithPath:(NSString *)url andParams:(NSDictionary *)params besidesBlock:(void (^)(id))block{
    
    AFHTTPClient *getAction=[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[Utiles getConfigureInfoFrom:@"netrequesturl" andKey:@"GooGuuBaseURL" inUserDomain:NO]]];
    [getAction getPath:[Utiles getConfigureInfoFrom:@"netrequesturl" andKey:url inUserDomain:NO] parameters:params success:^(AFHTTPRequestOperation *operation,id responseObject){
        
        id resObj=[operation.responseString objectFromJSONString];
        if(block){
            block(resObj);
        }
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        NSLog(@"%@",error.localizedDescription);
    }];
    [getAction release];
}

+(void)postNetInfoWithPath:(NSString *)url andParams:(NSDictionary *)params besidesBlock:(void (^)(id))block{
    
    AFHTTPClient *postAction=[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[Utiles getConfigureInfoFrom:@"netrequesturl" andKey:@"GooGuuBaseURL" inUserDomain:NO]]];
    [postAction postPath:[Utiles getConfigureInfoFrom:@"netrequesturl" andKey:url inUserDomain:NO]parameters:params success:^(AFHTTPRequestOperation *operation,id responseObject){
        
        id resObj=[operation.responseString objectFromJSONString];
        if(block){
            block(resObj);
        }
        
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        NSLog(@"%@",error.localizedDescription);
    }];
    [postAction release];
}


+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if([string isKindOfClass:[NSString class]]){
        if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
            return YES;
        }
    }
    
    return NO;
}

+(BOOL)stringToBool:(NSString *)string{
    
    BOOL tag;
    if([string isEqualToString:@"1"]){
        tag=YES;
    }else {
        tag=NO;
    }
    return tag;
    
}

+ (NSString *)intervalSinceNow: (NSString *) theDate
{
    
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
        
    }
    [date release];
    return timeString;
}

+(NSString *)getCatchSize{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    float folderSize = 0;
    if([fileManager fileExistsAtPath:path]){
        
        NSEnumerator *childFilesEnumerator = [[fileManager subpathsOfDirectoryAtPath:path error:nil] objectEnumerator];
        
        NSString *fileName;
        
        while((fileName = [childFilesEnumerator nextObject]) != nil){
            
            NSString *fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
            folderSize += [fileManager attributesOfItemAtPath:fileAbsolutePath error:nil].fileSize;
        }
    }
    return [NSString stringWithFormat:@"%.2f",folderSize/1000];
}

+(void)deleteSandBoxContent{
    
    NSString *extension = @"plist";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *e = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [e nextObject])) {
        
        if ([[filename pathExtension] isEqualToString:extension]) {
            
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];
        }
    }
    
}









@end

//
//  DBLite.h
//  welcom_demo_1
//
//  Created by Xcode on 13-5-9.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 数据库相关操作
//  2013-05-08 | Wanax | 废弃

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface DBLite : NSObject{
    sqlite3* database;
}


-(void)openSQLiteDB;

- (void)initDB;

-(void)initDBData;

-(void)closeDB;
//获取同类型公司信息
- (NSMutableArray *)getCompanyInfo:(NSString *)classify;
//获取所有公司所属类型
- (NSMutableArray *)getCompanyType;
//搜索购票
-(NSMutableArray *)searchStocks:(NSString *)key from:(NSString *)classify;
//验证用户，用户登录
-(void)checkUser:(NSString *)name and:(NSString *)pwd WithBlock:(void (^)(NSString * isLogin,NSString *token))block;

//用户注销||用户信息获取||获取关注公司列表||获取保存公司列表
-(void)userToken:(NSString *)token Todo:(NSString *)url WithBlock:(void(^)(id obj))block;
















@end

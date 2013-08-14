//
//  DBLite.m
//  welcom_demo_1
//
//  Created by Xcode on 13-5-9.
//  Copyright (c) 2013年 Pony Finance. All rights reserved.
//
//  Vision History
//  2013-05-08 | Wanax | 数据库相关操作

#import "DBLite.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"

@implementation DBLite


- (void)dealloc
{
    [super dealloc];
}


-(void)openSQLiteDB
{
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:@"PonyData.rdb"];
    //NSLog(@"%@",databaseFilePath);
    
    if (sqlite3_open([databaseFilePath UTF8String], &database)!=SQLITE_OK) {
        NSLog(@"database is not ok");
    }
}

- (void)initDB
{
    char *errorMsg;
    NSString *sql = @"CREATE TABLE IF NOT EXISTS \"CompanyList\" (\
                            \"comId\" integer DEFAULT 0,\
                            \"companyName\" Varchar(25,0),\
                            \"trade\" Varchar(25,0),\
                            \"market\" Varchar(25,0),\
                            \"communityPrice\" Double,\
                            \"marketPrice\" Double,\
                            \"comanyLogoUrl\" Varchar(200,0),\
                            \"companyPicUrl\" Varchar(200,0),\
                            \"interestNum\" INTEGER(8,0),\
                            \"stockCode\" Varchar(50,0),\
                            \"googuuPrice\" Double,\
                            PRIMARY KEY(\"comId\")\
                            );\
    CREATE TABLE IF NOT EXISTS user (id integer  NOT NULL  PRIMARY KEY DEFAULT 0,name Varchar(100) DEFAULT NULL,email Varchar(50) DEFAULT NULL,password Varchar(100) DEFAULT NULL,comId integer,newId integer,token Varchar(255) DEFAULT NULL);\
    INSERT INTO user(id,name,email,password,comId,newId,token) VALUES\
    ('1','jack','mxchenry@sina.com','e10adc3949ba59abbe56e057f20f883e','2','0',''),\
    ('2','张三','mxiaochi@gmail.com','e10adc3949ba59abbe56e057f20f883e','3','0',''),\
    ('3','李四','sdaf@163.com','e10adc3949ba59abbe56e057f20f883e','4','0','');";
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
    {
        sqlite3_close(database);
    }
    
}

-(void)initDBData{

    //初始化公司列表
     AFHTTPClient *httpClient = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:@"http://www.googuu.net"]];
    [httpClient getPath:@"http://www.googuu.net/m/queryAllCompany.htm"
             parameters:nil
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSMutableArray *comArr=[operation.responseString objectFromJSONString];
                    NSString *sql=[[NSString alloc] initWithString:@"INSERT INTO CompanyList(companyName,trade,market,stockCode ,googuuPrice ,communityPrice,marketPrice,comanyLogoUrl,companyPicUrl,interestNum) VALUES "];
                    for(id obj in comArr){
                        sql=[sql stringByAppendingFormat:@"('%@','%@','%@','%@',%f,%f,%f,'%@','%@',%d),",[obj objectForKey:@"companyname"],[obj objectForKey:@"trade"],[obj objectForKey:@"market"],[obj objectForKey:@"stockcode"],[[obj objectForKey:@"googuuprice"] doubleValue],[[obj objectForKey:@"communityprice"] doubleValue],[[obj objectForKey:@"marketprice"] doubleValue],[obj objectForKey:@"comanylogourl"],[obj objectForKey:@"companypicurl"],[[obj objectForKey:@"interestnum"] integerValue]];
                        
                    }
                    sql=[sql substringWithRange:NSMakeRange(0,[sql length]-1)];
                    
                    [self openSQLiteDB];
                    
                    char *errorMsg;
                    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
                    {
                        sqlite3_close(database);
                        NSLog(@"error: %s",errorMsg); 
                    }
                    [self closeDB];
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    //Error code
                    [self closeDB];
                }];
    
    [httpClient release];

  
}

-(void)closeDB{
    sqlite3_close(database);
}

//股票搜索
-(NSMutableArray *)searchStocks:(NSString *)key from:(NSString *)classify{
    NSDictionary* dic=nil;
    NSMutableArray* arr=[[NSMutableArray alloc] init];
    sqlite3_stmt *statement = nil;
    NSString *sql=nil;
    //all搜索全部分类
    if([classify isEqual:@"全部"]){
        sql=[[NSString alloc] initWithFormat:@"SELECT * FROM companylist WHERE (companyName LIKE '%%%@%%' OR stockCode LIKE '%%%@%%');",key,key];
    }else{
        //sql=[[NSString alloc] initWithFormat:@"SELECT * FROM companylist WHERE (companyName LIKE '%%%@%%' OR stockCode LIKE '%%%@%%') AND market='%@%';",key,key,classify];
 
    }
    NSLog(@"股票搜索：%@",sql);
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK)
    {
        NSLog(@"Error: failed to prepare statement with message:get channels.");
    }
    //查询结 果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        NSInteger comID=(int)sqlite3_column_int(statement, 0);
        char* name = (char*)sqlite3_column_text(statement, 1);
        char* industry = (char*)sqlite3_column_text(statement, 2);
        char* classify = (char*)sqlite3_column_text(statement, 3);
        char* code = (char*)sqlite3_column_text(statement, 10);
        NSNumber *comId=[NSNumber numberWithInteger:comID];
        NSString* nameStr= [NSString stringWithUTF8String:name];
        NSString* industryStr = [NSString stringWithUTF8String:industry];
        NSString* classifyStr = [NSString stringWithUTF8String:classify];
        NSString* codeStr = [NSString stringWithUTF8String:code];
        NSLog(@"userName=%@  类型=%@,分类=%@,编码=%@,id=%@", nameStr, industryStr,classifyStr,codeStr,comId);
        dic = [NSDictionary dictionaryWithObjectsAndKeys:comId,@"comID",nameStr, @"name",industryStr,@"industry",classifyStr,@"classify",codeStr,@"code", nil];
        [arr addObject:dic];
    }
    sqlite3_finalize(statement);
    //[dic release];
    [sql release];
    return [arr autorelease];

}


//查询股票类型
- (NSMutableArray *)getCompanyType
{
    NSDictionary* dic=nil;
    NSMutableArray* arr=[[NSMutableArray alloc] init];
    sqlite3_stmt *statement = nil;
    char *sql = "select distinct market from companylist ";
    if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK)
    {
        NSLog(@"Error: failed to prepare statement with message:get channels.");
    }
    //查询结 果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        char* classify = (char*)sqlite3_column_text(statement, 0);
        NSString* classifyStr = [NSString stringWithUTF8String:classify];

        //NSLog(@"classify=%@", classifyStr);
        dic = [NSDictionary dictionaryWithObjectsAndKeys:classifyStr, @"classify", nil];
        [arr addObject:dic];
    }
    sqlite3_finalize(statement);
    //[dic release];
    return [arr autorelease];
}


//查询股票详细信息
- (NSMutableArray *)getCompanyInfo:(NSString *)classify
{
    NSDictionary* dic=nil;
    NSMutableArray* arr=[[[NSMutableArray alloc] init] autorelease];
    sqlite3_stmt *statement = nil;
    NSString *sql;
    if([classify isEqual:@"全部"]){
       sql=[[NSString alloc] initWithFormat:@"SELECT * FROM COMPANYLIST;"];  
    }else{
       sql=[[NSString alloc] initWithFormat:@"SELECT * FROM COMPANYLIST WHERE market='%@';",classify]; 
    }
    
    if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK)
    {
        NSLog(@"Error: failed to prepare statement with message:get channels.");
    }
    //查询结 果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
    while (sqlite3_step(statement) == SQLITE_ROW)
    {
        NSInteger comID=(int)sqlite3_column_int(statement, 0);
        char* name = (char*)sqlite3_column_text(statement, 1);
        char* industry = (char*)sqlite3_column_text(statement, 2);
        char* classify = (char*)sqlite3_column_text(statement, 3);
        char* comPicUrl=(char*)sqlite3_column_text(statement,7);
        char* code = (char*)sqlite3_column_text(statement, 9);
        NSNumber *comId=[NSNumber numberWithInteger:comID];
        NSString* nameStr= [NSString stringWithUTF8String:name];
        NSString* industryStr = [NSString stringWithUTF8String:industry];
        NSString* classifyStr = [NSString stringWithUTF8String:classify];
        NSString* comPicStr=[NSString stringWithUTF8String:comPicUrl];
        NSString* codeStr = [NSString stringWithUTF8String:code];
        //NSLog(@"userName=%@  类型=%@,分类=%@,编码=%@,id=%@", nameStr, industryStr,classifyStr,codeStr,comId);
        dic = [NSDictionary dictionaryWithObjectsAndKeys:comId,@"comID",nameStr, @"name",industryStr,@"industry",classifyStr,@"classify",comPicStr,@"companypicurl", codeStr,@"stockcode", nil];
        [arr addObject:dic];
    }
    sqlite3_finalize(statement);
    //[dic release];
    [sql release];
    return arr;
}


//登录验证用户
-(void)checkUser:(NSString *)name and:(NSString *)pwd WithBlock:(void (^)(NSString *, NSString *))block{
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc]initWithBaseURL:[NSURL URLWithString:[Utiles getConfigureInfoFrom:@"netrequesturl" andKey:@"GooGuuBaseURL" inUserDomain:NO]]];
    [httpClient getPath:@"/m/login"
             parameters:@{@"username":name, @"password":pwd,@"from":@"googuu"}
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if (block) {
                        id info=[operation.responseString objectFromJSONString];                        
                        block([info objectForKey:@"status"],[info objectForKey:@"token"]);
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    //Error code
                    [self closeDB];
                    NSLog(@"net failed");
                }];
    
    [httpClient release];
    
}


-(void)userToken:(NSString *)token Todo:(NSString *)url WithBlock:(void (^)(id))block{

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[Utiles getConfigureInfoFrom:@"netrequesturl" andKey:@"GooGuuBaseURL" inUserDomain:NO]]];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            token, @"token",@"googuu",@"from",
                            nil];
    [httpClient postPath:url
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     
                     if (block) {
                         id info=[operation.responseString objectFromJSONString];
                         block(info);
                     }
                     
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
                 }];
    
    [httpClient release];
    
}





















@end

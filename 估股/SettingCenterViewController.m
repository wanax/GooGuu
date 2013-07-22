//
//  SettingCenterViewController.m
//  UIDemo
//
//  Created by Xcode on 13-6-21.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "SettingCenterViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import "CustomTableView.h"
#import "ClientLoginViewController.h"
#import "XYZAppDelegate.h"

@interface SettingCenterViewController ()

@end

@implementation SettingCenterViewController

@synthesize centerTableView;
@synthesize top;

- (void)dealloc
{
    [top release];top=nil;
    [centerTableView release];centerTableView=nil;
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
    [self setTitle:@"设置"];
    
    self.navigationController.navigationBarHidden=NO;
    
    centerTableView=[[CustomTableView alloc] initWithFrame:CGRectMake(0,0,320,400) style:UITableViewStyleGrouped];
    centerTableView.delegate=self;
    centerTableView.dataSource=self;
    
    [self.view addSubview:centerTableView];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Table Date Source Methods


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if(section==0){
        return @"个人业务";
    }else if(section==1){
        return @"公司详情";
    }else if(section==2){
        return @"系统";
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return 3;
    }else if(section==1){
        return 1;
    }else if(section==2){
        return 2;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * ClientCenterIdentifier =
    @"ClientCenterIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             ClientCenterIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier: ClientCenterIdentifier] autorelease];
    }
    
    int tag=indexPath.row;
    int section=indexPath.section;
    if(section==0){
        switch (tag) {
            case 0:
                cell.textLabel.text=@"草稿箱";
                break;
            case 1:
                cell.textLabel.text=@"我的评论";
                break;
            case 2:
                cell.textLabel.text=@"意见反馈";
                break;
            default:
                break;
        }
    }else if(section==1){
        switch (tag) {
            case 0:
                cell.textLabel.text=@"关于估股";
                break;
            default:
                break;
        }
    }else if(section==2){
        switch (tag) {
            case 0:
                cell.textLabel.text=@"系统设置";
                break;
            case 1:
                cell.textLabel.text=@"退出登录";
                break;
            default:
                break;
        }
    }
    
    cell.textLabel.font=[UIFont fontWithName:@"Heiti SC" size:15];
    
    return cell;
    
}

#pragma mark -
#pragma mark Table Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //[SVProgressHUD showWithStatus:@"Loading...."];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
}

-(BOOL)shouldAutorotate{
    return NO;
}


@end

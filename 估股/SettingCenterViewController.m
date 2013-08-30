//
//  SettingCenterViewController.m
//  UIDemo
//
//  Created by Xcode on 13-6-21.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "SettingCenterViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "ClientLoginViewController.h"
#import "XYZAppDelegate.h"
#import "PrettyKit.h"
#import "DoubleLabelCell.h"
#import "LabelSwitchCell.h"
#import "StockRiseDownColorSettingViewController.h"
#import "AboutUsAndCopyrightViewController.h"
#import "FeedBackViewController.h"

@interface SettingCenterViewController ()

@end

@implementation SettingCenterViewController

@synthesize customTabel;

- (void)dealloc
{
    [customTabel release];customTabel=nil;
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

-(void)viewDidAppear:(BOOL)animated{
    [self.customTabel reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"设置"];
    
    self.customTabel=[[UITableView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,380) style:UITableViewStyleGrouped];
    self.customTabel.delegate=self;
    self.customTabel.dataSource=self;
    [self.view addSubview:self.customTabel];
    
    
    
}
#pragma mark -
#pragma mark General Methods

-(void)switchChange:(UISwitch *)p{

    BOOL isButtonOn = [p isOn];
    if(p.tag==1){
        [self setUserConfigure:@"wifiImg" isOn:isButtonOn];
    }else if(p.tag==2){
        [self setUserConfigure:@"checkUpdate" isOn:isButtonOn];
    }
    
}
-(void)setUserConfigure:(NSString *)key isOn:(BOOL)isButtonOn{
    if (isButtonOn) {
        [Utiles setConfigureInfoTo:@"userconfigure" forKey:key andContent:@"1"];
    }else {
        [Utiles setConfigureInfoTo:@"userconfigure" forKey:key andContent:@"0"];
    }
}

#pragma mark -
#pragma mark Table Data Source Methods
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(section==0){
        return 3;
    }else if(section==1){
        return 1;
    }else if(section==2){
        return 2;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0){
        return @"功能设置";
    }else if (section == 1){
        return @"缓存设置";
    }else if(section==2){        
        return @"其它";        
    }
    return @"";
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[[UILabel alloc] init] autorelease];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont fontWithName:@"Heiti SC" size:16.0f];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    [view autorelease];
    [view addSubview:label];
    
    return view;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger section=indexPath.section;
    NSInteger row=indexPath.row;
    
    if(section==0){
       
        if(row==0){
            
            static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                     TableSampleIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]
                        initWithStyle:UITableViewCellStyleValue1
                        reuseIdentifier:TableSampleIdentifier];
            }

            cell.textLabel.text = @"设置涨跌示意颜色";
            cell.textLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
            cell.detailTextLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
            int tag=[[Utiles getConfigureInfoFrom:@"userconfigure" andKey:@"stockColorSetting" inUserDomain:YES] intValue];
            if(tag==0){
                cell.detailTextLabel.text=@"红涨绿跌";
            }else if(tag==1){
                cell.detailTextLabel.text=@"绿涨红跌";
            }else if(tag==2){
                cell.detailTextLabel.text=@"黄涨蓝跌";
            }
            
            return cell;
            
        }else if(row==1){
            
            static NSString *LabelSwitchCellIdentifier = @"LabelSwitchCellIdentifier";
            
            LabelSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                     LabelSwitchCellIdentifier];
            if (cell == nil) {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"LabelSwitchCell" owner:self options:nil];
                cell = array[0];
            }
            BOOL isOn=[Utiles stringToBool:[Utiles getConfigureInfoFrom:@"userconfigure" andKey:@"wifiImg" inUserDomain:YES]];
            cell.titleLabel.text = @"仅在wifi下加载图片";
            cell.titleLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
            [cell.controlSwitch setOn:isOn animated:YES];
            [cell.controlSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
            cell.controlSwitch.tag=1;
            return cell;
            
        }else if(row==2){
            
            static NSString *LabelSwitchCellIdentifier = @"LabelSwitchCellIdentifier";
            
            LabelSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                     LabelSwitchCellIdentifier];
            if (cell == nil) {
                NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"LabelSwitchCell" owner:self options:nil];
                cell = array[0];
            }
            BOOL isOn=[Utiles stringToBool:[Utiles getConfigureInfoFrom:@"userconfigure" andKey:@"checkUpdate" inUserDomain:YES]];
            [cell.controlSwitch setOn:isOn animated:YES];
            cell.titleLabel.text = @"启动检查更新";
            cell.titleLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
            [cell.controlSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
            cell.controlSwitch.tag=2;
            return cell;
            
        }
        
        
        
        
    }else if(indexPath.section==1){
        
        static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                 TableSampleIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]
                    initWithStyle:UITableViewCellStyleValue1
                    reuseIdentifier:TableSampleIdentifier];
        }
        
        cell.textLabel.text = @"清除缓存";
        cell.textLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
        cell.detailTextLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
        NSString *catchSize=[NSString stringWithFormat:@"%@KB",[Utiles getCatchSize]];
        cell.detailTextLabel.text=catchSize;
        
        return cell;
        
    }else if(indexPath.section==2){
        
        if(row==0){
            static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                     TableSampleIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]
                        initWithStyle:UITableViewCellStyleSubtitle
                        reuseIdentifier:TableSampleIdentifier];
            }
            
            cell.textLabel.text = @"意见反馈";
            cell.textLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
            cell.detailTextLabel.font=[UIFont fontWithName:@"Heiti SC" size:12.0f];
            cell.detailTextLabel.text=@"用户意见反馈";
            
            return cell;
        }else if(row==1){
            
            static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                                     TableSampleIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]
                        initWithStyle:UITableViewCellStyleSubtitle
                        reuseIdentifier:TableSampleIdentifier];
            }
            
            cell.textLabel.text = @"关于我们";
            cell.textLabel.font=[UIFont fontWithName:@"Heiti SC" size:16.0f];
            cell.detailTextLabel.font=[UIFont fontWithName:@"Heiti SC" size:12.0f];
            cell.detailTextLabel.text=@"关于我们，版权信息";
            
            return cell;
        }
        
    }

    return nil;
}



#pragma mark -
#pragma mark Table Delegate Methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row=indexPath.row;
    NSInteger section=indexPath.section;
    
    if(section==0){
        if(row==0){
            StockRiseDownColorSettingViewController *set=[[StockRiseDownColorSettingViewController alloc] init];
            [self presentViewController:set animated:YES completion:nil];
            [set release];
        }
    }else if(section==1){
        //[Utiles deleteSandBoxContent];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text=@"0";
    }else if(section==2){
        if(row==1){
            AboutUsAndCopyrightViewController *us=[[AboutUsAndCopyrightViewController alloc] init];
            [self.navigationController pushViewController:us animated:YES];
            [us release];
        }else if(row==0){
            FeedBackViewController *fd=[[FeedBackViewController alloc] init];
            [self.navigationController pushViewController:fd animated:YES];
            SAFE_RELEASE(fd);
        }
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}








- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(BOOL)shouldAutorotate{
    return NO;
}




















@end

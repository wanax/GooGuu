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
#import "PrettyKit.h"
#import "Utiles.h"
#import "NimbusModels.h"
#import "NimbusCore.h"

@interface SettingCenterViewController ()

@end

@implementation SettingCenterViewController

@synthesize top;

@synthesize model = _model;
@synthesize subRadioGroup = _subRadioGroup;
@synthesize actions=_actions;

- (void)dealloc
{
    [_actions release];_actions=nil;
    [_model release];_model=nil;
    [_subRadioGroup release];_subRadioGroup=nil;
    [top release];top=nil;
    [super dealloc];
}

NICellDrawRectBlock drawTextBlock = ^CGFloat(CGRect rect, id object, NICellObject *cell) {
    
    NSString* text = [object objectForKey:@"title"];
    UIFont* titleFont = [UIFont fontWithName:@"Courier" size:15.0f];
    [text drawAtPoint:CGPointMake(10, 13) withFont:titleFont];
    [[UIColor grayColor] set];
    NSString *subTitle=[NSString stringWithFormat:@"%@",[object objectForKey:@"subtitle"]];
    if([subTitle isEqualToString:@"估股高端大气上档次必用"]){
        [subTitle drawAtPoint:CGPointMake(CGRectGetMaxX(rect)-175, 12) withFont:[UIFont systemFontOfSize:15]];
    }else{
        [subTitle drawAtPoint:CGPointMake(CGRectGetMaxX(rect)-65-[subTitle length], 12) withFont:[UIFont systemFontOfSize:15]];
    }
    
    return 0;
};

-(void)unitInit{

    
    _subRadioGroup = [[NIRadioGroup alloc] initWithController:self];
    _subRadioGroup.delegate = self;
    _subRadioGroup.cellTitle = @"设置涨跌示意颜色";
    //_subRadioGroup.controllerTitle = @"Make a Selection";
    
    [_subRadioGroup mapObject:[NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:[NSDictionary dictionaryWithObjectsAndKeys:@"红涨绿跌",@"title",@"大陆常用",@"subtitle", nil]]
                 toIdentifier:SubRadioOption1];
    [_subRadioGroup mapObject:[NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:[NSDictionary dictionaryWithObjectsAndKeys:@"绿涨红跌",@"title",@"墙外常用",@"subtitle", nil]]
                 toIdentifier:SubRadioOption2];
    [_subRadioGroup mapObject:[NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:[NSDictionary dictionaryWithObjectsAndKeys:@"黄涨蓝跌",@"title",@"估股高端大气上档次必用",@"subtitle", nil]]
                 toIdentifier:SubRadioOption3];
   
}


- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {

        [self unitInit];
        
        
        
        _actions = [[NITableViewActions alloc] initWithTarget:self];

        NIActionBlock tapAction = ^BOOL(id object, UIViewController *controller, NSIndexPath* indexPath) {
            NSLog(@"%@",indexPath);
            return YES;
        };
        
        BOOL isOn=[Utiles stringToBool:[Utiles getConfigureInfoFrom:@"userconfigure" andKey:@"wifiImg" inUserDomain:YES]];

        NSArray* tableContents =
        [NSArray arrayWithObjects:
         @"图片设置",
         [NISwitchFormElement switchElementWithID:0 labelText:@"仅wifi下显示图片" value:isOn didChangeTarget:self didChangeSelector:@selector(switchChange:)],
         [_actions attachToObject:[NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:[NSDictionary dictionaryWithObjectsAndKeys:@"清除缓存",@"title",@"剩余空间",@"subtitle", nil]]
                         tapBlock:tapAction],
         @"",
         _subRadioGroup,
         @"",
         [_actions attachToObject:[NIDrawRectBlockCellObject objectWithBlock:drawTextBlock object:[NSDictionary dictionaryWithObjectsAndKeys:@"意见反馈",@"title",@"",@"subtitle", nil]]
                  navigationBlock:NIPushControllerAction([UIViewController class])],
         nil];
        
        self.subRadioGroup.selectedIdentifier = [[Utiles getConfigureInfoFrom:@"userconfigure" andKey:@"stockColorSetting" inUserDomain:YES] intValue];
        [_actions attachToClass:[NITitleCellObject class] tapBlock:tapAction];
        _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                         delegate:(id)[NICellFactory class]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"设置"];
    
    self.navigationController.navigationBarHidden=NO;
    self.tableView.rowHeight=45;
    self.tableView.dataSource = _model;
    self.tableView.delegate = [self.actions forwardingTo:[self.subRadioGroup forwardingTo:self.tableView.delegate]];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
}


-(void)switchChange:(UISwitch *)p{

    BOOL isButtonOn = [p isOn];
    if (isButtonOn) {
        [Utiles setConfigureInfoTo:@"userconfigure" forKey:@"wifiImg" andContent:@"1"];
    }else {
        [Utiles setConfigureInfoTo:@"userconfigure" forKey:@"wifiImg" andContent:@"0"];
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate


#pragma mark - NIRadioGroupDelegate

- (void)radioGroup:(NIRadioGroup *)radioGroup didSelectIdentifier:(NSInteger)identifier {

    [Utiles setConfigureInfoTo:@"userconfigure" forKey:@"stockColorSetting" andContent:[NSString stringWithFormat:@"%d",identifier]];

}

- (NSString *)radioGroup:(NIRadioGroup *)radioGroup textForIdentifier:(NSInteger)identifier {
    switch (identifier) {
        case SubRadioOption1:
            return @"红涨绿跌";
        case SubRadioOption2:
            return @"绿涨红跌";
        case SubRadioOption3:
            return @"黄涨蓝跌";
    }
    return nil;
}


-(BOOL)shouldAutorotate{
    return NO;
}


@end

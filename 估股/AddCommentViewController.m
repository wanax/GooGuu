//
//  AddCommentViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-16.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "AddCommentViewController.h"
#import "AFImageRequestOperation.h"

@interface AddCommentViewController ()

@end

@implementation AddCommentViewController

@synthesize commentField;
@synthesize titleLabel;
@synthesize articleId;
@synthesize type;

- (void)dealloc
{
    [articleId release];
    [commentField release];
    [titleLabel release];
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
	// Do any additional setup after loading the view.
    self.commentField.returnKeyType=UIReturnKeyGo;
    [self.view setBackgroundColor:[Utiles colorWithHexString:@"#EFEBD9"]];
    if(self.type==CompanyType||self.type==ArticleType){
        UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        back.frame=CGRectMake(30,150,60,40);
        [back setTitle:@"取消" forState:UIControlStateNormal];
        back.tintColor=[UIColor blackColor];
        [back addTarget:self action:@selector(btClick:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:back];
    }
}

-(void)btClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark TextField Methods Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    if(self.type==CompanyType){
         NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:articleId,@"stockcode",textField.text,@"msg",[Utiles getUserToken],@"token",@"googuu",@"from",nil];
        [Utiles postNetInfoWithPath:@"CompanyReview" andParams:params besidesBlock:^(id obj){
            if([[obj objectForKey:@"status"] isEqualToString:@"1"]){
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                [Utiles ToastNotification:@"发布失败" andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
            }
        }];        
    }else{
        NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:articleId,@"articleid",textField.text,@"msg",[Utiles getUserToken],@"token",@"googuu",@"from",nil];
        [Utiles postNetInfoWithPath:@"ContentrReply" andParams:params besidesBlock:^(id resObj){
            if([[resObj objectForKey:@"status"] isEqualToString:@"1"]){
                if(self.type==NewsType){
                   [(UINavigationController *)self.parentViewController popViewControllerAnimated:YES]; 
                }else if(self.type==ArticleType){
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                
            }else{
                [Utiles ToastNotification:@"发布失败" andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
            }
        }];
    }
    return YES;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
















@end

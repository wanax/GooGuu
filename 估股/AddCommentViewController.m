//
//  AddCommentViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-16.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "AddCommentViewController.h"
#import "AFImageRequestOperation.h"
#import "UIButton+BGColor.h"

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
    self.commentField.returnKeyType=UIReturnKeySend;
    [self.view setBackgroundColor:[Utiles colorWithHexString:@"#EFEBD9"]];
    if(self.type==CompanyType||self.type==ArticleType){
        UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        [back setFrame:CGRectMake(30,150,50,30)];
        [back setTitle:@"返回" forState:UIControlStateNormal];
        [back setBackgroundColor:[UIColor clearColor]];
        [back.titleLabel setFont:[UIFont fontWithName:@"Heiti SC" size:13.0]];
        [back setBackgroundImage:[UIImage imageNamed:@"resetBt"] forState:UIControlStateNormal];
        [back setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [back addTarget:self action:@selector(btClick:) forControlEvents:UIControlEventTouchDown];
        [self.view addSubview:back];
    }
}

-(void)btClick:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backgroundTap:(id)sender {
    [commentField resignFirstResponder];
}

#pragma mark -
#pragma mark TextField Methods Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    if(self.type==CompanyType){
         NSDictionary *params=@{@"stockcode": articleId,@"msg": textField.text,@"token": [Utiles getUserToken],@"from": @"googuu"};
        [Utiles postNetInfoWithPath:@"CompanyReview" andParams:params besidesBlock:^(id obj){
            if([obj[@"status"] isEqualToString:@"1"]){
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                [Utiles ToastNotification:@"发布失败" andView:self.view andLoading:NO andIsBottom:NO andIsHide:YES];
            }
        }];        
    }else{
        NSDictionary *params=@{@"articleid": articleId,@"msg": textField.text,@"token": [Utiles getUserToken],@"from": @"googuu"};
        [Utiles postNetInfoWithPath:@"ContentrReply" andParams:params besidesBlock:^(id resObj){
            if([resObj[@"status"] isEqualToString:@"1"]){
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

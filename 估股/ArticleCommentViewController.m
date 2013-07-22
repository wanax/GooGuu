//
//  ArticleCommentViewController.m
//  UIDemo
//
//  Created by Xcode on 13-7-16.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "ArticleCommentViewController.h"
#import "ArticleCommentModel.h"
#import "Utiles.h"
#import "UserCell.h"
#import "MHTabBarController.h"
#import "UIImageView+AFNetworking.h"
#import "AddCommentViewController.h"

@interface ArticleCommentViewController ()

@end

@implementation ArticleCommentViewController

@synthesize articleId;
@synthesize cusTable;
@synthesize commentArr;

- (void)dealloc
{
    [commentArr release];
    [cusTable release];
    [articleId release];
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
    UIBarButtonItem *wanSay=[[UIBarButtonItem alloc] initWithTitle:@"添加评论" style:nil target:self action:@selector(wanSay:)];
    self.parentViewController.navigationItem.rightBarButtonItem=wanSay;
    CATransition *transition=[CATransition animation];
    transition.duration=0.4f;
    transition.fillMode=kCAFillModeForwards;
    transition.type=kCATruncationMiddle;
    transition.subtype=kCATransitionFromRight;
    [self.parentViewController.navigationController.navigationBar.layer addAnimation:transition forKey:@"animation"];
    [self getComment];
    
}

-(void)wanSay:(id)sender{
    AddCommentViewController *addCommentViewController=[[AddCommentViewController alloc] initWithNibName:@"AddCommentView" bundle:nil];
    addCommentViewController.articleId=self.articleId;
    addCommentViewController.type=ArticleType;
    [(UINavigationController *)self.parentViewController.parentViewController pushViewController:addCommentViewController animated:YES];
    [addCommentViewController release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    nibsRegistered=NO;
    self.cusTable=[[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    self.cusTable.dataSource=self;
    self.cusTable.delegate=self;
    [self.view addSubview:cusTable];
    
    [self getComment];
    
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:pan];
    [pan release];
}

-(void)panView:(UIPanGestureRecognizer *)tap{
    CGPoint change=[tap translationInView:self.view];
    
    if(change.x>FINGERCHANGEDISTANCE){
        [(MHTabBarController *)self.parentViewController setSelectedIndex:0 animated:YES];
    }
}

-(void)getComment{

    NSDictionary *params=[NSDictionary dictionaryWithObjectsAndKeys:self.articleId,@"articleid", nil];
    [Utiles getNetInfoWithPath:@"Commentary" andParams:params besidesBlock:^(id resObj){
        self.commentArr=resObj;
        
        [self.cusTable reloadData];
    }];
    
}

#pragma mark -
#pragma mark Table Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.commentArr count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *UserCellIdentifier = @"UserCellIdentifier";
    
    if(!nibsRegistered){
        UINib *nib=[UINib nibWithNibName:@"UserCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:UserCellIdentifier];
        nibsRegistered = YES;
    }
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:UserCellIdentifier];
    if (cell == nil) {
        cell = [[UserCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:UserCellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    id model=[self.commentArr objectAtIndex:row];
    
    cell.name = [model objectForKey:@"author"];
    cell.dec = [model objectForKey:@"content"];
    cell.loc = [model objectForKey:@"updatetime"];
    
    @try {
        if([[NSString stringWithFormat:@"%@",[model objectForKey:@"headerpicurl"]] length]>7){
            //异步加载cell图片
        [cell.imageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[model objectForKey:@"headerpicurl"]]]
          placeholderImage:[UIImage imageNamed:@"pumpkin.png"]
                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                       cell.image = image;
                       
                   }
                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                       
                   }];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception);
    }

    return cell;
}



#pragma mark -
#pragma mark Table Methods Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 58.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


























@end

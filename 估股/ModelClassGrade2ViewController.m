//
//  ModelClassGrade2ViewController.m
//  估股
//
//  Created by Xcode on 13-8-2.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "ModelClassGrade2ViewController.h"
#import "CQMFloatingController.h"

#define ClassGrade2CellIdentifier  @"UITable2ViewCell"

@interface ModelClassGrade2ViewController ()

@end

@implementation ModelClassGrade2ViewController

@synthesize delegate;

@synthesize jsonData;
@synthesize indicator;
@synthesize indicatorClass;
@synthesize indicatorClassKey;

- (void)dealloc
{
    [delegate release];delegate=nil;
    [indicatorClassKey release];indicatorClassKey=nil;
    [jsonData release];jsonData=nil;
    [indicator release];indicator=nil;
    [indicatorClass release];indicatorClass=nil;
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
    [self.navigationItem setTitle:@"行业选择"];
    id tempClass=[jsonData objectForKey:indicator];
    NSMutableDictionary *tempDic=[[NSMutableDictionary alloc] init];
    NSMutableArray *tempArr=[[NSMutableArray alloc] init];
    for(id obj in tempClass){
        [tempDic setObject:[obj objectForKey:@"id"] forKey:[obj objectForKey:@"name"]];
        [tempArr addObject:[obj objectForKey:@"name"]];
    }
    self.indicatorClass=tempDic;
    self.indicatorClassKey=tempArr;
    [tempArr release];
    [tempDic release];
    
}





#pragma mark -
#pragma mark UITableViewController


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.indicatorClass count];
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ClassGrade2CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:ClassGrade2CellIdentifier] autorelease];
	}
	NSString *text =[self.indicatorClassKey objectAtIndex:indexPath.row];
	[cell.textLabel setText:text];
    cell.textLabel.font=[UIFont fontWithName:@"Heiti SC" size:15.0f];
	
	return cell;
}

#pragma mark -
#pragma mark Table Methods Delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	
    [delegate modelClassChanged:[self.indicatorClass objectForKey:[self.indicatorClassKey objectAtIndex:indexPath.row]]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CQMFloatingController *floatingController = [CQMFloatingController sharedFloatingController];
    [floatingController dismissAnimated:YES];
    
    
}







- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

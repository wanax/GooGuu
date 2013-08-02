//
//  ModelClassViewController.m
//  估股
//
//  Created by Xcode on 13-8-1.
//  Copyright (c) 2013年 Xcode. All rights reserved.
//

#import "ModelClassViewController.h"
#import "ModelClassGrade2ViewController.h"

#define ClassCellIdentifier  @"UITableViewCell"

@interface ModelClassViewController ()

@end

@implementation ModelClassViewController

@synthesize delegate;
@synthesize jsonData;
@synthesize modelClass;
@synthesize customTable;

- (void)dealloc
{
    [delegate release];delegate=nil;
    [jsonData release];jsonData=nil;
    [customTable release];customTable=nil;
    [modelClass release];modelClass=nil;
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
    
    self.modelClass=[jsonData allKeys];
    
}


#pragma mark -
#pragma mark UITableViewController


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.modelClass count];
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ClassCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									   reuseIdentifier:ClassCellIdentifier] autorelease];
	}
	
	NSString *text = [self.modelClass objectAtIndex:[indexPath row]];
	[cell.textLabel setText:text];
    cell.textLabel.font=[UIFont fontWithName:@"Heiti SC" size:15.0f];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
	return cell;
}

#pragma mark -
#pragma mark Table Methods Delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	
    ModelClassGrade2ViewController *grade2=[[ModelClassGrade2ViewController alloc] init];
    grade2.delegate=self;
    grade2.indicator=[self.modelClass objectAtIndex:indexPath.row];
    grade2.jsonData=self.jsonData;    
    [self.navigationController pushViewController:grade2 animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [grade2 release];
    
}

-(void)modelClassChanged:(NSString *)driverId{
    [delegate toldYouClassChanged:driverId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}















@end

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
@synthesize radioGroup = _radioGroup;
@synthesize subRadioGroup = _subRadioGroup;

- (void)dealloc
{
    [_model release];_model=nil;
    [_radioGroup release];_radioGroup=nil;
    [_subRadioGroup release];_subRadioGroup=nil;
    [top release];top=nil;
    [super dealloc];
}



- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        self.title = @"Form Cell Catalog";
        
        _radioGroup = [[NIRadioGroup alloc] init];
        _radioGroup.delegate = self;
        
        _subRadioGroup = [[NIRadioGroup alloc] initWithController:self];
        _subRadioGroup.delegate = self;
        _subRadioGroup.cellTitle = @"Selection";
        _subRadioGroup.controllerTitle = @"Make a Selection";
        
        [_subRadioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Sub Radio 1"
                                                               subtitle:@"First option"]
                     toIdentifier:SubRadioOption1];
        [_subRadioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Sub Radio 2"
                                                               subtitle:@"Second option"]
                     toIdentifier:SubRadioOption2];
        [_subRadioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Sub Radio 3"
                                                               subtitle:@"Third option"]
                     toIdentifier:SubRadioOption3];
        
        NSArray* tableContents =
        [NSArray arrayWithObjects:
         @"Radio Group",
         [_radioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Radio 1"
                                                             subtitle:@"First option"]
                   toIdentifier:RadioOption1],
         [_radioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Radio 2"
                                                             subtitle:@"Second option"]
                   toIdentifier:RadioOption2],
         [_radioGroup mapObject:[NISubtitleCellObject objectWithTitle:@"Radio 3"
                                                             subtitle:@"Third option"]
                   toIdentifier:RadioOption3],
         @"Radio Group Controller",
         _subRadioGroup,
         
         @"NITextInputFormElement",
         [NITextInputFormElement textInputElementWithID:0 placeholderText:@"Placeholder" value:nil],
         [NITextInputFormElement textInputElementWithID:0 placeholderText:@"Placeholder" value:@"Initial value"],
         [NITextInputFormElement textInputElementWithID:1 placeholderText:nil value:@"Disabled input field" delegate:self],
         [NITextInputFormElement passwordInputElementWithID:0 placeholderText:@"Password" value:nil],
         [NITextInputFormElement passwordInputElementWithID:0 placeholderText:@"Password" value:@"Password"],
         
         @"NISwitchFormElement",
         [NISwitchFormElement switchElementWithID:0 labelText:@"Switch" value:NO],
         [NISwitchFormElement switchElementWithID:0 labelText:@"Switch with a really long label that will be cut off" value:YES],
         
         @"NISliderFormElement",
         [NISliderFormElement sliderElementWithID:0
                                        labelText:@"Slider"
                                            value:45
                                     minimumValue:0
                                     maximumValue:100],
         
         @"NISegmentedControlFormElement",
         [NISegmentedControlFormElement segmentedControlElementWithID:0
                                                            labelText:@"Text segments"
                                                             segments:[NSArray arrayWithObjects:
                                                                       @"one", @"two", nil]
                                                        selectedIndex:0],
         [NISegmentedControlFormElement segmentedControlElementWithID:0
                                                            labelText:@"Image segments"
                                                             segments:[NSArray arrayWithObjects:
                                                                       [UIImage imageNamed:@"star.png"],
                                                                       [UIImage imageNamed:@"circle.png"],
                                                                       nil]
                                                        selectedIndex:-1
                                                      didChangeTarget:self
                                                    didChangeSelector:@selector(segmentedControlWithImagesDidChangeValue:)],
         @"NIDatePickerFormElement",
         [NIDatePickerFormElement datePickerElementWithID:0
                                                labelText:@"Date and time"
                                                     date:[NSDate date]
                                           datePickerMode:UIDatePickerModeDateAndTime],
         [NIDatePickerFormElement datePickerElementWithID:0
                                                labelText:@"Date only"
                                                     date:[NSDate date]
                                           datePickerMode:UIDatePickerModeDate],
         [NIDatePickerFormElement datePickerElementWithID:0
                                                labelText:@"Time only"
                                                     date:[NSDate date]
                                           datePickerMode:UIDatePickerModeTime
                                          didChangeTarget:self
                                        didChangeSelector:@selector(datePickerDidChangeValue:)],
         [NIDatePickerFormElement datePickerElementWithID:0
                                                labelText:@"Countdown"
                                                     date:[NSDate date]
                                           datePickerMode:UIDatePickerModeCountDownTimer],
         nil];
        
        self.radioGroup.selectedIdentifier = RadioOption1;
        self.subRadioGroup.selectedIdentifier = SubRadioOption1;
        
        // We let the Nimbus cell factory create the cells.
        _model = [[NITableViewModel alloc] initWithSectionedArray:tableContents
                                                         delegate:(id)[NICellFactory class]];
    }
    return self;
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
    
    self.tableView.dataSource = _model;
    
    self.tableView.delegate = [self.radioGroup forwardingTo:
                               [self.subRadioGroup forwardingTo:self.tableView.delegate]];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    // When including text editing cells in table views you should provide a means for the user to
    // stop editing the control. To do this we add a gesture recognizer to the table view.
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapTableView)];
    
    // We still want the table view to be able to process touch events when we tap.
    tap.cancelsTouchesInView = NO;
    
    [self.tableView addGestureRecognizer:tap];
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)segmentedControlWithImagesDidChangeValue:(UISegmentedControl *)segmentedControl {
    NIDPRINT(@"Segmented control changed value to index %d", segmentedControl.selectedSegmentIndex);
}

- (void)datePickerDidChangeValue:(UIDatePicker *)picker {
    NIDPRINT(@"Time only date picker changed value to %@",
             [NSDateFormatter localizedStringFromDate:picker.date
                                            dateStyle:NSDateFormatterNoStyle
                                            timeStyle:NSDateFormatterShortStyle]);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        return NO;
    }
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Customize the presentation of certain types of cells.
    if ([cell isKindOfClass:[NITextInputFormElementCell class]]) {
        NITextInputFormElementCell* textInputCell = (NITextInputFormElementCell *)cell;
        if (1 == cell.tag) {
            // Make the disabled input field look slightly different.
            textInputCell.textField.textColor = [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1];
            
        } else {
            // We must always handle the else case because cells can be reused.
            textInputCell.textField.textColor = [UIColor blackColor];
        }
    }
}

#pragma mark - NIRadioGroupDelegate

- (void)radioGroup:(NIRadioGroup *)radioGroup didSelectIdentifier:(NSInteger)identifier {
    if (radioGroup == self.radioGroup) {
        NSLog(@"Radio group selection: %d", identifier);
    } else if (radioGroup == self.subRadioGroup) {
        NSLog(@"Sub radio group selection: %d", identifier);
    }
}

- (NSString *)radioGroup:(NIRadioGroup *)radioGroup textForIdentifier:(NSInteger)identifier {
    switch (identifier) {
        case SubRadioOption1:
            return @"Option 1";
        case SubRadioOption2:
            return @"Option 2";
        case SubRadioOption3:
            return @"Option 3";
    }
    return nil;
}

#pragma mark - Gesture Recognizers

- (void)didTapTableView {
    [self.view endEditing:YES];
}

-(BOOL)shouldAutorotate{
    return NO;
}


@end

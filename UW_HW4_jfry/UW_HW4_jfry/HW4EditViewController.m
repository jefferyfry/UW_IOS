//
//  HW4EditViewController.m
//  UW_HW4_jfry
//
//  Created by Jeffery Fry on 10/30/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "HW4EditViewController.h"

@interface HW4EditViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation HW4EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    _nameField.delegate=self;
    if(_index!=-1){
        _nameField.text=[_nameBirthdayManager nameAtIndex:_index];
        _datePicker.date=[_nameBirthdayManager birthdayAtIndex:_index];
    }
}

-(void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)done:(id)sender {
    if(_index!=-1)
        [_nameBirthdayManager updateNameBirthday:_nameField.text withBirthday:_datePicker.date atIndex:_index];
    else
        [_nameBirthdayManager addNameBirthday:_nameField.text withBirthday:_datePicker.date];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [_nameField resignFirstResponder];
    return YES;
}

@end

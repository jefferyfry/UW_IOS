//
//  EditCredientialViewController.m
//  UW_HW7_jfry
//
//  Created by Jeffery Fry on 11/20/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "EditCredientialViewController.h"

@interface EditCredientialViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *websiteTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UILabel *touchIdLabel;
@property (weak, nonatomic) IBOutlet UISwitch *touchIdSwitch;
@end

@implementation EditCredientialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.websiteTextField.delegate=self;
    self.usernameTextField.delegate=self;
    self.passwordTextField.delegate=self;
    self.passwordConfirmTextField.delegate=self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.addIfTrue){
        self.websiteTextField.enabled=YES;
        self.usernameTextField.enabled=YES;
        self.passwordTextField.enabled=YES;
        self.passwordConfirmTextField.enabled=YES;
        self.touchIdLabel.hidden=NO;
        self.touchIdSwitch.hidden=NO;
        self.navigationController.navigationBar.topItem.title = @"Add Credentials";
    }
    else {
        self.websiteTextField.enabled=NO;
        self.websiteTextField.text=self.websiteString;
        self.usernameTextField.enabled=NO;
        self.usernameTextField.text=self.usernameString;
        self.passwordTextField.enabled=YES;
        self.passwordConfirmTextField.enabled=YES;
        self.touchIdLabel.hidden=YES;
        self.touchIdSwitch.hidden=YES;
        self.navigationController.navigationBar.topItem.title = @"Update Credentials";
        
        //query password
        NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassInternetPassword,
                               (__bridge id)kSecAttrAccount: self.usernameString,
                               (__bridge id)kSecAttrServer: self.websiteString,
                               (__bridge id)kSecReturnData:(__bridge id)kCFBooleanTrue};
        
        CFTypeRef result = nil;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), &result);
        if(status!=errSecSuccess){
            NSLog(@"Error querying keychain: %d",status);
            UIAlertController *alert = [self alertWithTitle:@"Update Credential Error!" andMessage:@"Unable to retrieve password."];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else {
            NSData *data = (__bridge NSData *)result;
            NSString *password = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            self.passwordTextField.text=password;
            self.passwordConfirmTextField.text=password;
        }
    }
}

- (IBAction)fireDone:(id)sender {
    if(self.addIfTrue){ //add
        if(self.websiteTextField.text.length==0 || self.usernameTextField.text.length==0 || self.passwordTextField.text.length==0|| self.passwordConfirmTextField.text.length==0){
            UIAlertController *alert = [self alertWithTitle:@"Add Credential Error!" andMessage:@"Please complete all fields."];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else if (![self.passwordTextField.text isEqualToString: self.passwordConfirmTextField.text]){
            UIAlertController *alert = [self alertWithTitle:@"Add Credential Error!" andMessage:@"Password fields do not match."];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        NSDictionary *attr;
        if(self.touchIdSwitch.on==YES){
            NSError *error;
            CFErrorRef cfError = (__bridge CFErrorRef)error;
            SecAccessControlRef accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, kSecAccessControlUserPresence, &cfError);
            
            if (accessControl == NULL || error != NULL)
                NSLog(@"Cannot create SecAccessControlRef to query the key chain: %@.", error);
            
            attr = @{(__bridge id)kSecClass: (__bridge id)kSecClassInternetPassword,
                                   (__bridge id)kSecAttrAccount: self.usernameTextField.text,
                                   (__bridge id)kSecAttrServer: self.websiteTextField.text,
                                   (__bridge id)kSecValueData:[self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding],
                                   (__bridge id)kSecAttrAccessControl:(__bridge id)accessControl};
        }
        else {
            attr = @{(__bridge id)kSecClass: (__bridge id)kSecClassInternetPassword,
                                   (__bridge id)kSecAttrAccount: self.usernameTextField.text,
                                   (__bridge id)kSecAttrServer: self.websiteTextField.text,
                                   (__bridge id)kSecValueData:[self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding]};
        }
        
//        NSDictionary *attr = @{(__bridge id)kSecClass: (__bridge id)kSecClassInternetPassword,
//                 (__bridge id)kSecAttrAccount: self.usernameTextField.text,
//                 (__bridge id)kSecAttrServer: self.websiteTextField.text,
//                 (__bridge id)kSecValueData:[self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding]};
        
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)(attr), nil);
        
        if(status!=errSecSuccess){
            NSString *errorString = [NSString stringWithFormat:@"Keychain update error %d",status];
            if(status==-25299)
                errorString = @"Credentials already exist!";
            UIAlertController *alert = [self alertWithTitle:@"Add Credential Error!" andMessage:errorString];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
            [self dismissViewControllerAnimated:YES completion:nil];
    }
    else { //update
        if (![self.passwordTextField.text isEqualToString: self.passwordConfirmTextField.text]){
            UIAlertController *alert = [self alertWithTitle:@"Update Credential Error!" andMessage:@"Password fields do not match."];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        //query
        NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassInternetPassword,
                                (__bridge id)kSecAttrAccount: self.usernameString,
                                (__bridge id)kSecAttrServer: self.websiteString};
        
        NSDictionary *attrUpdate = @{(__bridge id)kSecValueData:[self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding]};
        
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attrUpdate);
        
        if(status!=errSecSuccess){
            UIAlertController *alert = [self alertWithTitle:@"Update Credential Error!" andMessage:[NSString stringWithFormat:@"Keychain update error %d",status]];
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
            [self dismissViewControllerAnimated:YES completion:nil];

    }
}

- (IBAction)fireCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    if(textField == self.passwordConfirmTextField)
        [self fireDone:self];
    else {
        NSInteger nextTag = textField.tag + 1;
        // Try to find next responder
        UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
        if (nextResponder) {
            // Found next responder, so set it.
            [nextResponder becomeFirstResponder];
        } else {
            // Not found, so remove keyboard.
            [textField resignFirstResponder];
        }
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

-(UIAlertController*)alertWithTitle: (NSString*)title andMessage: (NSString*)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    return alert;
}



@end

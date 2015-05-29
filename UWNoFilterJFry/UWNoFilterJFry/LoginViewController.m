//
//  LoginViewController.m
//  UWNoFilterJFry
//
//  Created by Jeffery Fry on 2/19/15.
//  Copyright (c) 2015 Jeff_Fry. All rights reserved.
//

#import "LoginViewController.h"
#import "NoFilterClient.h"

@interface LoginViewController () <UITextFieldDelegate,NoFilterClientDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *loginCreateSegment;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (strong,nonatomic) NoFilterClient *noFilterClient;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noFilterClient = [NoFilterClient sharedClient];
    self.noFilterClient.delegate=self;
    self.usernameField.text=@"";
    self.passwordField.text=@"";
    self.passwordConfirmField.text=@"";
    self.activityIndicatorView.hidden=YES;
    self.passwordConfirmField.hidden=YES;
    self.goButton.enabled=NO;
    [self.loginCreateSegment setSelectedSegmentIndex:0];
    self.usernameField.delegate=self;
    self.passwordField.delegate=self;
    self.passwordConfirmField.delegate=self;
}

- (IBAction)doLoginCreate:(id)sender {
    if([self.loginCreateSegment selectedSegmentIndex]==1){
        self.passwordConfirmField.hidden=NO;
        if(([self.usernameField.text length]>2)
           &&([self.passwordField.text length]>2)
           &&([self.passwordConfirmField.text length]>2))
            self.goButton.enabled=YES;
        else
            self.goButton.enabled=NO;
    }
    else {
        self.passwordConfirmField.hidden=YES;
        if(([self.usernameField.text length]>2)
           &&([self.passwordField.text length]>2))
            self.goButton.enabled=YES;
        else
            self.goButton.enabled=NO;
    }
}


- (IBAction)doGo:(id)sender {
    self.activityIndicatorView.hidden=NO;
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([self.loginCreateSegment selectedSegmentIndex]==0){ //do login
        [self.noFilterClient loginUser:username withPassword:password];
    }
    else { //do create
        NSString *passwordConfirm = [self.passwordConfirmField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([passwordConfirm isEqualToString:password])
            [self.noFilterClient registerNewUser:username withPassword:password];
        else {
            self.activityIndicatorView.hidden=YES;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Password Match" message:@"Password fields do not match." preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action) {
                                                               [alert dismissViewControllerAnimated:YES completion:nil];
                                                           }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([self.loginCreateSegment selectedSegmentIndex]==0){ //do login
        if(([self.usernameField.text length]>2)
            &&([self.passwordField.text length]>2))
            self.goButton.enabled=YES;
    }
    else { //do create
        if(([self.usernameField.text length]>2)
           &&([self.passwordField.text length]>2)
           &&([self.passwordConfirmField.text length]>2))
            self.goButton.enabled=YES;
    }
    return YES;
}

-(void)loginUserResult:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.activityIndicatorView.hidden=YES;
        NSLog(@"User login:%@",(success ? @"YES" : @"NO"));
        if(success){
            LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotosCollectionView"];
            
            [self presentViewController:vc animated:YES completion:nil];
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Login" message:@"Login failed." preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }

    });
}

-(void)registerUserResult:(BOOL)success {
    NSLog(@"Registered new user:%@",(success ? @"YES" : @"NO"));
    if(!success){
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Register" message:@"Registration failed. Please choose another username." preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

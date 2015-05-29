//
//  MyCredentialsTableViewController.m
//  UW_HW7_jfry
//
//  Created by Jeffery Fry on 11/20/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "MyCredentialsTableViewController.h"
#import "CredentialTableViewCell.h"
#import "EditCredientialViewController.h"

@interface MyCredentialsTableViewController ()
@property (nonatomic,strong) NSArray *credentialsAttrArray;
@end

@implementation MyCredentialsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _credentialsAttrArray = [NSArray new];
    self.navigationController.navigationBar.topItem.title = @"My Credentials";
    [self resetKeychain];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadKeychains];
}

-(void)loadKeychains {
    //query and load credentials
//    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassInternetPassword,
//                            (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue,
//                            (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll};
    
    NSError *error;
    CFErrorRef cfError = (__bridge CFErrorRef)error;
    SecAccessControlRef accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, kSecAccessControlUserPresence, &cfError);
    
    if (accessControl == NULL || error != NULL)
        NSLog(@"Cannot create SecAccessControlRef to query the key chain: %@.", error);
    
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)kSecClassInternetPassword,
                            (__bridge id)kSecReturnAttributes: (__bridge id)kCFBooleanTrue,
                            (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll,
                            (__bridge id)kSecAttrAccessControl:(__bridge id)accessControl};
    
    
    CFArrayRef results = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), (CFTypeRef*)&results);
    if(status!=errSecSuccess){
        NSLog(@"Error querying keychain: %d",status);
    }
    else {
        _credentialsAttrArray = (__bridge NSArray*)results;
        [self.tableView reloadData];
    }
}

-(void)resetKeychain {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:(__bridge id)kSecClassInternetPassword forKey:(__bridge id)kSecClass];
    OSStatus result = SecItemDelete((__bridge CFDictionaryRef) dict);
    NSAssert(result == noErr || result == errSecItemNotFound, @"Error deleting keychain data (%d)", result);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_credentialsAttrArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CredentialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CredentialCell" forIndexPath:indexPath];
    
    CFDictionaryRef thisCredentialsDict = (__bridge CFDictionaryRef)([_credentialsAttrArray objectAtIndex:indexPath.row]);
    
    CFStringRef website = CFDictionaryGetValue(thisCredentialsDict, kSecAttrServer);
    CFStringRef username = CFDictionaryGetValue(thisCredentialsDict, kSecAttrAccount);
    
    cell.websiteLabel.text = (__bridge NSString *)website;
    cell.usernameLabel.text = (__bridge NSString *)username;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


// Override to support editing the table view.
/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"EditSegue"]){
        UINavigationController *tableNavigationController = (UINavigationController*)[segue destinationViewController];
        EditCredientialViewController *editCredientialViewController = (EditCredientialViewController *)tableNavigationController.topViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        CFDictionaryRef thisCredentialsDict = (__bridge CFDictionaryRef)([_credentialsAttrArray objectAtIndex:selectedIndexPath.row]);
        CFStringRef website = CFDictionaryGetValue(thisCredentialsDict, kSecAttrServer);
        CFStringRef username = CFDictionaryGetValue(thisCredentialsDict, kSecAttrAccount);
        editCredientialViewController.addIfTrue=NO;
        editCredientialViewController.websiteString=(__bridge NSString *)website;
        editCredientialViewController.usernameString=(__bridge NSString *)username;
    }
    else if([[segue identifier] isEqualToString:@"AddSegue"]){
        UINavigationController *tableNavigationController = (UINavigationController*)[segue destinationViewController];
        EditCredientialViewController *editCredientialViewController = (EditCredientialViewController *)tableNavigationController.topViewController;
        editCredientialViewController.addIfTrue=YES;
        editCredientialViewController.websiteString=nil;
        editCredientialViewController.usernameString=nil;
    }
}


@end

//
//  AppDelegate.m
//  UW_HW4_jfry
//
//  Created by Jeffery Fry on 10/29/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "AppDelegate.h"
#import "NameBirthdayManager.h"
#import "HW4TableViewController.h"
#import "HW4CollectionViewController.h"

@interface AppDelegate ()
@property NameBirthdayManager *nameBirthdayManager;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _nameBirthdayManager = [NameBirthdayManager new];
    [_nameBirthdayManager loadTestData];
    
    UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
    
    UINavigationController *tableNavigationController = (UINavigationController*)tabBarController.viewControllers[0];
    HW4TableViewController *tableViewController = (HW4TableViewController*)tableNavigationController.topViewController;
    tableViewController.nameBirthdayManager = _nameBirthdayManager;
    
    
    UINavigationController *collectionNavigationController = (UINavigationController*)tabBarController.viewControllers[1];
    HW4CollectionViewController *collectionViewController = (HW4CollectionViewController*)collectionNavigationController.topViewController;
    collectionViewController.nameBirthdayManager = _nameBirthdayManager;
    
    return YES;
}

@end

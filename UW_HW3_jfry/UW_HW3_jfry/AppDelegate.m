//
//  AppDelegate.m
//  UW_HW3_jfry
//
//  Created by Jeffery Fry on 10/21/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSDictionary *squareColorDefault = @{SquareColorSettingsKey:@1};
    [[NSUserDefaults standardUserDefaults] registerDefaults:squareColorDefault];
    
    NSDictionary *squareCornerRadiusDefault = @{SquareCornerRadiusSettingsKey:@10};
    [[NSUserDefaults standardUserDefaults] registerDefaults:squareCornerRadiusDefault];
    
    return YES;
}

@end

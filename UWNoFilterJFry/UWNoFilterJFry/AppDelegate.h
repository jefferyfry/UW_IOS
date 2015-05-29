//
//  AppDelegate.h
//  UWNoFilterJFry
//
//  Created by Jeffery Fry on 1/10/15.
//  Copyright (c) 2015 Jeff_Fry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (copy) void (^sessionCompletionHandler)();
@property (strong, nonatomic) UIWindow *window;


@end


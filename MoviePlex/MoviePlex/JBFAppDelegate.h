//
//  JBFAppDelegate.h
//  MoviePlex
//
//  Created by Jeffery Fry on 8/18/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "JBFWindowController.h"

@interface JBFAppDelegate : NSObject <NSApplicationDelegate>

@property (strong,nonatomic) JBFWindowController *mainWindowController;

@end

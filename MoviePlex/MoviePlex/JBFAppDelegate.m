//
//  JBFAppDelegate.m
//  HW6_Jfry
//
//  Created by Jeffery Fry on 8/18/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFAppDelegate.h"

@implementation JBFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.mainWindowController = [JBFWindowController new];
    [self.mainWindowController showWindow:self];
}
- (IBAction)fireSearchStarTrek:(id)sender {
    [self.mainWindowController submitSearch:@"Star Trek"];
}
- (IBAction)fireSearchTerminator:(id)sender {
    [self.mainWindowController submitSearch:@"Terminator"];
}
- (IBAction)fireSearchSuperman:(id)sender {
    [self.mainWindowController submitSearch:@"Superman"];
}

@end

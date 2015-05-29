//
//  NSURL+Extension.m
//  UWNoFilterJFry
//
//  Created by Jeffery Fry on 2/27/15.
//  Copyright (c) 2015 Jeff_Fry. All rights reserved.
//

#import "NSURL+Extension.h"

@implementation NSURL (Extension)

-(NSDictionary *)queryDictionary
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *param in [[self query] componentsSeparatedByString:@"&"]) {
        NSArray *parts = [param componentsSeparatedByString:@"="];
        if([parts count] < 2) continue;
        [params setObject:[parts objectAtIndex:1] forKey:[parts objectAtIndex:0]];
    }
    return params;
}

@end

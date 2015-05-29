//
//  HW5CheckInAnnotation.m
//  UW_HW5_jfry
//
//  Created by Jeffery Fry on 11/6/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "HW5CheckInAnnotation.h"

@interface HW5CheckInAnnotation ()

@property CLPlacemark *placemark;

@end

@implementation HW5CheckInAnnotation

-(id)initWithPlacemark:(CLPlacemark*)placemark {
    if(!(self=[super init]))
        return nil;
    self.placemark = placemark;
    self.coordinate = placemark.location.coordinate;
    return self;
}

#pragma mark - MKAnnotation

-(NSString*)title {
    return self.placemark.name;
}

-(NSString*)subtitle {
    return [NSString stringWithFormat:@"%@, %@",self.placemark.locality,self.placemark.administrativeArea];
}

@end

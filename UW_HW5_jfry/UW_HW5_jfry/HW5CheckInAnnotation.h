//
//  HW5CheckInAnnotation.h
//  UW_HW5_jfry
//
//  Created by Jeffery Fry on 11/6/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface HW5CheckInAnnotation : NSObject <MKAnnotation>

-(id)initWithPlacemark:(CLPlacemark*)placemark;

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;

@end

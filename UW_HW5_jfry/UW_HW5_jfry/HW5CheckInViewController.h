//
//  TableViewController.h
//  UW_HW5_jfry
//
//  Created by Jeffery Fry on 11/5/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface HW5CheckInViewController : UITableViewController

@property (nonatomic,strong) CLLocation *location;
@property (nonatomic,strong) CLPlacemark *placemark;

@end

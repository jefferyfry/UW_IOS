//
//  ViewController.m
//  UW_HW5_jfry
//
//  Created by Jeffery Fry on 11/5/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "HW5ViewController.h"
#import "HW5CheckInViewController.h"
#import "HW5CheckInAnnotation.h"
#import <MapKit/MapKit.h>

@interface HW5ViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *hw5MapView;
@property CLLocationManager *locationManager;

@end

@implementation HW5ViewController

static NSString * const Identifier = @"Annotation";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.locationManager==nil){
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate=self;
    }
    //add delay
    
    [self doFindMe:self];
}

- (IBAction)doFindMe:(id)sender {
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined)
       [self.locationManager requestWhenInUseAuthorization];
    else if(([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied)||
            ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusRestricted))
        return;
    
    [self.hw5MapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UINavigationController *navController = [segue destinationViewController];
    
    HW5CheckInViewController *checkInController = (HW5CheckInViewController*)navController.topViewController;
    checkInController.location=self.hw5MapView.userLocation.location;
}

- (void)unwindSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    HW5CheckInViewController *checkInController = [segue sourceViewController];
    
    HW5CheckInAnnotation *annotation = [[HW5CheckInAnnotation alloc] initWithPlacemark:checkInController.placemark];
    
    [self.hw5MapView addAnnotation:annotation];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self doFindMe:self];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:Identifier];
    
    if(annotationView==nil)
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:Identifier];
    
    MKPinAnnotationView *pin = (MKPinAnnotationView*)annotationView;
    
    pin.pinColor = MKPinAnnotationColorGreen;
    pin.animatesDrop=YES;
    pin.canShowCallout=YES;
    
    return pin;
}

@end

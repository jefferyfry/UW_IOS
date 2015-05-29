//
//  TableViewController.m
//  UW_HW5_jfry
//
//  Created by Jeffery Fry on 11/5/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "HW5CheckInViewController.h"

@interface HW5CheckInViewController ()
@property NSArray *placemarks;
@property CLGeocoder *geocoder;
@end

@implementation HW5CheckInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.placemarks = [NSMutableArray new];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.title = @"Loading...";
    self.placemark = nil;
    self.placemarks = nil;
    [self startGeocoding];
}

-(void)startGeocoding {
    if(self.geocoder==nil)
        self.geocoder = [CLGeocoder new];
    
    [self.geocoder cancelGeocode];
    [self.geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error!=nil){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Geocoder Error!" message:@"Unable to reverse geocode!" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self doCancel:self];
            }]];
        }
        else {
            self.title = @"Select Location Name";
            self.placemarks = [placemarks copy];
            [self.tableView reloadData];
        }
    }];
        
}

- (IBAction)doCancel:(id)sender {
    [self.geocoder cancelGeocode];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.placemarks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    CLPlacemark *placemark = [self.placemarks objectAtIndex:indexPath.row];
    cell.textLabel.text = placemark.name;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    self.placemark = [self.placemarks objectAtIndex:indexPath.row];
    [self dismissViewControllerAnimated:YES completion:nil];

}


@end

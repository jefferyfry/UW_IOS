//
//  HW4TableViewController.m
//  UW_HW4_jfry
//
//  Created by Jeffery Fry on 10/29/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "HW4TableViewController.h"
#import "NameBirthday.h"
#import "HW4EditViewController.h"

@interface HW4TableViewController ()
@property NSDateFormatter *dateFormat;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegment;
@end

@implementation HW4TableViewController

static NSString * const CellIdentifier = @"TableCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNameBirthday:)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)fireSort:(id)sender {
    if([_sortSegment selectedSegmentIndex]==0)
       [_nameBirthdayManager setSortName:YES];
    else
       [_nameBirthdayManager setSortName:NO];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_nameBirthdayManager count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.text = [_nameBirthdayManager nameAtIndex:indexPath.row] ;
    cell.detailTextLabel.text = [_nameBirthdayManager birthdayStringAtIndex:indexPath.row];
    
    return cell;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_nameBirthdayManager deleteNameBirthday:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"TableCellToEditSegue"]){
        UINavigationController *tableNavigationController = (UINavigationController*)[segue destinationViewController];
        HW4EditViewController *editViewController = (HW4EditViewController *)tableNavigationController.topViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        editViewController.nameBirthdayManager = _nameBirthdayManager;
        editViewController.index=selectedIndexPath.row;
    }
    else if([[segue identifier] isEqualToString:@"TableCellToAddSegue"]){
        UINavigationController *tableNavigationController = (UINavigationController*)[segue destinationViewController];
        HW4EditViewController *editViewController = (HW4EditViewController *)tableNavigationController.topViewController;
        editViewController.nameBirthdayManager = _nameBirthdayManager;
        editViewController.index=-1;
    }

}

@end

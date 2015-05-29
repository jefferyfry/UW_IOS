//
//  HW4CollectionViewController.m
//  UW_HW4_jfry
//
//  Created by Jeffery Fry on 10/29/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "HW4CollectionViewController.h"
#import "NameBirthday.h"
#import "HW4CollectionViewCell.h"

@interface HW4CollectionViewController ()
@property NSDateFormatter *dateFormat;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSegment;
@end

@implementation HW4CollectionViewController

static NSString * const CellIdentifier = @"CollectionCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setItemSize:CGSizeMake(self.collectionView.bounds.size.width/2.0f, 80.0f)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}

- (IBAction)fireSort:(id)sender {
    if([_sortSegment selectedSegmentIndex]==0)
        [_nameBirthdayManager setSortName:YES];
    else
        [_nameBirthdayManager setSortName:NO];
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_nameBirthdayManager count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HW4CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.nameLabel.text = [_nameBirthdayManager nameAtIndex:indexPath.row];
    cell.birthdayLabel.text = [_nameBirthdayManager birthdayStringAtIndex:indexPath.row];
    cell.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    cell.layer.borderWidth = 1.0f;
    
    return cell;
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    [flowLayout setMinimumInteritemSpacing:0.0f];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setItemSize:CGSizeMake(size.width/2.0f, 80.0f)];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

@end

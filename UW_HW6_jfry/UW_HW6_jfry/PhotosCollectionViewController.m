//
//  PhotosCollectionViewController.m
//  UW_HW6_jfry
//
//  Created by Jeffery Fry on 11/12/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import "PhotoCollectionViewCell.h"
#import "PhotoViewController.h"

@interface PhotosCollectionViewController ()

@end

@implementation PhotosCollectionViewController

static NSString * const reuseIdentifier = @"CollectionCell";

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Select a Photo";
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.collectionView reloadData];
}

- (IBAction)fireDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"ViewPhotoSegue"]){
        UINavigationController *tableNavigationController = (UINavigationController*)[segue destinationViewController];
        PhotoViewController *photoViewController = (PhotoViewController *)tableNavigationController.topViewController;
        NSIndexPath *selectedIndexPath = [self.collectionView indexPathsForSelectedItems][0];
        
        PHAsset *photoAsset = [_photos objectAtIndex:selectedIndexPath.row];
        
        photoViewController.photoAsset = photoAsset;
    }
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_photos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    PHAsset *photoAsset = [_photos objectAtIndex:indexPath.row];
    
    cell.photoImageView.image = [UIImage imageNamed:@"no_pic"];
    
    [[PHImageManager defaultManager] requestImageForAsset:photoAsset targetSize:cell.bounds.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.photoImageView.image = result;
        });
    }];
    
    return cell;
}

@end

//
//  AlbumsTableViewController.m
//  UW_HW6_jfry
//
//  Created by Jeffery Fry on 11/12/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "AlbumsTableViewController.h"
#import "AlbumTableViewCell.h"
#import <Photos/Photos.h>
#import "PhotosCollectionViewController.h"

@interface AlbumsTableViewController () <PHPhotoLibraryChangeObserver>
@property PHFetchResult *smartAlbums;
@end

@implementation AlbumsTableViewController

static NSString * const CellIdentifier = @"TableCell";
static NSString * const CellIdentifier2 = @"TableCell2";

-(void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Select an Album";
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(status != PHAuthorizationStatusAuthorized)
            return;
    }];
    [self reloadAlbums];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

-(void)reloadAlbums {
    _smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    [self.tableView reloadData];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"ViewAlbumSegue"]){
        UINavigationController *tableNavigationController = (UINavigationController*)[segue destinationViewController];
        PhotosCollectionViewController *photosCollectionViewController = (PhotosCollectionViewController *)tableNavigationController.topViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        PHAssetCollection *album = [_smartAlbums objectAtIndex:selectedIndexPath.row];
        photosCollectionViewController.photos = [PHAsset fetchAssetsInAssetCollection:album options:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_smartAlbums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHAssetCollection *album = [_smartAlbums objectAtIndex:indexPath.row];
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:album options:nil];
    AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.albumNameLabel.text = album.localizedTitle;
    cell.countLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[assets count]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:@"no_pic"];
    
    if([assets count]>0){
        NSUInteger randomIndex = arc4random() % [assets count];
        PHAsset *randomAsset = [assets objectAtIndex:randomIndex];
        [[PHImageManager defaultManager] requestImageForAsset:randomAsset targetSize:CGSizeMake(50,50) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = result;
            });
        }];
        
    }
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - Photo Library Change Observer
-(void) photoLibraryDidChange:(PHChange *)changeInstance {
    [self reloadAlbums];
}



@end

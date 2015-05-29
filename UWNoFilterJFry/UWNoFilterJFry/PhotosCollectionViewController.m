//
//  PhotosCollectionViewController.m
//  UWNoFilterJFry
//
//  Created by Jeffery Fry on 1/22/15.
//  Copyright (c) 2015 Jeff_Fry. All rights reserved.
//

#import "PhotosCollectionViewController.h"
#import "PhotoCollectionViewCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+NFExtensions.h"
#import "CoreDataStack.h"
#import "Photo.h"
#import "NoFilterClient.h"
//#import "PhotoViewController.h"
@import CoreData;

@interface PhotosCollectionViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSFetchedResultsControllerDelegate,NoFilterClientDelegate>
@property (strong,nonatomic) NSOperationQueue *persistPhotoQueue;
@property (strong,nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong,nonatomic) NSMutableArray *queuedCollectionViewChanges;
@property (nonatomic, assign) UIBackgroundTaskIdentifier addPhotoBgTask;
@property (nonatomic, assign) UIBackgroundTaskIdentifier doAllBgTask;
@property (strong,nonatomic) NoFilterClient *noFilterClient;
@property (strong, nonatomic) NSUserDefaults *sharedDefaults;
@end

@implementation PhotosCollectionViewController

static NSString * const reuseIdentifier = @"PhotoCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.noFilterClient = [NoFilterClient sharedClient];
    self.noFilterClient.delegate=self;
    self.queuedCollectionViewChanges = [NSMutableArray array];
    self.sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.jefferyfry.nofilter"];
    [self.noFilterClient getServerList];
    
    NSManagedObjectContext* managedObjectContext = [[CoreDataStack sharedStack] rootManagedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Photo"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"UWNoFilterJfryDataCache"];
    self.fetchedResultsController.delegate=self;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error performing initial fetch! Not sure what to do... %@", error);
    }
    
    self.persistPhotoQueue = [[NSOperationQueue alloc] init];
    self.persistPhotoQueue.name = @"PersistPhotoQueue";
    self.persistPhotoQueue.maxConcurrentOperationCount = 2;
        
    // Do any additional setup after loading the view.
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Photo" style:UIBarButtonItemStyleDone target:self action:@selector(promptForPhoto:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    //double table to reload
    UITapGestureRecognizer* uiTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(regenerateThumbsForTest)];
    uiTapGestureRecognizer.numberOfTapsRequired =2;
    [self.collectionView addGestureRecognizer:uiTapGestureRecognizer];
}

-(void)promptForPhoto:(id)sender {
    //check if camera available.  if so prompt to choose
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Photo" message:@"Choose Photo Source." preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         [self addPhotoFromCamera];
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
        [alert addAction:camera];
        
        UIAlertAction *photos = [UIAlertAction actionWithTitle:@"Photos" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             [self addPhotoFromPhotos];
                                                             [alert dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        [alert addAction:photos];

        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else { //just select from albums
        [self addPhotoFromPhotos];
    }
}

-(void)regenerateThumbsForTest {
    _doAllBgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"DoAllTask" expirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:_doAllBgTask];
        _doAllBgTask = UIBackgroundTaskInvalid;
        NSLog(@"%@: Ended do all background task due to expiration.", NSStringFromSelector(_cmd));
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSLog(@"%@: Started do all background task.", NSStringFromSelector(_cmd));
        
        NSManagedObjectContext* childManagedObjectContext = [[CoreDataStack sharedStack] newChildManagedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Photo"];
        NSArray *photos = [childManagedObjectContext executeFetchRequest:fetchRequest error:nil];
        //set all thumbs to nil
        for(Photo *photo in photos){
            photo.thumb=nil;
        }
        NSError *error = nil;
        if (![childManagedObjectContext save:&error]) {
            NSLog(@"Error saving photos after thumb=nil in child MOC: %@", error);
        }
        
        //now regenerate all thumbs
        for(Photo *photo in photos){
            [self generateAndSaveThumb:photo withManagedContext:childManagedObjectContext];
        }
        
        [[UIApplication sharedApplication] endBackgroundTask:_doAllBgTask];
        _doAllBgTask = UIBackgroundTaskInvalid;
        NSLog(@"%@: Completed do all background task.", NSStringFromSelector(_cmd));
    });
}

-(void)generateAndSaveThumb:(Photo *)photo withManagedContext:(NSManagedObjectContext *)managedObjectContext {
    UIImage *photoImage = [UIImage imageWithData:photo.image];
    UIImage *scaledImage = [photoImage scaledImageConstrainedToSize:CGSizeMake(100.0, 100.0)];
    photo.thumb=UIImagePNGRepresentation(scaledImage);
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error saving thumbs in MOC: %@", error);
    }
}

-(void)addPhotoFromCamera {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(__bridge NSString *)kUTTypeImage];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)addPhotoFromPhotos {
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(__bridge NSString *)kUTTypeImage];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)persistNewImage:(UIImage *)image withId:(NSNumber*)itemId withUpload:(BOOL)upload {
    NSManagedObjectContext* childManagedObjectContext = [[CoreDataStack sharedStack] newChildManagedObjectContext];
    
    Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Photo class]) inManagedObjectContext:childManagedObjectContext];
    newPhoto.thumb = nil;
    newPhoto.dateAdded = [NSDate date];
    if(!upload)
        newPhoto.serverId=itemId;
    
    NSError *error = nil;
    if (![childManagedObjectContext save:&error]) {
        NSLog(@"Error saving inserting new photo in child MOC: %@", error);
    }
    
    [self.persistPhotoQueue addOperationWithBlock:^{
        
        //prepare to run this in the background
        _addPhotoBgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"AddPhotoTask" expirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:_addPhotoBgTask];
            _addPhotoBgTask = UIBackgroundTaskInvalid;
            NSLog(@"%@: Ended add photo background task due to expiration.", NSStringFromSelector(_cmd));
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSLog(@"%@: Started add photo background task.", NSStringFromSelector(_cmd));
            newPhoto.image = UIImagePNGRepresentation(image);
            [self.sharedDefaults setObject:UIImagePNGRepresentation(image) forKey:@"lastImage"];
            [self.sharedDefaults synchronize];
            [self generateAndSaveThumb:newPhoto withManagedContext:childManagedObjectContext];
            if(upload)
                [self.noFilterClient uploadPhoto:newPhoto];
            [[UIApplication sharedApplication] endBackgroundTask:_addPhotoBgTask];
            _addPhotoBgTask = UIBackgroundTaskInvalid;
            NSLog(@"%@: Completed add photo background task.", NSStringFromSelector(_cmd));
        });
    }];
}

#pragma mark - NoFilterClientDelegate

-(void)uploadPhotoResult:(BOOL)success withId:(NSNumber*)serverId {
    NSLog(@"Upload new photo:%@ %@",(success ? @"YES" : @"NO"),serverId);
    if(success){
        NSManagedObjectContext* childManagedObjectContext = [[CoreDataStack sharedStack] newChildManagedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Photo"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:NO]];
        Photo *uploadedPhoto = [[childManagedObjectContext executeFetchRequest:fetchRequest error:nil] firstObject];
        uploadedPhoto.serverId=serverId;
        
        NSError *error = nil;
        if (![childManagedObjectContext save:&error]) {
            NSLog(@"Error saving inserting new photo in child MOC: %@", error);
        }
    }
}

-(void)serverListResult:(NSArray*)itemIds {
    NSManagedObjectContext* childManagedObjectContext = [[CoreDataStack sharedStack] newChildManagedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"Photo"];
    
    for(NSNumber *itemId in itemIds){
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"serverId==%@",itemId];
        fetchRequest.predicate=predicate;
        NSError *error = nil;
        NSArray *array = [childManagedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (array == nil)
            NSLog(@"Unable to fetch photo with id %@ due to error %@",itemId,error);
        else if([array count]==0) {
            NSLog(@"Requesting photo with id %@",itemId);
            [self.noFilterClient downloadPhoto:itemId];
        }
    }
}

-(void)downloadPhotoResult:(NSURL*)location withId:(NSNumber*)serverId {
    NSLog(@"Downloaded item id %@",serverId);
    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:location]];
    [self persistNewImage:image withId:serverId withUpload:NO];
}


#pragma mark - Image Picker Delegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if(image==nil)
        image = info[UIImagePickerControllerOriginalImage];
    
    [self persistNewImage:image withId:@-1 withUpload:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark <NSFetchedResultsControllerDelegate>
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch(type)
    {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            //NSLog(@"didChangeObject: NSFetchedResultsChangeInsert type.");
            break;
//        case NSFetchedResultsChangeDelete:
//            change[@(type)] = indexPath;
//            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            //NSLog(@"didChangeObject: NSFetchedResultsChangeUpdate type.");
            break;
//        case NSFetchedResultsChangeMove:
//            change[@(type)] = @[indexPath, newIndexPath];
//            break;
        default:
            //NSLog(@"didChangeObject: Unimplemented type.");
            break;
    }
    [self.queuedCollectionViewChanges addObject:change];
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        
        for (NSDictionary *change in self.queuedCollectionViewChanges)
        {
            [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch (type)
                {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
//                    case NSFetchedResultsChangeDelete:
//                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
//                        break;
                    case NSFetchedResultsChangeUpdate:
                        [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                        break;
//                    case NSFetchedResultsChangeMove:
//                        [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
//                        break;
                    default:
                        //NSLog(@"controllerDidChangeContent: Unimplemented type.");
                        break;
                }
            }];
        }
    } completion:nil];
    
    [self.queuedCollectionViewChanges removeAllObjects];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSArray *sections = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionObject = sections[indexPath.section];
    Photo *photo = [sectionObject objects][indexPath.row];
    
    if(!photo.thumb){  //thumbnail does not exist. show progress indicator
        // Configure the cell
        cell.photoImageView.image = nil;
        cell.photoImageView.hidden = YES;
        cell.progressIndicatorView.hidden=NO;
        [cell.progressIndicatorView startAnimating];
    }
    else { //thumbnail exists.  use it
        UIImage *thumbImage = [UIImage imageWithData:photo.thumb];
        cell.photoImageView.image = thumbImage;
        cell.photoImageView.hidden = NO;
        cell.progressIndicatorView.hidden=YES;
    }
    
    return cell;
}

@end

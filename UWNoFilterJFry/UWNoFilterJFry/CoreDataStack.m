//
//  CoreDataStack.m
//  UWNoFilterJFry
//
//  Created by Jeffery Fry on 1/29/15.
//  Copyright (c) 2015 Jeff_Fry. All rights reserved.
//

#import "CoreDataStack.h"
@import CoreData;

@interface CoreDataStack ()
@property (strong, nonatomic, readwrite) NSManagedObjectContext *rootManagedObjectContext;
@property (strong, nonatomic,readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation CoreDataStack

+(CoreDataStack*)sharedStack
{
    static CoreDataStack *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

-(NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if(_persistentStoreCoordinator){
        return _persistentStoreCoordinator;
    }
    NSURL *momURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    self.persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    
    NSError *error = nil;
    if (![self.persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:[self applicationDocumentsDirectory]
                                                             options:nil
                                                               error:&error]) {
        NSLog(@"Setting up persistent store failed: %@", error);
        
        return nil;
    }
    return self.persistentStoreCoordinator;
}

- (NSManagedObjectContext *)rootManagedObjectContext
{
    if (_rootManagedObjectContext) {
        return _rootManagedObjectContext;
    }
    
    self.rootManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    self.rootManagedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
    
    return self.rootManagedObjectContext;
}

-(NSManagedObjectContext *)newChildManagedObjectContext {
    
    NSManagedObjectContext *childManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    childManagedObjectContext.parentContext = [self rootManagedObjectContext];
    
    [[NSNotificationCenter defaultCenter]addObserverForName:NSManagedObjectContextDidSaveNotification object:childManagedObjectContext queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note){
        [self.rootManagedObjectContext mergeChangesFromContextDidSaveNotification:note];
        NSError *error = nil;
        if (![self.rootManagedObjectContext save:&error]){
            NSLog(@"Unable to save from notification: %@", error);
        }
    }];
    
    return childManagedObjectContext;
}

- (NSURL *)applicationDocumentsDirectory
{
    NSArray *URLs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSAssert([URLs count] > 0, @"Expected to find a document URL");
    NSURL *documentDirectory = URLs[0];
    return [[documentDirectory URLByAppendingPathComponent:@"photos"] URLByAppendingPathExtension:@"sqlite"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
    
}



@end

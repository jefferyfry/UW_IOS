//
//  CoreDataStack.h
//  UWNoFilterJFry
//
//  Created by Jeffery Fry on 1/29/15.
//  Copyright (c) 2015 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataStack : NSObject

+(CoreDataStack*)sharedStack;

-(NSManagedObjectContext *)rootManagedObjectContext;

-(NSManagedObjectContext *)newChildManagedObjectContext;

@end

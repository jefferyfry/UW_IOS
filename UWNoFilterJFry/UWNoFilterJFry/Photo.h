//
//  Photo.h
//  UWNoFilterJFry
//
//  Created by Jeffery Fry on 2/27/15.
//  Copyright (c) 2015 Jeff_Fry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSData * thumb;
@property (nonatomic, retain) NSNumber * serverId;

@end

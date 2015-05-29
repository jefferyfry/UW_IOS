//
//  NameBirthdayManager.h
//  UW_HW4_jfry
//
//  Created by Jeffery Fry on 10/31/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NameBirthdayManager : NSObject

-(NSUInteger)count;
-(void)addNameBirthday:(NSString*)name withBirthday:(NSDate*)birthday;
-(void)deleteNameBirthday:(NSUInteger)index;
-(void)updateNameBirthday:(NSString*)name withBirthday:(NSDate*)birthday atIndex:(NSUInteger)index;
-(void)setSortName:(BOOL)sortName;
-(void)loadTestData;
-(NSString*)nameAtIndex:(NSUInteger)index;
-(NSDate*)birthdayAtIndex:(NSUInteger)index;
-(NSString*)birthdayStringAtIndex:(NSUInteger)index;

@end


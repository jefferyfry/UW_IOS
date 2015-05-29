//
//  NameBirthdayManager.m
//  UW_HW4_jfry
//
//  Created by Jeffery Fry on 10/31/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "NameBirthdayManager.h"
#import "NameBirthday.h"

@interface NameBirthdayManager()
@property NSMutableArray *birthdays;
@property NSDateFormatter *dateFormat;
@property (nonatomic)  BOOL sortName;
@end

@implementation NameBirthdayManager

-(id)init{
    if (self = [super init])  {
        _sortName=YES;
        _birthdays = [NSMutableArray new];
        _dateFormat = [NSDateFormatter new];
        [_dateFormat setDateFormat:@"M/dd/yyyy"];
    }
    return self;
    
}

-(void)sort {
    if(_sortName){
        NSSortDescriptor *nameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                             ascending:YES
                                                                              selector:@selector(localizedStandardCompare:)];
        [_birthdays sortUsingDescriptors:[NSArray arrayWithObject:nameSortDescriptor]];
    }
    else {
        NSSortDescriptor *birthdaySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"birthday"
                                                                             ascending:YES];
        [_birthdays sortUsingDescriptors:[NSArray arrayWithObject:birthdaySortDescriptor]];
    }
}

-(NSUInteger)count {
    return [_birthdays count];
}

-(void)addNameBirthday:(NSString*)name withBirthday:(NSDate*)birthday {
    NameBirthday *newPerson = [NameBirthday new];
    newPerson.name = name;
    newPerson.birthday = birthday;
    [_birthdays addObject:newPerson];
    [self sort];
}

-(void)updateNameBirthday:(NSString*)name withBirthday:(NSDate*)birthday atIndex:(NSUInteger)index {
    NameBirthday *nameBirthday = [_birthdays objectAtIndex:index];
    nameBirthday.name = name;
    nameBirthday.birthday = birthday;
    [self sort];

}

-(void)deleteNameBirthday:(NSUInteger)index {
    [_birthdays removeObjectAtIndex:index];
}

-(void)setSortName:(BOOL)sortName {
    _sortName=sortName;
    [self sort];
}

-(void)loadTestData {
    NameBirthday *person1 = [NameBirthday new];
    person1.name = @"Joe";
    person1.birthday = [_dateFormat dateFromString:@"12/01/1977"];
    [_birthdays addObject:person1];
    
    NameBirthday *person2 = [NameBirthday new];
    person2.name = @"Mary";
    person2.birthday = [_dateFormat dateFromString:@"6/01/1975"];
    [_birthdays addObject:person2];
    
    NameBirthday *person3 = [NameBirthday new];
    person3.name = @"Tom";
    person3.birthday = [_dateFormat dateFromString:@"9/21/1981"];
    [_birthdays addObject:person3];
}

-(NSString*)nameAtIndex:(NSUInteger)index {
    NameBirthday *nameBirthday = [_birthdays objectAtIndex:index];
    return nameBirthday.name;
}

-(NSDate*)birthdayAtIndex:(NSUInteger)index {
    NameBirthday *nameBirthday = [_birthdays objectAtIndex:index];
    return nameBirthday.birthday;
}

-(NSString*)birthdayStringAtIndex:(NSUInteger)index {
    NameBirthday *nameBirthday = [_birthdays objectAtIndex:index];
    return [_dateFormat stringFromDate:nameBirthday.birthday];
}

@end
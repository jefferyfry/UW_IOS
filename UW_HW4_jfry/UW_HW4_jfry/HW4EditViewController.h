//
//  HW4EditViewController.h
//  UW_HW4_jfry
//
//  Created by Jeffery Fry on 10/30/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NameBirthdayManager.h"

@interface HW4EditViewController : UIViewController <UITextFieldDelegate>
@property NSInteger index;
@property NameBirthdayManager *nameBirthdayManager;
@end

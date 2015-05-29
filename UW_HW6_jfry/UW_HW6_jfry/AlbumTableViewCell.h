//
//  AlbumTableViewCell.h
//  UW_HW6_jfry
//
//  Created by Jeffery Fry on 11/12/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

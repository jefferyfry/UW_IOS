//
//  PhotoViewController.m
//  UW_HW6_jfry
//
//  Created by Jeffery Fry on 11/12/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@end

@implementation PhotoViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    _photoImageView.image = [UIImage imageNamed:@"no_pic"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[PHImageManager defaultManager] requestImageForAsset:_photoAsset targetSize:_photoImageView.bounds.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _photoImageView.image = result;
        });
    }];
}
- (IBAction)fireDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

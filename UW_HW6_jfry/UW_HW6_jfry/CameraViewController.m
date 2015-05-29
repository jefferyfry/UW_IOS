//
//  CameraViewController.m
//  UW_HW6_jfry
//
//  Created by Jeffery Fry on 11/12/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface CameraViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *lastPhotoImageView;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)fireTakePhoto:(id)sender {
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        return;
    
    UIImagePickerController *imagePicker = [UIImagePickerController new];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.mediaTypes = @[(__bridge NSString *)kUTTypeImage];
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark - Delegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if(image==nil)
        image = info[UIImagePickerControllerOriginalImage];
    
    if(image!=nil){
        self.lastPhotoImageView.image = image;
        UIImageWriteToSavedPhotosAlbum(image, nil, NULL, NULL);
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}



@end

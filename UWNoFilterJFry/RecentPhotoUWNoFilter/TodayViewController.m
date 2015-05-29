//
//  TodayViewController.m
//  RecentPhotoUWNoFilter
//
//  Created by Jeffery Fry on 3/5/15.
//  Copyright (c) 2015 Jeff_Fry. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>
@property (weak, nonatomic) IBOutlet UIImageView *lastImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageProgress;
@property (strong, nonatomic) NSUserDefaults *sharedDefaults;
@end

@implementation TodayViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    _sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.jefferyfry.nofilter"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPic)];
    tap.numberOfTapsRequired = 1;
    [_lastImageView setUserInteractionEnabled:YES];
    [_lastImageView addGestureRecognizer:tap];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsDidChange:)
                                                 name:NSUserDefaultsDidChangeNotification
                                               object:nil];
    [self updateExtension];
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self updateExtension];
}

-(void)updateExtension {
    NSData* imageData = [self.sharedDefaults objectForKey:@"lastImage"];
    UIImage* image = [UIImage imageWithData:imageData];
    _lastImageView.image = image;
}


-(void)tapPic {
    NSURL *myURL = [NSURL URLWithString:@"nofilter://"];
    [self.extensionContext openURL:myURL completionHandler:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end

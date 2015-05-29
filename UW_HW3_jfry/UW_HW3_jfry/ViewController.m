//
//  ViewController.m
//  UW_HW3_jfry
//
//  Created by Jeffery Fry on 10/21/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "ViewController.h"
#import "DrawView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet DrawView *drawView;
@property (weak, nonatomic) IBOutlet UISlider *cornerRadiusSlider;
@property (weak, nonatomic) IBOutlet UISegmentedControl *squareColorControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cornerRadiusSlider.minimumValue=0;
    self.cornerRadiusSlider.maximumValue=25;
    
    [[NSNotificationCenter defaultCenter]
     addObserverForName:NSUserDefaultsDidChangeNotification
     object:[NSUserDefaults standardUserDefaults]
     queue:[NSOperationQueue mainQueue]
     usingBlock:^(NSNotification *block){
         [[NSUserDefaults standardUserDefaults] synchronize];
         [self applySettings];
     }];
    
    UITapGestureRecognizer* uiTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addSquare:)];
    [self.drawView addGestureRecognizer:uiTapGestureRecognizer];
    
    UIPanGestureRecognizer* uiPanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveSquare:)];
    [self.drawView addGestureRecognizer:uiPanGestureRecognizer];
    [self applySettings];
}

-(void)addSquare:(UITapGestureRecognizer*)uiTapGestureRecognizer {
    if(uiTapGestureRecognizer.state==UIGestureRecognizerStateRecognized){
        CGPoint location = [uiTapGestureRecognizer locationInView:uiTapGestureRecognizer.view];
        [self.drawView addSquare:location];
    }
}

-(void)moveSquare:(UIPanGestureRecognizer*)uiPanGestureRecognizer {
    if(uiPanGestureRecognizer.state==UIGestureRecognizerStateBegan) {
        CGPoint location = [uiPanGestureRecognizer locationInView:uiPanGestureRecognizer.view];
        [self.drawView startMoveSquare:location];
        NSLog(@"Began %@", NSStringFromCGPoint(location));
    }
    else if(uiPanGestureRecognizer.state==UIGestureRecognizerStateChanged) {
        CGPoint translation = [uiPanGestureRecognizer translationInView:uiPanGestureRecognizer.view];
        [self.drawView moveSquare:translation];
        
        [uiPanGestureRecognizer setTranslation:CGPointZero inView:uiPanGestureRecognizer.view];
    }
}

- (IBAction)fireCornerRadiusSlider:(id)sender {
    float value = self.cornerRadiusSlider.value;
    [self.drawView setSquareCornerRadii:value];
    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:SquareCornerRadiusSettingsKey];
    NSLog(@"Corner radius %.2f", value);
}

- (IBAction)fireSquareColorControl:(id)sender {
    NSInteger selectedSegment = [self.squareColorControl selectedSegmentIndex];
    [[NSUserDefaults standardUserDefaults] setInteger:selectedSegment+1 forKey:SquareColorSettingsKey];
    switch(selectedSegment){
        case 0:
            [self.drawView setSquareColor:[UIColor redColor]];
            break;
        case 1:
            [self.drawView setSquareColor:[UIColor blueColor]];
            break;
        case 2:
            [self.drawView setSquareColor:[UIColor greenColor]];
            break;
    }
}

-(void)applySettings {
    NSInteger cornerRadius = [[NSUserDefaults standardUserDefaults] integerForKey:SquareCornerRadiusSettingsKey];
    [self.drawView setSquareCornerRadii:cornerRadius];
    [self.cornerRadiusSlider setValue:cornerRadius];
    
    NSInteger color = [[NSUserDefaults standardUserDefaults] integerForKey:SquareColorSettingsKey];
    [self.squareColorControl setSelectedSegmentIndex:color-1];
    switch(color){
        case 1:
            [self.drawView setSquareColor:[UIColor redColor]];
            break;
        case 2:
            [self.drawView setSquareColor:[UIColor blueColor]];
            break;
        case 3:
            [self.drawView setSquareColor:[UIColor greenColor]];
            break;
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self.drawView rotate:size.width forHeight:size.height];
}

@end

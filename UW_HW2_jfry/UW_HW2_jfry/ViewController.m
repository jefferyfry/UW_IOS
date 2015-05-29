//
//  ViewController.m
//  UW_HW2_jfry
//
//  Created by Jeffery Fry on 10/5/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIView *superView;
@property (weak, nonatomic) IBOutlet UIView *redView;
@property (weak, nonatomic) IBOutlet UIView *blueView;
@property (weak, nonatomic) IBOutlet UISlider *viewRatioSlider;

//portrait constraints already set via IB
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *redViewHeightConstraintPortrait;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *redViewTrailingConstraintPortrait;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *redViewTopConstraintPortrait;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *blueViewLeadingConstraintPortrait;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *blueViewTopConstraintPortrait;

//new landscape constraints
@property (strong,nonatomic) NSLayoutConstraint *redViewWidthConstraintLandscape;
@property (strong,nonatomic) NSLayoutConstraint *redViewBottomConstraintLandscape;
@property (strong,nonatomic) NSLayoutConstraint *redViewTopConstraintLandscape;

@property (strong, nonatomic) NSLayoutConstraint *blueViewLeadingConstraintLandscape;
@property (strong, nonatomic) NSLayoutConstraint *blueViewTopConstraintLandscape;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set up new landscape constraints
    self.redViewWidthConstraintLandscape = [NSLayoutConstraint constraintWithItem:self.redView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1 constant:125];
    self.redViewBottomConstraintLandscape = [NSLayoutConstraint constraintWithItem:self.redView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.viewRatioSlider attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    self.redViewTopConstraintLandscape = [NSLayoutConstraint constraintWithItem:self.redView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
    
    self.blueViewLeadingConstraintLandscape = [NSLayoutConstraint constraintWithItem:self.blueView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.redView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    self.blueViewTopConstraintLandscape = [NSLayoutConstraint constraintWithItem:self.blueView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superView attribute:NSLayoutAttributeTop multiplier:1 constant:0];
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    BOOL isLandscape = size.width > size.height;
    
    if(isLandscape)
        [self setLandscapeLayoutConstraints];
    else
        [self setPortraitLayoutConstraints];
    
    [coordinator animateAlongsideTransition:^(id c) {
        [self.superView layoutIfNeeded];
        [self.redView layoutIfNeeded];
        [self.blueView layoutIfNeeded];
        [self.viewRatioSlider layoutIfNeeded];
    } completion:nil];
}

- (void)setPortraitLayoutConstraints {
    self.redViewHeightConstraintPortrait.active=YES;
    self.redViewTrailingConstraintPortrait.active=YES;
    self.redViewTopConstraintPortrait.active=YES;
    self.blueViewLeadingConstraintPortrait.active=YES;
    self.blueViewTopConstraintPortrait.active=YES;
    
    self.redViewWidthConstraintLandscape.active=NO;
    self.redViewBottomConstraintLandscape.active=NO;
    self.redViewTopConstraintLandscape.active=NO;
    self.blueViewLeadingConstraintLandscape.active=NO;
    self.blueViewTopConstraintLandscape.active=NO;
}

- (void)setLandscapeLayoutConstraints {
    self.redViewHeightConstraintPortrait.active=NO;
    self.redViewTrailingConstraintPortrait.active=NO;
    self.redViewTopConstraintPortrait.active=NO;
    self.blueViewLeadingConstraintPortrait.active=NO;
    self.blueViewTopConstraintPortrait.active=NO;
    
    self.redViewWidthConstraintLandscape.active=YES;
    self.redViewBottomConstraintLandscape.active=YES;
    self.redViewTopConstraintLandscape.active=YES;
    self.blueViewLeadingConstraintLandscape.active=YES;
    self.blueViewTopConstraintLandscape.active=YES;
}

- (IBAction)fireSliderSet:(id)sender {
    float value = self.viewRatioSlider.value;
    self.redViewWidthConstraintLandscape.constant = value * self.superView.frame.size.width;
    self.redViewHeightConstraintPortrait.constant = value * self.superView.frame.size.height;
}

@end

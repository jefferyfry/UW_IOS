//
//  JBFWindowController.m
//  HW6_Jfry
//
//  Created by Jeffery Fry on 8/18/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "JBFWindowController.h"

@interface JBFWindowController ()

@property JBFRottenTomatoesMovieSearch *rottenTomatoesMovieSearch;
@property JBFJSONViewController *jsonViewController;
@property JBFMovieSearchListingViewController *movieSearchListingViewController;
@property (weak) IBOutlet NSSearchField *movieSearchField;
@property (weak) IBOutlet NSSegmentedControl *numResultsSegmentControl;


@end

@implementation JBFWindowController

- (id)init
{
    self = [super initWithWindowNibName:NSStringFromClass(self.class)];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.rottenTomatoesMovieSearch = [JBFRottenTomatoesMovieSearch new];
    self.rottenTomatoesMovieSearch.delegate = self;
    self.jsonViewController = [JBFJSONViewController new];
    self.movieSearchListingViewController = [JBFMovieSearchListingViewController new];
    [self displayViewController:self.movieSearchListingViewController];
}

-(void)submitSearch:(NSString*)text
{
    self.movieSearchField.stringValue=text;
    [self fireMovieSearch:self];
}

- (IBAction)fireMovieSearch:(id)sender {
    NSInteger selectedSegment = [self.numResultsSegmentControl selectedSegment];
    NSUInteger numResults = 1;
    if(selectedSegment==1)
        numResults = 10;
    else if(selectedSegment==2)
        numResults = 50;
    
    [self.rottenTomatoesMovieSearch searchForMovie:self.movieSearchField.stringValue forNumberOfResults:numResults];
}

- (IBAction)fireTableView:(id)sender {
    [self displayViewController:self.movieSearchListingViewController];
}

- (IBAction)fireJSONView:(id)sender {
    [self displayViewController:self.jsonViewController];
}

-(void)startedSearchRequest{
    
}

-(void)updateSearchRequestProgress:(double)progress{
    
}

-(void)finishedSearchRequest:(JBFMovieSearchResult*)results{
    self.jsonViewController.jsonTextView.textContainer.textView.string = results.jsonString;
    self.movieSearchListingViewController.movies = results.moviesArray;
    [self.movieSearchListingViewController reloadData];
}

-(void)displayViewController:(NSViewController*)viewController
{
    [self removeAllSubViews];
    viewController.view.frame = [self.window.contentView bounds];
    viewController.view.autoresizingMask = NSViewHeightSizable |NSViewWidthSizable;
    [self.window.contentView addSubview:viewController.view];
}

-(void)removeAllSubViews
{
    [self.jsonViewController.view removeFromSuperview];
    [self.movieSearchListingViewController.view removeFromSuperview];
}

@end

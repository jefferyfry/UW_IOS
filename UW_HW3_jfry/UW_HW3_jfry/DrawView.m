//
//  DrawView.m
//  UW_HW3_jfry
//
//  Created by Jeffery Fry on 10/21/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import "DrawView.h"

static const CGFloat SquareDimension = 75;

@interface DrawView ()

@property CGFloat radii;

@property UIColor* color;

@property NSMutableArray *shapes;

@property NSInteger currentShapeIndex;

@end

@implementation DrawView

-(void)initialize
{
    self.radii = 10.0;
    self.color = [UIColor redColor];
    self.shapes = [NSMutableArray new];
    self.currentShapeIndex=-1;
    
}

- (id)initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)rect{
    if(self = [super initWithFrame:rect]){
        [self initialize];
    }
    return self;
}

-(void)addSquare:(CGPoint)point; {
    NSValue *pointObj = [NSValue valueWithCGPoint:point];
    [self.shapes addObject:pointObj];
    NSLog(@"Add %@", NSStringFromCGPoint(point));
    [self setNeedsDisplay];
}

-(void)startMoveSquare:(CGPoint)point; {
    NSInteger index=[self.shapes count]-1;
    for(NSValue *value in [self.shapes reverseObjectEnumerator]){  //iterate in reverse to check from top down
        CGPoint center = [value CGPointValue];
        CGRect rect = CGRectMake(center.x-SquareDimension/2, center.y-SquareDimension/2, SquareDimension, SquareDimension);
        if(CGRectContainsPoint(rect, point)){
            self.currentShapeIndex=index;
            NSLog(@"Shape index=%lu",(unsigned long)index);
            return;
        }
        index--;
    }
    self.currentShapeIndex=-1;
}

-(void)moveSquare:(CGPoint)translation; {
    if(self.currentShapeIndex>-1 && self.currentShapeIndex < [self.shapes count]){
        CGPoint center = [self.shapes[self.currentShapeIndex] CGPointValue];
        CGPoint newCenter = CGPointMake(center.x+translation.x, center.y+translation.y);
        NSValue *newValue = [NSValue valueWithCGPoint:newCenter];
        [self.shapes replaceObjectAtIndex:self.currentShapeIndex withObject:newValue];
        NSLog(@"Move shape %lu %@", (unsigned long)self.currentShapeIndex, NSStringFromCGPoint(translation));
        [self setNeedsDisplay];
    }
}

-(void)setSquareColor:(UIColor*)color; {
    self.color = color;
    [self setNeedsDisplay];
}

-(void)setSquareCornerRadii:(CGFloat)radii; {
    self.radii=radii;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    for(NSValue *value in self.shapes){
        CGPoint center = [value CGPointValue];
        [self.color set];
        UIBezierPath *square = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(center.x-SquareDimension/2, center.y-SquareDimension/2, SquareDimension, SquareDimension) cornerRadius:self.radii];
        
        [square fill];
        
        [[UIColor blackColor] set];
        UIBezierPath *squareBorder = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(center.x-SquareDimension/2, center.y-SquareDimension/2, SquareDimension, SquareDimension) cornerRadius:self.radii];
        
        [squareBorder stroke];
    }
    
}

-(void)rotate:(CGFloat)width forHeight:(CGFloat)height; {
    NSMutableArray *newArray = [NSMutableArray new];
    for(NSValue *value in self.shapes){
        CGPoint center = [value CGPointValue];
        float ratioX = width/height;
        float ratioY = height/width;
        CGPoint newCenter = CGPointMake(center.x*ratioX, center.y*ratioY);
        NSValue *newValue = [NSValue valueWithCGPoint:newCenter];
        [newArray addObject:newValue];
    }
    self.shapes = newArray;
    [self setNeedsDisplay];
}

@end

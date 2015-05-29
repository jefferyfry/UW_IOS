//
//  DrawView.h
//  UW_HW3_jfry
//
//  Created by Jeffery Fry on 10/21/14.
//  Copyright (c) 2014 Jeff_Fry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawView : UIView

-(void)addSquare:(CGPoint)point;

-(void)startMoveSquare:(CGPoint)point;

-(void)moveSquare:(CGPoint)translation;

-(void)setSquareColor:(UIColor*)color;

-(void)setSquareCornerRadii:(CGFloat)radii;

-(void)rotate:(CGFloat)width forHeight:(CGFloat)height;

@end

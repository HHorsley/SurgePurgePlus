//
//  EscapeSurgeButton.m
//  SurgePurgePlus
//
//  Created by Hunter Horsley on 10/18/14.
//  Copyright (c) 2014 YAH. All rights reserved.
//

#import "EscapeSurgeButton.h"

@implementation EscapeSurgeButton


- (void)drawRect:(CGRect)rect {
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed: 0.122 green: 0.729 blue: 0.839 alpha: 1];
    UIColor* shadowColor2 = [UIColor colorWithRed: 0.019 green: 0.587 blue: 0.69 alpha: 1];
    
    //// Shadow Declarations
    UIColor* shadow3 = shadowColor2;
    CGSize shadow3Offset = CGSizeMake(0.1, 3.1);
    CGFloat shadow3BlurRadius = 0;
    
    //// Rounded Rectangle Drawing
    UIBezierPath* roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, 213, 41) cornerRadius: 3];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadow3Offset, shadow3BlurRadius, shadow3.CGColor);
    [color setFill];
    [roundedRectanglePath fill];
    CGContextRestoreGState(context);
    
}

@end

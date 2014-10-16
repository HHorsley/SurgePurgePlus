//
//  ResetButton.m
//  SurgePurgePlus
//
//  Created by Hunter Horsley on 10/15/14.
//  Copyright (c) 2014 YAH. All rights reserved.
//

#import "ResetButton.h"

@implementation ResetButton


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    // General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Color Declarations
    UIColor* color = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 0.7];
    
    // Shadow Declarations
    UIColor* shadow = [UIColor.blackColor colorWithAlphaComponent: 0.55];
    CGSize shadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat shadowBlurRadius = 1;
    
    // Rectangle Drawing
    CGRect rectangleRect = CGRectMake(0, 0, 70, 70);
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: rectangleRect cornerRadius: 3];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, [shadow CGColor]);
    [color setFill];
    [rectanglePath fill];
    CGContextRestoreGState(context);
    
    {
        NSString* textContent = @"X";
        NSMutableParagraphStyle* rectangleStyle = NSMutableParagraphStyle.defaultParagraphStyle.mutableCopy;
        rectangleStyle.alignment = NSTextAlignmentCenter;
        
        NSDictionary* rectangleFontAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize: 32], NSForegroundColorAttributeName: UIColor.whiteColor, NSParagraphStyleAttributeName: rectangleStyle};
        
        [textContent drawInRect: CGRectOffset(rectangleRect, 0, (CGRectGetHeight(rectangleRect) - [textContent boundingRectWithSize: rectangleRect.size options: NSStringDrawingUsesLineFragmentOrigin attributes: rectangleFontAttributes context: nil].size.height) / 2) withAttributes: rectangleFontAttributes];
    }

    
    
    
}


@end

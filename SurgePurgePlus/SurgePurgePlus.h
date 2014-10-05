//
//  SurgePurgePlus.h
//  SurgePurgePlus
//
//  Created by Geoffrey Vedernikoff on 10/4/14.
//  Copyright (c) 2014 YAH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SurgePurgePlus : NSObject

+ (CGPoint)createPointWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude miles:(CGFloat)miles degrees:(CGFloat)degrees;
+ (void)getSurge:(CGPoint)point callback:(void (^)(CGFloat surge))callback;
+ (void)escapeSurgeWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude callback:(void (^)(CGPoint point))callback;

@end

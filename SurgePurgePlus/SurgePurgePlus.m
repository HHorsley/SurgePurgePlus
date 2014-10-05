//
//  SurgePurgePlus.m
//  SurgePurgePlus
//
//  Created by Geoffrey Vedernikoff on 10/4/14.
//  Copyright (c) 2014 YAH. All rights reserved.
//

/** Degrees to Radian **/
#define toRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )
/** Radians to Degrees **/
#define toDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )
#define RADIUS 3959.0

#import "SurgePurgePlus.h"
#import "AFNetworking.h"

@implementation SurgePurgePlus

// taken from http://www.movable-type.co.uk/scripts/latlong.html
+ (CGPoint)createPointWithLatitude:(CGFloat)lat1 longitude:(CGFloat)lon1 miles:(CGFloat)miles degrees:(CGFloat)degrees {
    CGFloat radians = toRadians(degrees);
    CGFloat d = miles / RADIUS;
    lat1 = toRadians(lat1);
    lon1 = toRadians(lon1);
    
    CGFloat lat2 = asin(sin(lat1) * cos(d) + cos(lat1) * sin(d) * cos(radians));
    CGFloat lon2 = lon1 + atan2(sin(radians) * sin(d) * cos(lat1), cos(d) - sin(lat1) * sin(lat2));
    
    return CGPointMake(toDegrees(lat2), toDegrees(lon2));
}

+ (void)getSurge:(CGPoint)p callback:(void (^)(CGFloat surge))callback {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"Token oExcdluW-T23rusqa2_be7GBv_bXIGCW44nKdCPM" forHTTPHeaderField:@"Authorization"];
    NSDictionary *coords = @{
                             @"start_latitude": [NSNumber numberWithDouble:p.x],
                             @"start_longitude": [NSNumber numberWithDouble:p.y],
                             @"end_latitude": [NSNumber numberWithDouble:p.x],
                             @"end_longitude": [NSNumber numberWithDouble:p.y],
                             };
    
    [manager GET:@"https://api.uber.com/v1/estimates/price" parameters:coords success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        
        NSArray *prices = responseObject[@"prices"];
        CGFloat uberXsurge = -1.0;
        for (int i = 0; i < prices.count; i++) {
            NSDictionary *price = prices[i];
            if ([price[@"display_name"] isEqualToString:@"UberX"]) {
                uberXsurge = [price[@"surge_multiplier"] doubleValue];
                break;
            }
        }
        callback(uberXsurge);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        callback(-1.0);
    }];
}

+ (void)escapeSurgeWithLatitude:(CGFloat)lat longitude:(CGFloat)lon callback:(void (^)(CGPoint point))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    // Assume current spot is the first min
    __block CGPoint minPoint = CGPointMake(lat, lon);
    __block CGFloat minSurge = 10.0;
    dispatch_group_enter(group);
    [self getSurge:minPoint callback:^(CGFloat surge) {
        if (surge > 0) {
            minSurge = surge;
        }
        dispatch_group_leave(group);
    }];
    
    for (int i = 0; i < 360; i += 60) {
        CGPoint p = [self createPointWithLatitude:lat longitude:lon miles:1.0 degrees:i];
        dispatch_group_enter(group);
        
        // Send async request
        [self getSurge:p callback:^(CGFloat surge) {
            if (surge > 0 && surge < minSurge) {
                minSurge = surge;
                minPoint = p;
            }
            dispatch_group_leave(group);
        }];
    }
    dispatch_group_notify(group, queue, ^{
        NSLog(@"Final block is executed last");
        if (callback) {
            callback(minPoint);
        }
    });
}

@end

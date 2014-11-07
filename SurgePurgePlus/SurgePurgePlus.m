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
#define MINIMUM_SURGE 1.05
#define INITIAL_DISTANCE 0.5
#define NO_UBERX -9000.0

#import "SurgePurgePlus.h"
#import "AFNetworking.h"
#import "Surge.h"

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
    [manager.requestSerializer setValue:@"Token 3vG3ZC4c1MdesRm_4cb0aBM436dDZqLvzOBcoxfn" forHTTPHeaderField:@"Authorization"];
    NSDictionary *coords = @{
                             @"start_latitude": [NSNumber numberWithDouble: p.x],
                             @"start_longitude": [NSNumber numberWithDouble: p.y],
                             @"end_latitude": [NSNumber numberWithDouble: p.x],
                             @"end_longitude": [NSNumber numberWithDouble: p.y],
                             };
    
    [manager GET:@"https://api.uber.com/v1/estimates/price" parameters:coords success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *prices = responseObject[@"prices"];
        CGFloat uberXsurge = NO_UBERX - 1.0;
        for (int i = 0; i < prices.count; i++) {
            NSDictionary *price = prices[i];
            if ([price[@"display_name"] isEqualToString:@"uberX"]) {
                uberXsurge = [price[@"surge_multiplier"] doubleValue];
                break;
            }
        }
        callback(uberXsurge);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callback(-1.0);
    }];
}

+ (void)escapeSurgeWithLatitude:(CGFloat)lat longitude:(CGFloat)lon callback:(void (^)(NSString *error, CGPoint point))callback {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    CGPoint firstPoint = CGPointMake(lat, lon);
    
    __block Surge* min = [[Surge alloc] init];
    __block NSArray *surges = @[];

    dispatch_group_enter(group);
    [self getSurge:min.point callback:^(CGFloat surge) {
        surge = 5.0; // testing-only
        if (surge > 0) {
            NSLog(@"Surge at current location: %f", surge);
            if (surge < MINIMUM_SURGE) { // Current surge is 1.0
                if (callback) {
                    callback(@"You're currently in a Surge-free zone!", min.point);
                }
                return;
            }
            min.surge = surge;
            min.point = firstPoint;
        } else if (surge < NO_UBERX) {
            if (callback) {
                callback(@"UberX is not offered in your area. We cannot purge your Surge.", min.point);
            }
            return;
        }
        dispatch_group_leave(group);
    }];

    for (int i = 0; i < 360; i += 60) {
        CGPoint p = [self createPointWithLatitude:lat longitude:lon miles:INITIAL_DISTANCE degrees:i];
        dispatch_group_enter(group);
        [self getSurge:p callback:^(CGFloat surge) {
            NSLog(@"Surge at %d degrees is %f", i, surge);
            // only accept Surge of 1.0
            if (surge > 0 && surge < MINIMUM_SURGE) {
                Surge *s = [[Surge alloc] init];
                s.order = i;
                s.point = p;
                s.surge = surge;
                surges = [surges arrayByAddingObject:s];
            }
            dispatch_group_leave(group);
        }];
    }

    dispatch_group_notify(group, queue, ^{
        // Sort the surges array by degrees
        surges = [surges sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            int first = [(Surge*)a order];
            int second = [(Surge*)b order];
            return first < second;
        }];

        if ([surges count]) {
            min = [surges lastObject];
        }

        // only drill down if we find a surge-less area
        if (min.surge > 0 && min.surge < MINIMUM_SURGE) {
            surges = @[]; // reset surges array
            int minDegrees = min.order;
            CGFloat smallestDistance = INITIAL_DISTANCE / 5.0;

            for (int distance = 4; distance >= 1; distance--) {
                CGPoint p = [self createPointWithLatitude:lat longitude:lon miles:(distance * smallestDistance) degrees:minDegrees];
                dispatch_group_enter(group);
                [self getSurge:p callback:^(CGFloat surge) {
                    NSLog(@"Surge at %f miles away with angle %d is %f", (distance * smallestDistance), minDegrees, surge);
                    if (surge > 0 && surge < MINIMUM_SURGE) {
                        Surge *s = [[Surge alloc] init];
                        s.point = p;
                        s.order = distance;
                        s.surge = surge;
                        surges = [surges arrayByAddingObject:s];
                    }
                    dispatch_group_leave(group);
                }];
            }
            dispatch_group_notify(group, queue, ^{
                // Sort the surges array by distance
                surges = [surges sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                    int first = [(Surge*)a order];
                    int second = [(Surge*)b order];
                    return first < second;
                }];

                if ([surges count] > 0) {
                    min = [surges lastObject];
                }
                if (callback) {
                    callback(@"", min.point);
                }
                return;
            });
        } else if (min.surge > MINIMUM_SURGE) { // There's no escaping the surge
            if (callback) {
                callback(@"There's no escaping the Surge!", min.point);
            }
            return;
        } else { // API returned bad stuff
            if (callback) {
                callback(@"We could not process your request. Please try again later.", min.point);
            }
            return;
        }
    });
}

@end

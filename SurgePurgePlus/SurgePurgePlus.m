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



// taken from http://www.movable-type.co.uk/scripts/latlong.html
CGPoint createPoint(double lat1, double lon1, double miles, double degrees) {
    double radians = toRadians(degrees);
    double d = miles / RADIUS;
    lat1 = toRadians(lat1);
    lon1 = toRadians(lon1);

    double lat2 = asin(sin(lat1) * cos(d) + cos(lat1) * sin(d) * cos(radians));
    double lon2 = lon1 + atan2(sin(radians) * sin(d) * cos(lat1), cos(d) - sin(lat1) * sin(lat2));

    return CGPointMake(toDegrees(lat2), toDegrees(lon2));
}

void getSurge(CGPoint p, void (^callback)(double someDouble)) {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:@"Token oExcdluW-T23rusqa2_be7GBv_bXIGCW44nKdCPM" forHTTPHeaderField:@"Authorization"];
    NSDictionary *coords = @{
                             @"start_latitude" : [NSNumber numberWithDouble:p.x],
                             @"start_longitude" : [NSNumber numberWithDouble:p.y],
                             @"end_latitude": [NSNumber numberWithDouble:p.x],
                             @"end_longitude" : [NSNumber numberWithDouble:p.y],
                             };
    
    [manager GET:@"https://api.uber.com/v1/estimates/price" parameters:coords success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);

        NSArray *prices = responseObject[@"prices"];
        double uberXsurge = -1.0;
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

CGPoint escapeSurge(double lat, double lon) {
    // Assume current spot is the first min
    CGPoint minPoint = CGPointMake(lat, lon);
    double minSurge = 0.0;
    
    
    for (int i = 0; i < 360; i += 60) {
        CGPoint p = createPoint(lat, lon, 1.0, i);
        getSurge(p, ^(double surge){
            
        });
        if (minSurge > surge) {
            minSurge = surge;
            minPoint = p;
        }
    }
    return minPoint;
}
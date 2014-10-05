//
//  SurgePurgePlus.m
//  SurgePurgePlus
//
//  Created by Geoffrey Vedernikoff on 10/4/14.
//  Copyright (c) 2014 YAH. All rights reserved.
//

#import "SurgePurgePlus.h"
#import "AFNetworking.h"

CGPoint createPoint(double lat, double lon, double miles, double degrees) {
    return CGPointMake(lat, lon);

}

double getSurge(CGPoint p) {
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
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    return 0.0;
}

CGPoint escapeSurge(double lat, double lon) {
    double minSurge = 0.0;
    CGPoint minPoint;
    
    for (int i = 0; i < 360; i += 60) {
        CGPoint p = createPoint(lat, lon, 1.0, i);
        double surge = getSurge(p);
        if (minSurge && minSurge > surge) {
            minSurge = surge;
            minPoint = p;
        } else {
            minSurge = surge;
            minPoint = p;
        }
    }
    return minPoint;
}
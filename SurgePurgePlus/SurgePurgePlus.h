//
//  SurgePurgePlus.h
//  SurgePurgePlus
//
//  Created by Geoffrey Vedernikoff on 10/4/14.
//  Copyright (c) 2014 YAH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern CGPoint createPoint(double lat, double lon, double miles, double degrees);
extern void getSurge(CGPoint p, void (^callback)(double someDouble));
extern CGPoint escapeSurge(double lat, double lon);
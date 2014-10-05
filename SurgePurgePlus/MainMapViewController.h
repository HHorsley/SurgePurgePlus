//
//  MainMapViewController.h
//  SurgePurgePlus
//
//  Created by Hunter Horsley on 10/4/14.
//  Copyright (c) 2014 YAH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SurgePurgePlus.h"
#import "math.h"

@interface MainMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D surgePurgeCoords;
@property (nonatomic, strong) MKPointAnnotation *currentLocationPoint;
@property (nonatomic, strong) NSString *timeToDestination;
@property (nonatomic, strong) IBOutlet UIButton *escapeSurgeButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingGif;




@end




#import "MainMapViewController.h"

@interface MainMapViewController ()

@end

@implementation MainMapViewController

@synthesize mapView;
@synthesize locationManager;
@synthesize surgePurgeCoords;
@synthesize currentLocationPoint;
@synthesize destinationLocationPoint;


- (IBAction)EscapeSurgeButton:(UIButton *)sender {
    _escapeSurgeButton.hidden = YES;
    _loadingGif.hidden = NO;

    
    [SurgePurgePlus escapeSurgeWithLatitude:currentLocationPoint.coordinate.latitude longitude:currentLocationPoint.coordinate.longitude callback:^(CGPoint destination) {

        CLLocationCoordinate2D dest = CLLocationCoordinate2DMake(destination.x, destination.y);
        [self drawRouteFrom:currentLocationPoint.coordinate to:dest];
    }];
}




- (void)viewDidLoad {
    // NSLog(@"ViewDidLoad");
    [super viewDidLoad];
    //check to see if they have location servies on
    if ([CLLocationManager locationServicesEnabled] == YES) {
        [self startStandardUpdates];
        self.mapView.delegate = self;

        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Services Off"
                                                        message:@"Hey! We can't help if your location services aren't on or this app. Head over to your Settings and give this app location permission."
                                                       delegate:nil
                                              cancelButtonTitle:@"Got it!"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

- (IBAction)resetButton:(UIButton *)sender {
    [self viewDidLoad];
    //[self.mapView removeAnnotation:self.destinationLocationPoint];
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //[CLLocationManager requestWhenInUseAuthorization];
    
    // Add an annotation
    if (nil == currentLocationPoint) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000);
        [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

        // currentLocationPoint = userLocation.coordinate;
        MKPointAnnotation *currentLocationAnnotation = [[MKPointAnnotation alloc] init];
        currentLocationAnnotation.coordinate = userLocation.coordinate;
        currentLocationAnnotation.title = @"Your Current Location";
        [self.mapView addAnnotation:currentLocationAnnotation];
    } else {
        [locationManager stopUpdatingLocation];
    }
    [SurgePurgePlus escapeSurgeWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude callback:^(CGPoint destination) {
        
        destinationLocationPoint.coordinate = CLLocationCoordinate2DMake(destination.x, destination.y);
        destinationLocationPoint.title = @"No surge here!";
        [self.mapView addAnnotation:destinationLocationPoint];
    }];
}
 */






- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    // NSLog(@"startStandardUpdates");
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 250;
    self.desiredLocationFreshness = 15.0; // desired freshness in s
    self.desiredLocationAccuracy = 100.0; // desired location accuracy in m
    self.improvementAccuracyToGiveUpOn = 30.0; // desired improvement in m
    self.timeToFindLocation = 10.0; // timeout to find location in s
    self.locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}



- (void)drawRouteFrom:(CLLocationCoordinate2D)sourceCoords to:(CLLocationCoordinate2D)destinationCoords {
    
    MKPlacemark *source = [[MKPlacemark alloc]initWithCoordinate:sourceCoords addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *srcMapItem = [[MKMapItem alloc]initWithPlacemark:source];
    [srcMapItem setName:@""];
    
    MKPlacemark *destination = [[MKPlacemark alloc]initWithCoordinate:destinationCoords addressDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"", nil] ];
    
    MKMapItem *distMapItem = [[MKMapItem alloc]initWithPlacemark:destination];
    [distMapItem setName:@""];
    
    
    //safe
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc]init];
    [request setSource:srcMapItem];
    [request setDestination:distMapItem];
    [request setTransportType:MKDirectionsTransportTypeWalking];
    
    MKDirections *direction = [[MKDirections alloc]initWithRequest:request];
    
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        // NSLog(@"response = %@",response);
        NSArray *arrRoutes = [response routes];
        [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MKRoute *rout = obj;
            
            MKPolyline *line = [rout polyline];
            MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:line];
            routeRenderer.strokeColor = [UIColor blueColor];
            
            // Draw the destination pin
            self.destinationLocationPoint = [[MKPointAnnotation alloc] init];
            destinationLocationPoint.coordinate = destinationCoords;
            destinationLocationPoint.title = @"No surge here!";
            [self.mapView addAnnotation:destinationLocationPoint];

            // Draw the route
            [self.mapView addOverlay:line level:MKOverlayLevelAboveRoads];
            _timeToDestination = [NSString stringWithFormat:@"Nearest surge-free is %d min away!", (int)ceilf(rout.expectedTravelTime / 60.0)];
            _distanceLabel.text = _timeToDestination;
            [_loadingGif setHidden:TRUE];
            [_distanceLabel setHidden:FALSE];
            NSLog(@"ETA = %@", _timeToDestination);
            
//            NSArray *steps = [rout steps];
//            NSLog(@"Total Steps : %lu",(unsigned long)[steps count]);
//            NSLog(@"Rout Name : %@",rout.name);
//            NSLog(@"Total Distance (in Meters) :%f",rout.distance);
//            [steps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                NSLog(@"Rout Instruction : %@",[obj instructions]);
//                NSLog(@"Rout Distance : %f",[obj distance]);
//            }];
        }];
    }];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 6.0;
    return  renderer;
}







//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateLocations:(NSArray *)locations {
//    CLLocation* location = [locations lastObject];
//    NSDate* eventDate = location.timestamp;
//    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
//    if (abs(howRecent) < 15.0) {
//        // If the event is recent, do something with it.
//        NSLog(@"latitude %+.6f, longitude %+.6f\n",
//              location.coordinate.latitude,
//              location.coordinate.longitude);
//    }
//}

- (void)finalizeLocationSearch {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(currentLocationPoint.coordinate, 2000, 2000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

    MKPointAnnotation *currentLocationAnnotation = [[MKPointAnnotation alloc] init];
    currentLocationAnnotation.coordinate = currentLocationPoint.coordinate;
    currentLocationAnnotation.title = @"Your Current Location";
    [self.mapView addAnnotation:currentLocationAnnotation];
    [locationManager stopUpdatingLocation];
}



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) > self.desiredLocationFreshness || newLocation.horizontalAccuracy < 0) {
        // This location is way too old or straight up inaccurate. Keep trying to get better.
        if(nil == self.currentLocationPoint) {
            // Storing this anyway as the best location we have so far, unfortunately.
            self.locationRecent = NO;
            self.locationAccurate = NO;
            self.currentLocationPoint = newLocation;
        }
    }
    else if (newLocation.horizontalAccuracy > self.desiredLocationAccuracy && (oldLocation.horizontalAccuracy==0.0 || (oldLocation.horizontalAccuracy-newLocation.horizontalAccuracy) > self.improvementAccuracyToGiveUpOn)) {
        // Still too inaccurate but we are improving by enough over time or it's our first try. Keep trying to get better.
        if((nil == self.currentLocationPoint) || (newLocation.horizontalAccuracy < self.currentLocationPoint.horizontalAccuracy)) {
            // Storing this anyway as the best location we have so far, unfortunately.
            self.locationRecent = YES;
            self.locationAccurate = NO;
            self.currentLocationPoint = newLocation;
        }
    }
    else {
        // OK everyone-we either have  a great location or the location isn't total crap but we're not improving by enough over time. Time to call it quits.
        [self.locationManager stopUpdatingLocation];
        self.locationRecent = YES;
        self.locationAccurate = YES;
        self.currentLocationPoint = newLocation;
        [self finalizeLocationSearch];
    }
}

@end




#import "MainMapViewController.h"

@interface MainMapViewController ()

@end

@implementation MainMapViewController

@synthesize mapView;
@synthesize locationManager;
@synthesize surgePurgeCoords;
@synthesize currentLocationPoint;


- (IBAction)EscapeSurgeButton:(UIButton *)sender {
    _escapeSurgeButton.hidden = YES;
    _loadingGif.hidden = NO;

    MKPointAnnotation *destinationLocationPoint = [[MKPointAnnotation alloc] init];
    
    [SurgePurgePlus escapeSurgeWithLatitude:currentLocationPoint.coordinate.latitude longitude:currentLocationPoint.coordinate.longitude callback:^(CGPoint destination) {

        destinationLocationPoint.coordinate = CLLocationCoordinate2DMake(destination.x, destination.y);
        destinationLocationPoint.title = @"No surge here!";
        [self.mapView addAnnotation:destinationLocationPoint];

        [self drawRouteFrom:currentLocationPoint.coordinate to:destinationLocationPoint.coordinate];
    }];
}




- (void)viewDidLoad {
    NSLog(@"ViewDidLoad");
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    //[CLLocationManager requestWhenInUseAuthorization];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    // Add an annotation
    currentLocationPoint = [[MKPointAnnotation alloc] init];
    currentLocationPoint.coordinate = userLocation.coordinate;
    currentLocationPoint.title = @"Your Current Location";
    [self.mapView addAnnotation:currentLocationPoint];
    
    /*
    [SurgePurgePlus escapeSurgeWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude callback:^(CGPoint destination) {
        
        destinationLocationPoint.coordinate = CLLocationCoordinate2DMake(destination.x, destination.y);
        destinationLocationPoint.title = @"No surge here!";
        [self.mapView addAnnotation:destinationLocationPoint];
    }];
    */
}






- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager) {
        locationManager = [[CLLocationManager alloc] init];
    }
    NSLog(@"startStandardUpdates");
    [locationManager requestWhenInUseAuthorization];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
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
        
        NSLog(@"response = %@",response);
        NSArray *arrRoutes = [response routes];
        [arrRoutes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            MKRoute *rout = obj;
            
            MKPolyline *line = [rout polyline];
            MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:line];
            routeRenderer.strokeColor = [UIColor blueColor];
            
            [self.mapView addOverlay:line level:MKOverlayLevelAboveRoads];
            _timeToDestination = [NSString stringWithFormat:@"Nearest surge-free is %d min away!", (int)ceilf(rout.expectedTravelTime / 60.0)];
            _distanceLabel.text = _timeToDestination;
            [_loadingGif setHidden:TRUE];
            [_distanceLabel setHidden:FALSE];
            NSLog(@"ETA = %@", _timeToDestination);

            NSLog(@"ETA = %d", (int)ceilf(rout.expectedTravelTime / 60.0));
 
            
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

@end

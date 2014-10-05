


#import "MainMapViewController.h"

@interface MainMapViewController ()

@end

@implementation MainMapViewController

@synthesize mapView;
@synthesize locationManager;
@synthesize surgePurgeCoords;


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
    MKPointAnnotation *currentLocationPoint = [[MKPointAnnotation alloc] init];
    currentLocationPoint.coordinate = userLocation.coordinate;
    currentLocationPoint.title = @"Your Current Location";
    [self.mapView addAnnotation:currentLocationPoint];
    
    MKPointAnnotation *destinationLocationPoint = [[MKPointAnnotation alloc] init];
    
    destinationLocationPoint.coordinate = CLLocationCoordinate2DMake(42.374400, -71.116900);
    destinationLocationPoint.title = @"No surge here!";
    [self.mapView addAnnotation:destinationLocationPoint];
    
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

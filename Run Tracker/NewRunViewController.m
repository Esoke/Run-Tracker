//
//  NewRunViewController.m
//  Run Tracker
//
//  Created by Esma on 12/13/15.
//  Copyright © 2015 Esma. All rights reserved.
//

#import "NewRunViewController.h"
#import "DetailViewController.h"
#import "Run.h"
#import <CoreLocation/CoreLocation.h>
#import "MathController.h"
#import "Location.h"
#import <MapKit/MapKit.h>

static NSString * const detailSegueName = @"RunDetails";

@interface NewRunViewController () <UIActionSheetDelegate, CLLocationManagerDelegate, MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *runnerImg;


@property int seconds;
@property float distance;
@property BOOL isMetric;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locations;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) Run *run;

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *distLabel;
@property (nonatomic, weak) IBOutlet UILabel *paceLabel;
@property (nonatomic, weak) IBOutlet UIButton *startButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *paceUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;


@end

@interface NewRunViewController ()

@end

@implementation NewRunViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    
    self.startButton.hidden = NO;
    
    self.timeLabel.text = @"";
    self.timeLabel.hidden = YES;
    self.distLabel.hidden = YES;
    self.distanceUnitLabel.hidden = YES;
    self.paceLabel.hidden = YES;
    self.paceUnitLabel.hidden = YES;
    self.stopButton.hidden = YES;
    self.mapView.hidden = YES;
    //self.caloriesLabel.hidden = YES;
    
    self.startButton.layer.cornerRadius = self.startButton.frame.size.width /2;
    self.startButton.clipsToBounds = YES;
    
    self.stopButton.layer.cornerRadius = self.stopButton.frame.size.width /2;
    self.stopButton.clipsToBounds =YES;
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.timeLabel.layer.cornerRadius = self.timeLabel.frame.size.height /3;
    self.paceLabel.layer.cornerRadius = self.paceLabel.frame.size.height/3;
    self.distLabel.layer.cornerRadius = self.distLabel.frame.size.height /3;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startLocationUpdates];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)eachSecond
{
    self.seconds++;
    self.timeLabel.text = [NSString stringWithFormat:@"%@",  [MathController stringifySecondCount:self.seconds usingLongFormat:NO inMetricUnits:self.isMetric]];
    self.distLabel.text = [NSString stringWithFormat:@"%@", [MathController stringifyDistance:self.distance usingLongFormat:NO inMetricUnits:self.isMetric]];
    self.paceLabel.text = [NSString stringWithFormat:@"%@",  [MathController stringifyAvgPaceFromDist:self.distance overTime:self.seconds usingLongFormat:NO inMetricUnits:self.isMetric]];
}

- (void)startLocationUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    // Movement threshold for new events.
    self.locationManager.distanceFilter = 10; // meters
    
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    if(error){
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Unable to reach location."
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    }
    
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500);
    [self.mapView setRegion:region animated:YES];
    
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *newLocation in locations) {
        
        NSDate *eventDate = newLocation.timestamp;
        
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        if (fabs(howRecent) < 10.0 && newLocation.horizontalAccuracy < 20) {
            
            // update distance
            if (self.locations.count > 0) {
                self.distance += [newLocation distanceFromLocation:self.locations.lastObject];
                
                CLLocationCoordinate2D coords[2];
                coords[0] = ((CLLocation *)self.locations.lastObject).coordinate;
                coords[1] = newLocation.coordinate;
                
                [self.mapView addOverlay:[MKPolyline polylineWithCoordinates:coords count:2]];
            }
            
            [self.locations addObject:newLocation];
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyLine = (MKPolyline *)overlay;
        MKPolylineRenderer *aRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyLine];
        aRenderer.strokeColor = [UIColor colorWithRed:46.0f/255.0f green:201.0f/255.0f blue:176.0f/255.0f alpha:1.0f];
        aRenderer.lineWidth = 5;
        return aRenderer;
    }
    return nil;
}


- (void)saveRun
{
    Run *newRun = [NSEntityDescription insertNewObjectForEntityForName:@"Run"
                                                inManagedObjectContext:self.managedObjectContext];
    
    newRun.distance = [NSNumber numberWithFloat:self.distance];
    newRun.duration = [NSNumber numberWithInt:self.seconds];
    newRun.timestamp = [NSDate date];
    
    NSMutableArray *locationArray = [NSMutableArray array];
    for (CLLocation *location in self.locations) {
        Location *locationObject = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                 inManagedObjectContext:self.managedObjectContext];
        
        locationObject.timestamp = location.timestamp;
        locationObject.latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
        locationObject.longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
        [locationArray addObject:locationObject];
    }
    
    newRun.locations = [NSOrderedSet orderedSetWithArray:locationArray];
    self.run = newRun;
    
    // Save the context.
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

-(IBAction)startPressed:(id)sender
{
    // hide the start UI
    self.startButton.hidden = YES;
    self.runnerImg.hidden = YES;
    self.segmentedControl.hidden = YES;
    
    // show the running UI
    self.mapView.hidden = NO;
    self.timeLabel.hidden = NO;
    self.distLabel.hidden = NO;
    self.distanceUnitLabel.hidden = NO;
    self.paceLabel.hidden = NO;
    self.paceUnitLabel.hidden = NO;
    self.stopButton.hidden = NO;
    
    self.seconds = 0;
    self.distance = 0;
    self.locations = [NSMutableArray array];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self
                                                selector:@selector(eachSecond) userInfo:nil repeats:YES];
    
    self.mapView.showsUserLocation = YES;
    [self startLocationUpdates];
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView setRegion: MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 500, 500)];
    }

- (IBAction)stopPressed:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self
                                                    cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Save", @"Discard", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
    
    [self.timer invalidate];
    [self.locationManager stopUpdatingLocation];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // save
    if (buttonIndex == 0) {
        [self saveRun];
        [self performSegueWithIdentifier:detailSegueName sender:nil];
        
        // discard
    } else if (buttonIndex == 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
   
        // cancel
    }else if (buttonIndex == 2) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self
                                                    selector:@selector(eachSecond) userInfo:nil repeats:YES];
        [self.locationManager startUpdatingLocation];
    }
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[segue destinationViewController] setRun:self.run];
}


- (IBAction)unitSelectionChanged:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 0){ //km is chosen
        self.isMetric = YES;
        self.distanceUnitLabel.text = @"km";
        self.paceUnitLabel.text = @"min/km";
    }else{// miles is chosen
        self.isMetric = NO;
        self.distanceUnitLabel.text = @"mi";
        self.paceUnitLabel.text = @"min/mi";
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:self.isMetric forKey:@"isMetric"];
    [userDefaults synchronize];
}



@end

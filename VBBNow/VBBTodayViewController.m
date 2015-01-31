//
//  VBBTodayViewController.m
//  today
//
//  Created by Dennis Oberhoff on 30/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

@import CoreLocation;
@import NotificationCenter;

#import "VBBTodayViewController.h"
#import "VBBListRowViewController.h"
#import "VBBNetworkManager.h"

typedef void (^didUpdateLocationBlock)(CLLocation *location);
typedef void (^didChangeAuthorizationStatus)(CLAuthorizationStatus status);

@interface VBBTodayViewController () <NCWidgetProviding, NCWidgetListViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, readwrite, strong) IBOutlet NCWidgetListViewController *listViewController;
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;
@property (nonatomic, readwrite, copy) didUpdateLocationBlock didUpdateLocationBlock;
@property (nonatomic, readwrite, copy) didChangeAuthorizationStatus didChangeAuthorizationStatus;

@end

@implementation VBBTodayViewController

#pragma mark - NSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSURLCache setSharedURLCache:nil];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;

}

-(void)reloadDataForLocation:(CLLocation*)location {
    
    if (!location) return;
    self.listViewController.contents = [[VBBStation class] sortByDistance:location andLimit:5];
    
}

#pragma mark - NCWidgetProviding

-(void)fetchNearby: (void (^)(NCUpdateResult result))completionHandler {
 
    __block typeof(self) blockSelf = self;
    void (^responseBlock)(CLLocation *location) = ^void(CLLocation *location) {
        if (location) [blockSelf storeLocation:location];
        else location = [blockSelf storedLocation];
        if (!location) {
            completionHandler(NCUpdateResultFailed);
            return;
        }
        [[VBBNetworkManager manager] fetchNearedStations:location andCompletionHandler:^(NSArray *stations) {
            [blockSelf reloadDataForLocation:location];
            completionHandler(NCUpdateResultNewData);
        }];
        
    };
    
    if ([[CLLocationManager class] authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        responseBlock([self storedLocation]);
    }
    
    [self setDidUpdateLocationBlock:responseBlock];
    [self.locationManager startUpdatingLocation];
    
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    [self fetchNearby:completionHandler];
}

- (NSEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(NSEdgeInsets)defaultMarginInset {
    defaultMarginInset.left = 0;
    return defaultMarginInset;
}

#pragma mark - NCWidgetListViewDelegate

- (NSViewController *)widgetList:(NCWidgetListViewController *)list viewControllerForRow:(NSUInteger)row {
    return [[VBBListRowViewController alloc] init];
}

- (BOOL)widgetList:(NCWidgetListViewController *)list shouldReorderRow:(NSUInteger)row {
    return NO;
}

- (BOOL)widgetList:(NCWidgetListViewController *)list shouldRemoveRow:(NSUInteger)row {
    return NO;
}

- (BOOL)widgetAllowsEditing {
    return NO;
}

#pragma mark Location Persistance

-(void)storeLocation:(CLLocation*)location {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:location.coordinate.latitude forKey:@"latitude"];
    [defaults setDouble:location.coordinate.longitude forKey:@"longitude"];
    [defaults synchronize];
}

-(CLLocation*)storedLocation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    double latitude = [[defaults objectForKey:@"latitude"] doubleValue];
    double longitude = [[defaults objectForKey:@"longitude"] doubleValue];
    CLLocation *location;
    if (latitude && longitude) location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    return location;
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (self.didUpdateLocationBlock) {
        self.didUpdateLocationBlock(locations.firstObject);
        self.didUpdateLocationBlock = nil;
    }
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (self.didChangeAuthorizationStatus) {
        self.didChangeAuthorizationStatus(status);
        self.didChangeAuthorizationStatus = nil;
    }
}

@end

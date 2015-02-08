//
//  VBBTodayViewController.m
//  today
//
//  Created by Dennis Oberhoff on 30/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

@import CoreLocation;
@import NotificationCenter;
@import QuartzCore;

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
    self.listViewController.preferredContentSize = CGSizeMake(320, 350);
    [self performSelector:@selector(reloadDataForLocation:) withObject:[VBBPersistanceManager manager].storedLocation afterDelay:3.5];

}

-(void)reloadDataForLocation:(CLLocation*)location {
    
    if (!location) return;
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.toValue = @(0.0);
    opacity.duration = 0.35;
    opacity.removedOnCompletion = NO;
    opacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    opacity.fillMode = kCAFillModeBoth;
    opacity.delegate = self;
    [opacity setValue:@"opacity" forKey:@"identifier"];
    [opacity setValue:location forKey:@"location"];
    [self.listViewController.view.layer addAnimation:opacity forKey:@"opacity"];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:[NSDate date]];
    NSTimeInterval refreshInterval = 60 - components.second;
    [self performSelector:@selector(reloadDataForLocation:) withObject:[VBBPersistanceManager manager].storedLocation afterDelay:refreshInterval];
    
}


#pragma mark - NCWidgetProviding

-(void)fetchNearby: (void (^)(NCUpdateResult result))completionHandler {
 
    __block typeof(self) blockSelf = self;
    void (^responseBlock)(CLLocation *location) = ^void(CLLocation *location) {
        if (location) [[VBBPersistanceManager manager]  storeLocation:location];
        else location = [[VBBPersistanceManager manager]  storedLocation];
        if (!location) {
            completionHandler(NCUpdateResultFailed);
            return;
        }
        [[VBBNetworkManager manager] fetchNearedStations:location andCompletionHandler:^(NSArray *stations) {
            [NSObject cancelPreviousPerformRequestsWithTarget:blockSelf];
            [blockSelf reloadDataForLocation:location];
            completionHandler(NCUpdateResultNewData);
        }];
    };
    
    if ([[CLLocationManager class] authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        responseBlock([[VBBPersistanceManager manager]  storedLocation]);
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

#pragma mark CoreAnimation Delegate

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    NSString *key = [anim valueForKey:@"identifier"];
    if ([key isEqualTo:@"opacity"]) {
        CLLocation *location = [anim valueForKey:@"location"];
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacity.duration = 0.35;
        opacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        opacity.toValue = @(1.0);
        opacity.removedOnCompletion = NO;
        opacity.fillMode = kCAFillModeForwards;
        opacity.fromValue = [self.listViewController.view.layer.presentationLayer ?: self.listViewController.view.layer valueForKeyPath:opacity.keyPath];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.listViewController.contents = [[VBBStation class] sortByRelevance:location andLimit:5];
        [self.listViewController.view.layer setValue:opacity.toValue forKeyPath:opacity.keyPath];
        [CATransaction commit];
        [self.listViewController.view.layer addAnimation:opacity forKey:@"opacity"];
    }
    
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (self.didUpdateLocationBlock) {
        CLLocation *newLocation = locations.firstObject;
        CLLocation *storedLocation = [VBBPersistanceManager manager].storedLocation;
        if (storedLocation && [newLocation distanceFromLocation:storedLocation] < 20) return;
        [[VBBPersistanceManager manager] storeLocation:newLocation];
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

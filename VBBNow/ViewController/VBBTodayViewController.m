//
//  VBBTodayViewController.m
//  today
//
//  Created by Dennis Oberhoff on 30/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

@import VBBFramework;
@import CoreLocation;
@import NotificationCenter;
@import QuartzCore;

#import "VBBTodayViewController.h"
#import "VBBListRowViewController.h"

typedef void (^didUpdateLocationBlock)(CLLocation *location);
typedef void (^didChangeAuthorizationStatus)(CLAuthorizationStatus status);

@interface VBBTodayViewController () <NCWidgetProviding, NCWidgetListViewDelegate, CLLocationManagerDelegate, CAAnimationDelegate>

@property (nonatomic, readwrite, strong) VBBNetworkManager *networkManager;
@property (nonatomic, readwrite, strong) IBOutlet NSTextField *locationLabel;
@property (nonatomic, readwrite, strong) IBOutlet NCWidgetListViewController *listViewController;
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;
@property (nonatomic, readwrite, copy) didUpdateLocationBlock didUpdateLocationBlock;
@property (nonatomic, readwrite, copy) didChangeAuthorizationStatus didChangeAuthorizationStatus;

@end

@implementation VBBTodayViewController

#pragma mark - NSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.networkManager = [VBBNetworkManager new];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    VBBLocation *storedLocation = [VBBPersistanceManager manager].storedLocation;
    if (storedLocation.address) [self.locationLabel setStringValue:storedLocation.address];
    self.listViewController.preferredContentSize = CGSizeMake(320, 350);
    self.listViewController.contents = [[VBBStation class] sortByRelevance:storedLocation andLimit:5];
}

-(void)reloadDataForLocation:(VBBLocation*)location {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (location) {
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacity.toValue = @(0.0);
        opacity.duration = 0.35;
        opacity.removedOnCompletion = NO;
        opacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        opacity.fillMode = kCAFillModeBoth;
        opacity.delegate = self;
        [opacity setValue:@"opacity" forKey:@"identifier"];
        [opacity setValue:location forKey:@"location"];
        [self.view.layer addAnimation:opacity forKey:@"opacity"];
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:[NSDate date]];
        NSTimeInterval refreshInterval = 60 - components.second;
        [self performSelector:@selector(reloadDataForLocation:) withObject:location afterDelay:refreshInterval];
    }
}


#pragma mark - NCWidgetProviding

-(void)fetchNearby: (void (^)(NCUpdateResult result))completionHandler {
 
    __weak typeof(self) weakSelf = self;
    void (^responseBlock)(CLLocation *location) = ^void(CLLocation *location) {
        [self.networkManager fetchNearedStations:location andCompletionHandler:^(NSArray *stations, VBBLocation *location) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (location) [weakSelf reloadDataForLocation:location];
                completionHandler(stations.count ? NCUpdateResultNewData : NCUpdateResultFailed);
            });
        }];
    };
    
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
        VBBLocation *location = [anim valueForKey:@"location"];
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacity.duration = 0.35;
        opacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        opacity.toValue = @(1.0);
        opacity.removedOnCompletion = NO;
        opacity.fillMode = kCAFillModeForwards;
        opacity.fromValue = [self.view.layer.presentationLayer ?: self.view.layer valueForKeyPath:opacity.keyPath];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.listViewController.contents = [[VBBStation class] sortByRelevance:location andLimit:5];
        [self.view.layer setValue:opacity.toValue forKeyPath:opacity.keyPath];
        if (location.address) [self.locationLabel setStringValue:location.address];
        [CATransaction commit];
        [self.view.layer addAnimation:opacity forKey:@"opacity"];
    }
    
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (self.didUpdateLocationBlock) self.didUpdateLocationBlock(locations.firstObject);
    self.didUpdateLocationBlock = nil;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.didUpdateLocationBlock) self.didUpdateLocationBlock(nil);
    self.didUpdateLocationBlock = nil;
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (self.didChangeAuthorizationStatus) {
        self.didChangeAuthorizationStatus(status);
        self.didChangeAuthorizationStatus = nil;
    }
}

@end

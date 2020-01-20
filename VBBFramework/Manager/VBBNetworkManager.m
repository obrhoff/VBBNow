//
//  VBBNetworkManager.m
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

@import CoreLocation;
@import Contacts;
@import MapKit;
@import Contacts;

#import "VBBNetworkManager.h"
#import "VBBStationParser.h"
#import "VBBDepatureParser.h"

@interface VBBNetworkManager () <NSURLSessionDelegate>

@property(class, nonatomic, readonly) CNPostalAddressFormatter *addressFormatter;

@property(nonatomic, readwrite, strong) NSURLSession *session;
@property(nonatomic, readwrite, strong) CLGeocoder *geocoder;
@property(nonatomic, readwrite, assign) VBBNetworkStatus status;

@end

@implementation VBBNetworkManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                    delegate:self
                                               delegateQueue:[[self class] operationQueue]];
    }
    return self;
}

- (void)fetchNearedStations:(CLLocation * _Nonnull)location
       andCompletionHandler:(void (^ _Nonnull)(NSArray <VBBStation*> * _Nullable stations, VBBLocation * _Nullable location))completionHandler {

    __weak typeof(self) weakSelf = self;
    
    void (^ finalizeBlock)(NSArray <VBBStation*> *stations, VBBLocation *location) = ^void(NSArray <VBBStation*> *stations, VBBLocation * location) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.status = VBBNetworkStatusFinished;
            if (completionHandler) completionHandler(stations, location);
        });
    };

    void (^ stationsBlock)(VBBLocation *stationLocation) = ^void(VBBLocation *stationLocation) {
        NSNumber *latitude = @(location.coordinate.latitude * 1000000);
        NSNumber *longitude = @(location.coordinate.longitude * 1000000);
        
        NSMutableArray *query = [NSMutableArray array];
        [query addObject:[NSURLQueryItem queryItemWithName:@"performLocating" value:@"2"]];
        [query addObject:[NSURLQueryItem queryItemWithName:@"L" value:@"vs_java"]];
        [query addObject:[NSURLQueryItem queryItemWithName:@"look_x" value:longitude.stringValue]];
        [query addObject:[NSURLQueryItem queryItemWithName:@"look_y" value:latitude.stringValue]];
        [query addObject:[NSURLQueryItem queryItemWithName:@"look_maxdist" value:@"1000"]];
        [query addObject:[NSURLQueryItem queryItemWithName:@"look_maxno" value:@"10"]];
        
        NSURLComponents *components = [NSURLComponents new];
        components.scheme = @"http";
        components.host = @"fahrinfo.vbb.de";
        components.path = @"/bin/query.exe/dol";
        components.queryItems = query.copy;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];
        
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"%@: %@", NSStringFromClass([self class]), error.localizedDescription);
                weakSelf.status = VBBNetworkStatusFailed;
                finalizeBlock(nil, nil);
                return;
            }
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
            VBBStationParser *stationParser = [VBBStationParser new];
            parser.delegate = stationParser;
            [parser parse];

            weakSelf.status = VBBNetworkStatusFinished;
            
            if (stationParser.stations.count == 0) {
                finalizeBlock(nil, stationLocation);
                return;
            }

            [self fetchDeparturesFromStations:stationParser.stations andCompletionHandler:^(NSArray *stations) {
                finalizeBlock(stations, stationLocation);
            }];
        }];
        
        self.status = VBBNetworkStatusLoading;
        [task resume];
    };
    
    VBBLocation *storedLocation = [VBBPersistanceManager manager].storedLocation;
    
    if (storedLocation && !location) {
        stationsBlock(storedLocation);
    } else if (location && storedLocation && [storedLocation.location distanceFromLocation:location] < 15) {
        stationsBlock(storedLocation);
    } else if (location) {
        self.status = VBBNetworkStatusGeocoding;
        self.geocoder = [CLGeocoder new];
        [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = placemarks.firstObject;
            VBBLocation *stationLocation = [VBBLocation new];
            stationLocation.location = location;
            stationLocation.date = [NSDate new];
            stationLocation.address = [[VBBNetworkManager addressFormatter] stringFromPostalAddress:placemark.postalAddress];
            [VBBPersistanceManager manager].storedLocation = stationLocation;
            weakSelf.status = VBBNetworkStatusFinished;
            stationsBlock(stationLocation);
        }];
    } else {
        finalizeBlock(nil, nil);
    }
}

- (void)fetchDeparturesFromStations:(NSArray *)stations andCompletionHandler:(void (^)(NSArray *stations))completionHandler {

    __block NSUInteger count = stations.count;
    __weak typeof(self) weakSelf = self;

    void (^responseBlock)(VBBStation *station) = ^void(VBBStation *station) {
        if (--count) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.status = VBBNetworkStatusFinished;
            if (completionHandler) completionHandler(stations);
        });
    };
    
    self.status = VBBNetworkStatusLoadingDetails;
    for (VBBStation *station in stations) {
        [self fetchDepature:station andCompletionHandler:responseBlock];
    }
}

- (void)fetchDepature:(VBBStation *)station andCompletionHandler:(void (^)(VBBStation *station))completionHandler {

    NSString * stationId = station.stationId.copy;

    NSMutableArray *query = [NSMutableArray array];
    [query addObject:[NSURLQueryItem queryItemWithName:@"boardType" value:@"yes"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"disableEquivs" value:@"yes"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"maxJourneys" value:@"30"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"L" value:@"vs_java3"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"start" value:@"yes"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"input" value:station.stationId]];

    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"http";
    components.host = @"fahrinfo.vbb.de";
    components.path = @"/bin/stboard.exe/dn";
    components.queryItems = query.copy;
    NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@: %@", NSStringFromClass([self class]), error.localizedDescription);
            if (completionHandler) completionHandler(nil);
            return;
        }
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
        VBBDepatureParser *departureParser = [[VBBDepatureParser alloc] initWithStationId:stationId];
        parser.delegate = departureParser;
        [parser parse];

        if (completionHandler) completionHandler(station);
    }];
    [task resume];
}

+(CNPostalAddressFormatter *)addressFormatter {
    static dispatch_once_t pred;
    static CNPostalAddressFormatter *formatter;
    dispatch_once(&pred, ^{
        formatter = [CNPostalAddressFormatter new];
    });
    return formatter;
}

+ (NSOperationQueue *)operationQueue {
    static dispatch_once_t onceToken;
    static NSOperationQueue *operationQueue;
    
    dispatch_once(&onceToken, ^{
        dispatch_queue_t queue = dispatch_queue_create("com.obrhoff.vbbnow", DISPATCH_QUEUE_SERIAL);
        operationQueue = [NSOperationQueue new];
        operationQueue.maxConcurrentOperationCount = 1;
        operationQueue.qualityOfService = NSQualityOfServiceDefault;
        operationQueue.underlyingQueue = queue;
    });
    return operationQueue;
}

@end

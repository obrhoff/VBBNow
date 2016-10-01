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

#import "VBBNetworkManager.h"

@interface VBBNetworkManager ()

@property (nonatomic, readwrite, strong) NSURLSession *session;

@end

@implementation VBBNetworkManager

-(instancetype)init {
    self = [super init];
    if (self) {
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        self.session.delegateQueue.underlyingQueue = [VBBPersistanceManager manager].operationQueue.underlyingQueue;
    }
    return self;
}

-(void)fetchNearedStations:(CLLocation*)location andCompletionHandler:(void (^)(NSArray *stations, VBBLocation *location))completionHandler{
    
    [[VBBPersistanceManager manager] trim];

    NSNumber *latitude = @(location.coordinate.latitude * 1000000);
    NSNumber *longitude = @(location.coordinate.longitude * 1000000);
    
    NSMutableArray *query = [NSMutableArray array];
    [query addObject:[NSURLQueryItem queryItemWithName:@"performLocating" value:@"2"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"L" value:@"vs_java"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"look_x" value:longitude.stringValue]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"look_y" value:latitude.stringValue]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"look_maxdist" value:@"25000"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"look_maxno" value:@"10"]];
    
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"http";
    components.host = @"fahrinfo.vbb.de";
    components.path = @"/bin/query.exe/dol";
    components.queryItems = query.copy;
    
    void (^ requestBlock)(VBBLocation *stationLocation) = ^void (VBBLocation *stationLocation) {
        NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];
        NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError * error) {
            if (error) {
                NSLog(@"%@: %@", NSStringFromClass([self class]), error.localizedDescription);
                if (completionHandler) completionHandler(nil, stationLocation);
                return;
            }
            NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
            VBBStationParser *stationParser = [VBBStationParser new];
            parser.delegate = stationParser;
            [parser parse];
            [self fetchDeparturesFromStations:stationParser.stations andCompletionHandler:^(NSArray *stations) {
                if (completionHandler) completionHandler(stations, stationLocation);
            }];
        }];
        [task resume];
    };

    VBBLocation *storedLocation = [VBBPersistanceManager manager].storedLocation;
    if (storedLocation && !location) {
        requestBlock(storedLocation);
    } else if (location) {
        CLGeocoder *geocoder = [CLGeocoder new];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = placemarks.firstObject;
            VBBLocation *stationLocation = [VBBLocation new];
            stationLocation.location = location;
            stationLocation.address = [placemark.addressDictionary[@"FormattedAddressLines"] componentsJoinedByString:@", "];
            stationLocation.date = [NSDate new];
            [[VBBPersistanceManager manager] storeLocation:stationLocation];
            requestBlock(stationLocation);
        }];
    } else {
        if (completionHandler) completionHandler(nil, nil);
    }
}

-(void)fetchDeparturesFromStations:(NSArray*)stations andCompletionHandler:(void (^)(NSArray *stations))completionHandler {
    
    __block NSUInteger count = stations.count;
    void (^responseBlock)(VBBStation *station) = ^void(VBBStation *station) {
        if (--count) return;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) completionHandler(stations);
        });
    };
    for (VBBStation *station in stations) [self fetchDepature:station andCompletionHandler:responseBlock];
    
}

-(void)fetchDepature:(VBBStation *)station andCompletionHandler:(void (^)(VBBStation *station))completionHandler{
    
    NSString *stationId = station.stationId.copy;
    
    NSMutableArray *query = [NSMutableArray array];
    [query addObject:[NSURLQueryItem queryItemWithName:@"boardType" value:@"yes"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"disableEquivs" value:@"yes"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"maxJourneys" value:@"50"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"L" value:@"vs_java3"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"start" value:@"yes"]];
    [query addObject:[NSURLQueryItem queryItemWithName:@"input" value:station.stationId]];
    
    NSURLComponents *components = [NSURLComponents new];
    components.scheme = @"http";
    components.host = @"fahrinfo.vbb.de";
    components.path = @"/bin/stboard.exe/dn";
    components.queryItems = query.copy;
    NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];
    
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
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

@end

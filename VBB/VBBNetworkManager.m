//
//  VBBNetworkManager.m
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBNetworkManager.h"
#import <AFNetworking/AFNetworking.h>

@interface VBBNetworkManager ()

@property (nonatomic, readonly, strong) AFHTTPSessionManager *manager;

@end

@implementation VBBNetworkManager

-(void)fetchNearedStations:(CLLocation*)location andCompletionHandler:(void (^)(NSArray *stations))completionHandler{
    
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
    
    NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];
    
    NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, NSXMLParser *parser, NSError *error) {
        if (error) {
            NSLog(@"%@: %@", NSStringFromClass([self class]), error.localizedDescription);
            return;
        }
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            VBBStationParser *stationParser = [VBBStationParser new];
            parser.delegate = stationParser;
            [parser parse];
            [self fetchDeparturesFromStations:stationParser.stations andCompletionHandler:completionHandler];
        }];
        [[VBBPersistanceManager manager].operationQueue addOperation:operation];
    }];

    [task resume];
    
}

-(void)fetchDeparturesFromStations:(NSArray*)stations andCompletionHandler:(void (^)(NSArray *stations))completionHandler {
    
    __block NSUInteger count = stations.count;
    void (^responseBlock)(VBBStation *station, BOOL completed) = ^void(VBBStation *station, BOOL completed) {
        count--;
        if (!count && completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(stations);
            });
        }
    };
    for (VBBStation *station in stations) [self fetchDepature:station andCompletionHandler:responseBlock];
    
}

-(void)fetchDepature:(VBBStation *)station andCompletionHandler:(void (^)(VBBStation *station, BOOL completed))completionHandler{
    
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
    
    NSURLSessionDataTask *task = [self.manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, NSXMLParser *parser, NSError *error) {
        if (error) {
            NSLog(@"%@: %@", NSStringFromClass([self class]), error.localizedDescription);
            if (completionHandler) completionHandler(station, YES);
            return;
        }
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            VBBDepatureParser *departureParser = [[VBBDepatureParser alloc] initWithStationId:stationId];
            parser.delegate = departureParser;
            [parser parse];
            if (completionHandler) completionHandler(station, YES);
        }];
        [[VBBPersistanceManager manager].operationQueue addOperation:operation];

    }];
    
    [task resume];
    
}

-(AFHTTPSessionManager*)manager {
    static dispatch_once_t onceToken;
    static AFHTTPSessionManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/xml", nil];
        manager.completionQueue = [VBBPersistanceManager manager].operationQueue.underlyingQueue;
    });
    return manager;
}

+ (VBBNetworkManager *)manager {
    static dispatch_once_t pred;
    static VBBNetworkManager *manager;
    dispatch_once(&pred, ^{
        manager = [self new];
    });
    return manager;
}

@end

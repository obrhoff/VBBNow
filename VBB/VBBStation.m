//
//  VBBStation.m
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBStation.h"
#import "VBBPersistanceManager.h"

@interface VBBStation ()

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end

@implementation VBBStation

+ (NSArray *)sortByRelevance:(CLLocation*)userLocation andLimit:(NSUInteger)limit {
    
    RLMRealm *realm = [[VBBPersistanceManager class] createRealm];
    RLMResults *stations = [VBBStation allObjectsInRealm:realm];
    
    NSDate *now = [NSDate date];
    NSMutableArray *unsorted = [NSMutableArray arrayWithCapacity:stations.count];
    for (VBBStation *station in stations) {
        if (!station.depatures.count) continue;
        CLLocationDistance distance = [userLocation distanceFromLocation:station.location];
        NSDictionary *dict = @{@"station": station, @"distance": @(distance)};
        [unsorted addObject:dict];
    }
    [unsorted sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(NSDictionary *dictOne, NSDictionary *dictTwo) {
        return [dictOne[@"distance"] doubleValue] > [dictTwo[@"distance"] doubleValue];
    }];
    
    NSDate *future = [NSDate dateWithTimeInterval:60 sinceDate:now];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"arrivalDate > %@", future];
    [unsorted enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        VBBStation *station = dict[@"station"];
        VBBDepature *nextDepature = [station.depatures objectsWithPredicate:predicate].firstObject;
        if (!nextDepature || [nextDepature.arrivalDate timeIntervalSinceDate:now] > 3600) [unsorted removeObject:dict];
    }];
    if (limit < unsorted.count) [unsorted removeObjectsInRange:NSMakeRange(limit, unsorted.count - limit)];
    
    NSMutableArray *sortByRelevance = [NSMutableArray arrayWithCapacity:stations.count];
    [unsorted enumerateObjectsUsingBlock:^(NSDictionary *placeDict, NSUInteger idx, BOOL *stop) {
        [sortByRelevance insertObject:placeDict[@"station"] atIndex:idx];
    }];
    return sortByRelevance.copy;
}

-(void)setLocation:(CLLocation *)location {
    self.latitude = location.coordinate.latitude;
    self.longitude = location.coordinate.longitude;
}

-(CLLocation *)location {
    return [[CLLocation alloc] initWithLatitude:self.latitude longitude:self.longitude];
}

+ (NSDictionary *)defaultPropertyValues{
    return @{ @"stationName": @"", @"stationId": @"", @"stationType": @""};
}

+ (NSString *)primaryKey {
    return NSStringFromSelector(@selector(stationId));
}

@end

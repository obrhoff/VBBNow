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

+ (NSArray *)sortByDistance:(CLLocation*)userLocation andLimit:(NSUInteger)limit {
    
    RLMRealm *realm = [[VBBPersistanceManager class] createRealm];
    RLMResults *stations = [VBBStation allObjectsInRealm:realm];
    
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
    
    NSDate *future = [NSDate dateWithTimeInterval:180 sinceDate:[NSDate date]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"arrivalDate > %@", future];
    [unsorted enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        VBBStation *station = dict[@"station"];
        VBBDepature *nextDepature = [station.depatures objectsWithPredicate:predicate].firstObject;
        if (!nextDepature) [unsorted removeObject:dict];
    }];
    if (limit < unsorted.count) [unsorted removeObjectsInRange:NSMakeRange(limit, unsorted.count - limit)];
    /*
    [unsorted sortWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(NSDictionary *dictOne, NSDictionary *dictTwo) {
        NSDate *future = [NSDate dateWithTimeInterval:180 sinceDate:[NSDate date]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"arrivalDate > %@", future];
        VBBStation *station = dictOne[@"station"];
        VBBStation *comparesStation = dictTwo[@"station"];
        VBBDepature *departure = [station.depatures objectsWithPredicate:predicate].firstObject;
        VBBDepature *compareDeparture = [comparesStation.depatures objectsWithPredicate:predicate].firstObject;
        return [departure.arrivalDate timeIntervalSinceDate:future] > [compareDeparture.arrivalDate timeIntervalSinceDate:future];
    }]; */
    
    NSMutableArray *sortByDistance = [NSMutableArray arrayWithCapacity:stations.count];
    [unsorted enumerateObjectsUsingBlock:^(NSDictionary *placeDict, NSUInteger idx, BOOL *stop) {
        [sortByDistance insertObject:placeDict[@"station"] atIndex:idx];
    }];
    return sortByDistance.copy;
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

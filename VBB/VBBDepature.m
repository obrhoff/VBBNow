//
//  VBBDepature.m
//  bvg
//
//  Created by Dennis Oberhoff on 29/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBDepature.h"
#import "VBBStation.h"

@implementation VBBDepature

-(RLMObject *)station {
    return [self linkingObjectsOfClass:NSStringFromClass([VBBStation class]) forProperty:NSStringFromSelector(@selector(depatures))].firstObject;
}

+ (NSDictionary *)defaultPropertyValues {
    return @{@"arrivalName": @"",
             @"directionName": @"",
             @"departureType": @"",
             @"arrivalDate": [NSDate dateWithTimeIntervalSince1970:0]};
}

@end

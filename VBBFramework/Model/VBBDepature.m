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

-(BOOL)delayed {
    return self.delay > 0;
}

-(NSDate *)arrivalDate {
    return [self.scheduledDate dateByAddingTimeInterval:self.delay];
}

+ (NSDictionary<NSString *,RLMPropertyDescriptor *> *)linkingObjectsProperties {
    return @{NSStringFromSelector(@selector(station)): [RLMPropertyDescriptor descriptorWithClass:VBBStation.class
                                                                                     propertyName:NSStringFromSelector(@selector(depatures))] };
}

+ (NSString *)primaryKey {
    return NSStringFromSelector(@selector(departureId));
}

@end

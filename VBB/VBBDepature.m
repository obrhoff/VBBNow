//
//  VBBDepature.m
//  bvg
//
//  Created by Dennis Oberhoff on 29/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBDepature.h"

@implementation VBBDepature

+ (NSDictionary *)defaultPropertyValues {
    return @{@"arrivalName": @"",
             @"directionName": @"",
             @"departureType": @"",
             @"arrivalDate": [NSDate dateWithTimeIntervalSince1970:0]};
}

@end

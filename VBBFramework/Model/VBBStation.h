//
//  VBBStation.h
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

@import Realm;

#import "VBBDepature.h"
#import "VBBLine.h"
#import "VBBLocation.h"

@import CoreLocation;

@interface VBBStation : RLMObject

@property (nonatomic) NSString *stationName;
@property (nonatomic) NSString *stationId;
@property (nonatomic) NSInteger stationClass;
@property (nonatomic) NSString *stationType;

@property (readonly) CLLocation *location;

@property RLMArray <VBBDepature> *depatures;
@property RLMArray <VBBLine> *lines;

-(void)setLocation:(CLLocation*)location;
-(CLLocation*)location;
+ (NSArray *)sortByRelevance:(VBBLocation*)userLocation andLimit:(NSUInteger)limit;

@end

RLM_ARRAY_TYPE(VBBStation)

//
//  VBBStation.h
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import <Realm/Realm.h>
#import "VBBDepature.h"

@import CoreLocation;

@interface VBBStation : RLMObject

@property (nonatomic) NSString *stationName;
@property (nonatomic) NSString *stationId;
@property (nonatomic) NSInteger stationClass;
@property (nonatomic) NSString *stationType;

@property (readonly) CLLocation *location;
@property RLMArray <VBBDepature> *depatures;

-(void)setLocation:(CLLocation*)location;
-(CLLocation*)location;
+(NSArray *)sortByDistance:(CLLocation*)userLocation andLimit:(NSUInteger)limit;

@end

RLM_ARRAY_TYPE(VBBStation)

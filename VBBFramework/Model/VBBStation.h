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

@property(nonatomic, nonnull) NSString *stationName;
@property(nonatomic, nonnull) NSString *stationId;
@property(nonatomic, nonnull) NSString *stationType;
@property(nonatomic) NSInteger stationClass;

@property(nonnull, readonly) CLLocation *location;

@property(nonnull) RLMArray<VBBDepature> *depatures;
@property(nonnull) RLMArray<VBBLine> *lines;

+ (NSArray <VBBStation*>* _Nonnull)sortByRelevance:(VBBLocation* _Nonnull)userLocation andLimit:(NSUInteger)limit;

- (VBBDepature* _Nullable)nextDeparture: (NSTimeInterval)futureInterval;
- (void)setLocation:(CLLocation * _Nonnull)location;
- (CLLocation * _Nonnull)location;

@end

RLM_ARRAY_TYPE(VBBStation)

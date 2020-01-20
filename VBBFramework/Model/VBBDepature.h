//
//  VBBDepature.h
//  bvg
//
//  Created by Dennis Oberhoff on 29/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

@import Realm;

#import "VBBLine.h"

@interface VBBDepature : RLMObject

@property(nonatomic, nullable) VBBLine *line;
@property(nonatomic, nonnull) NSString *departureId;
@property(nonatomic, nonnull) NSDate *scheduledDate;
@property(nonatomic, assign) NSTimeInterval delay;
@property(nonatomic, readonly, nonnull) NSDate *arrivalDate;
@property(nonatomic, readonly, assign) BOOL delayed;

@property(readonly, nonnull) RLMLinkingObjects<RLMObject *> *station;

@end

RLM_ARRAY_TYPE(VBBDepature)

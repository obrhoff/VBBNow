//
//  VBBDirection.h
//  VBB
//
//  Created by Dennis Oberhoff on 01/02/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import <Realm/Realm.h>

typedef NS_ENUM (NSInteger, VBBLineType) {
    VBBLineTypeSBahn = 1,
    VBBLineTypeUBahn = 2,
    VBBLineTypeTram = 4,
    VBBLineTypeBus = 8,
    VBBLineTypeMetro = 12,
    VBBLineTypeBahn = 32,
};

@interface VBBLine : RLMObject

@property(readonly, nonnull) RLMLinkingObjects<RLMObject *> *departures;
@property(nonatomic, nonnull) NSString *lineId;
@property(nonatomic, nonnull) NSString *lineEnd;
@property(nonatomic, nonnull) NSString *lineName;
@property(nonatomic) NSInteger departureType;

-(VBBLineType)lineType;
+(NSString* _Nonnull)assetNameForType:(VBBLineType)lineType;

@end

RLM_ARRAY_TYPE(VBBLine)

//
//  VBBDirection.h
//  VBB
//
//  Created by Dennis Oberhoff on 01/02/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import <Realm/Realm.h>

@interface VBBLine : RLMObject

@property (nonatomic) NSString *lineId;
@property (nonatomic) NSString *lineEnd;
@property (nonatomic) NSString *lineName;
@property (nonatomic) NSInteger departureType;

@end

RLM_ARRAY_TYPE(VBBLine)

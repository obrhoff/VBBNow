//
//  VBBDepature.h
//  bvg
//
//  Created by Dennis Oberhoff on 29/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import <Realm/Realm.h>

@interface VBBDepature : RLMObject

@property (nonatomic) NSDate *arrivalDate;
@property (nonatomic) NSString* arrivalName;
@property (nonatomic) NSString* directionName;
@property (nonatomic) NSInteger departureType;

@end
RLM_ARRAY_TYPE(VBBDepature)

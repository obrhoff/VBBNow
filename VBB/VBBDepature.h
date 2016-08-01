//
//  VBBDepature.h
//  bvg
//
//  Created by Dennis Oberhoff on 29/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import <Realm/Realm.h>
#import "VBBLine.h"

@interface VBBDepature : RLMObject

@property (nonatomic) NSDate *arrivalDate;
@property (readonly) RLMLinkingObjects<RLMObject *> *station;
@property (nonatomic) VBBLine *line;

@end

RLM_ARRAY_TYPE(VBBDepature)

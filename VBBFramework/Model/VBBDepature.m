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

+(NSDictionary<NSString *,RLMPropertyDescriptor *> *)linkingObjectsProperties {
    return [NSDictionary dictionaryWithObject:[RLMPropertyDescriptor descriptorWithClass:VBBStation.class propertyName:NSStringFromSelector(@selector(depatures))] forKey:NSStringFromSelector(@selector(station))];
}


@end

//
//  VBBDirection.m
//  VBB
//
//  Created by Dennis Oberhoff on 01/02/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBLine.h"

@implementation VBBLine

-(BOOL)isEqual:(VBBLine*)object {
    return ([object isKindOfClass:[self class]]) ? ([self.lineEnd isEqualToString:object.lineEnd] &&
                                                    [self.lineName isEqualToString:object.lineName]) : [super isEqual:object];
}

+(NSString *)primaryKey {
    return NSStringFromSelector(@selector(lineId));
}

@end

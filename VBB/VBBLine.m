//
//  VBBDirection.m
//  VBB
//
//  Created by Dennis Oberhoff on 01/02/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBLine.h"

@implementation VBBLine

-(BOOL)isEqual:(id)object {

    #warning this seems be necessary since directionIds are not unique
    if (![object isKindOfClass:[self class]]) return [super isEqual:object];
    VBBLine *compareDirection = object;
    return ([self.lineEnd isEqualToString:compareDirection.lineEnd] &&
            [self.lineName isEqualToString:compareDirection.lineName]);

}

+(NSString *)primaryKey {
    return NSStringFromSelector(@selector(lineId));
}

+(NSDictionary *)defaultPropertyValues {
    return @{@"lineId": @"", @"lineName": @"",  @"lineEnd": @""};
}

@end

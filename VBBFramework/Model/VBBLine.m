//
//  VBBDirection.m
//  VBB
//
//  Created by Dennis Oberhoff on 01/02/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBLine.h"
#import "VBBDepature.h"

@implementation VBBLine

- (BOOL)isEqual:(VBBLine *)object {
    return ([object isKindOfClass:[self class]]) ? ([self.lineEnd isEqualToString:object.lineEnd] &&
            [self.lineName isEqualToString:object.lineName]) : [super isEqual:object];
}

-(VBBLineType)lineType {
    VBBLineType lineType = (VBBLineType) self.departureType;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^Bus M\\d+"];
    if ([predicate evaluateWithObject:self.lineName]) {
        return VBBLineTypeMetro;
    }
    return lineType;
}

+(NSString*)assetNameForType:(VBBLineType)lineType; {
    switch (lineType) {
        case VBBLineTypeSBahn:
            return @"SBahn";
        case VBBLineTypeUBahn:
            return @"UBahn";
        case VBBLineTypeTram:
            return @"Tram";
        case VBBLineTypeBus:
            return @"Bus";
        case VBBLineTypeMetro:
            return @"Metro";
        case VBBLineTypeBahn:
            return @"Train";
    }
}

+ (NSString *)primaryKey {
    return NSStringFromSelector(@selector(lineId));
}

+ (NSDictionary<NSString *,RLMPropertyDescriptor *> *)linkingObjectsProperties {
    return @{NSStringFromSelector(@selector(departures)): [RLMPropertyDescriptor descriptorWithClass:VBBDepature.class
                                                                                     propertyName:NSStringFromSelector(@selector(line))] };
}

@end

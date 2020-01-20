//
//  VBBLocation.m
//  VBB
//
//  Created by Dennis Oberhoff on 01/08/16.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

@import MapKit;


#import "VBBLocation.h"

@implementation VBBLocation

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    VBBLocation *location = [VBBLocation new];
    location.location = [aDecoder decodeObjectForKey:@"location"];
    location.address = [aDecoder decodeObjectForKey:@"address"];
    location.date = [aDecoder decodeObjectForKey:@"date"];
    return location;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.location forKey:@"location"];
    [coder encodeObject:self.date forKey:@"date"];
    [coder encodeObject:self.address forKey:@"address"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (BOOL)isEqual:(VBBLocation *)object {
    if ([object isKindOfClass:[self class]]) return NO;
    MKMapPoint this = MKMapPointForCoordinate(self.location.coordinate);
    MKMapPoint other = MKMapPointForCoordinate(object.location.coordinate);
    return MKMapPointEqualToPoint(this, other);
}


@end

//
//  VBBLocation.h
//  VBB
//
//  Created by Dennis Oberhoff on 01/08/16.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

@import CoreLocation;
@import Contacts;

@interface VBBLocation : NSObject <NSSecureCoding>

@property(nonatomic, readwrite, strong, nullable) CLLocation *location;
@property(nonatomic, readwrite, strong, nullable) NSString *address;
@property(nonatomic, readwrite, strong, nullable) NSDate *date;

@end

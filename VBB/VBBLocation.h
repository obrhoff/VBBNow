//
//  VBBLocation.h
//  VBB
//
//  Created by Dennis Oberhoff on 01/08/16.
//  Copyright © 2016 Dennis Oberhoff. All rights reserved.
//

@import CoreLocation;
@import Contacts;

@interface VBBLocation : NSObject <NSCoding>

@property (nonatomic, readwrite, strong) CLLocation *location;
@property (nonatomic, readwrite, strong) NSString *address;
@property (nonatomic, readwrite, strong) NSDate *date;

@end

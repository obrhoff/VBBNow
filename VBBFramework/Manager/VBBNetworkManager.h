//
//  VBBNetworkManager.h
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

@import CoreLocation;
#import "VBBLocation.h"

@interface VBBNetworkManager : NSObject

-(void)fetchNearedStations:(CLLocation*)location andCompletionHandler:(void (^)(NSArray *stations, VBBLocation *location))completionHandler;

@end

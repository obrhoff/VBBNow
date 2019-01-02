//
//  VBBPersistanceManager.h
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

@import Foundation;
@import CoreLocation;
@import Realm;

#import "VBBLocation.h"

@interface VBBPersistanceManager : NSObject

@property (nonatomic, readonly) NSOperationQueue *operationQueue;

-(void)trim;
-(VBBLocation*)storedLocation;
-(void)storeLocation:(VBBLocation*)location;
+(VBBPersistanceManager *)manager;
+(RLMRealm*)realm;

@end

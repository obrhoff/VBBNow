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

@property(class, readonly, strong, nonnull) VBBPersistanceManager *manager;
@property(class, readonly, strong, nonnull) RLMRealm *realm;

@property(nonatomic, readonly, nonnull) NSOperationQueue *operationQueue;
@property(nonatomic, nullable) VBBLocation *storedLocation;

+ (void)trim;

@end

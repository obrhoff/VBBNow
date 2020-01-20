//
//  VBBNetworkManager.h
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

@import CoreLocation;
@import Realm;

#import "VBBLocation.h"
#import "VBBStation.h"


typedef NS_ENUM (NSInteger, VBBNetworkStatus) {
    VBBNetworkStatusFinished = 0,
    VBBNetworkStatusGeocoding = 1,
    VBBNetworkStatusLoading = 2,
    VBBNetworkStatusLoadingDetails = 3,
    VBBNetworkStatusFailed = 4,
};

@interface VBBNetworkManager : NSObject

@property(nonatomic, readonly, assign) VBBNetworkStatus status;

- (void)fetchNearedStations:(CLLocation * _Nonnull)location
       andCompletionHandler:(void (^ _Nonnull)(NSArray <VBBStation*> * _Nullable stations, VBBLocation * _Nullable location))completionHandler;
@end

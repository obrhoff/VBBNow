//
//  VBBPersistanceManager.m
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBPersistanceManager.h"
#import "VBBDepature.h"


@interface VBBPersistanceManager ()

@property (nonatomic, readonly) dispatch_queue_t backgroundQueue;

@end

@implementation VBBPersistanceManager

- (void)trim {
    RLMRealm *realm = [[self class] createRealm];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"arrivalDate < %@", [NSDate date]];
    RLMResults *oldDates = [VBBDepature objectsInRealm:realm withPredicate:predicate];
    
    [realm beginWriteTransaction];
    [realm deleteObjects:oldDates];
    [realm commitWriteTransaction];
}

- (void)storeLocation:(VBBLocation *)location {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:location];
    
    [defaults setObject:data forKey:@"savedLocation"];
    [defaults synchronize];
}

- (VBBLocation *)storedLocation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults dataForKey:@"savedLocation"];
    VBBLocation *location = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return location;
}

+ (RLMRealm *)createRealm {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    
    documentPath = [documentPath stringByAppendingPathComponent:[NSBundle mainBundle].bundleIdentifier];
    NSString *realmFileName = [documentPath stringByAppendingPathComponent:@"stations.realm"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory;
    if (![fileManager fileExistsAtPath:documentPath isDirectory:&isDirectory]) {
        [fileManager createDirectoryAtPath:documentPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSURL *url = [NSURL URLWithString:realmFileName];
    
    RLMRealm *realm = [RLMRealm realmWithURL:url];
    return realm;
}

- (NSOperationQueue *)operationQueue {
    static dispatch_once_t onceToken;
    static NSOperationQueue *operationQueue;
    
    dispatch_once(&onceToken, ^{
        operationQueue = [NSOperationQueue new];
        operationQueue.maxConcurrentOperationCount = 1;
        operationQueue.qualityOfService = NSQualityOfServiceBackground;
        operationQueue.underlyingQueue = self.backgroundQueue;
    });
    return operationQueue;
}

- (dispatch_queue_t)backgroundQueue {
    static dispatch_once_t queueCreationGuard;
    static dispatch_queue_t backgroundQueue;
    
    dispatch_once(&queueCreationGuard, ^{
        backgroundQueue = dispatch_queue_create("com.obrhoff.background", DISPATCH_QUEUE_CONCURRENT);
    });
    return backgroundQueue;
}

+ (VBBPersistanceManager *)manager {
    static dispatch_once_t pred;
    static VBBPersistanceManager *manager;
    
    dispatch_once(&pred, ^{
        manager = [self new];
    });
    return manager;
}

@end

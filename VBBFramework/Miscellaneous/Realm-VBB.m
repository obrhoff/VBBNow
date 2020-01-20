//
//  BB.m
//  BicycleFramework-WatchOS
//
//  Created by Dennis Oberhoff on 23.07.19.
//  Copyright © 2019 Dennis Oberhoff. All rights reserved.
//

@import Foundation;

#import "Realm-VBB.h"

@implementation RLMResults (VBB)

-(NSArray* _Nonnull)mapItems {
    NSMutableArray *array = [NSMutableArray new];
    for (RLMObject *item in self) {
        [array addObject:item];
    }

    return array.copy;
}

@end

@implementation RLMArray (VBB)

-(NSArray* _Nonnull)mapItems {
    NSMutableArray *array = [NSMutableArray new];
    for (RLMObject *item in self) {
        [array addObject:item];
    }

    return array.copy;
}

@end



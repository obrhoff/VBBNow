//
//  NSBundle.m
//  VBB
//
//  Created by Dennis Oberhoff on 02.08.19.
//  Copyright © 2019 Dennis Oberhoff. All rights reserved.
//

#import "NSBundle+VBB.h"

@interface BundleClass : NSObject
@end

@implementation BundleClass
@end

@implementation NSBundle (VBB)

+(NSBundle* _Nonnull)frameworkBundle {
    return [NSBundle bundleForClass:[BundleClass class]];
}

@end

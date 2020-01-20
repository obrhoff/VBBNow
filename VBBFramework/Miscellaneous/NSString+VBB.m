//
//  NSString+VBB.m
//  VBBFramework
//
//  Created by Dennis Oberhoff on 19.06.19.
//  Copyright © 2019 Dennis Oberhoff. All rights reserved.
//

#import "NSString+VBB.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (VBB)

- (NSString *)sha1 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}
@end

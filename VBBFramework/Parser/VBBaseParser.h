//
//  BVGBaseParser.h
//  bvg
//
//  Created by Dennis Oberhoff on 29/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

@import Realm;
@import Foundation;
#import "VBBPersistanceManager.h"

@interface VBBaseParser : NSObject <NSXMLParserDelegate>

@property(nonatomic, readonly, strong) RLMRealm *realm;

@end

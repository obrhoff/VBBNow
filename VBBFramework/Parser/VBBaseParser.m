//
//  BVGBaseParser.m
//  bvg
//
//  Created by Dennis Oberhoff on 29/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBaseParser.h"

@interface VBBaseParser()

@property (nonatomic, readwrite, strong) RLMRealm *realm;

@end

@implementation VBBaseParser

-(instancetype)init{
    self = [super init];
    if (self) {
        self.realm = [[VBBPersistanceManager class] realm];
    }
    return self;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    [self.realm beginWriteTransaction];
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.realm commitWriteTransaction];
}

@end

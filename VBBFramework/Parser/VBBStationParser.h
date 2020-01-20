//
//  VBBStationParser.h
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBaseParser.h"
#import "VBBStation.h"

@interface VBBStationParser : VBBaseParser

@property(nonatomic, readonly, strong) NSArray *stations;

@end
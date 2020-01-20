//
//  Bla.m
//  VBBFramework
//
//  Created by Dennis Oberhoff on 16.06.19.
//  Copyright © 2019 Dennis Oberhoff. All rights reserved.
//

#import "NSDateComponentsFormatter+VBB.h"

@implementation NSDateComponentsFormatter (BB)

+(NSDateComponentsFormatter *)timeFormatter {
    static dispatch_once_t onceToken;
    static NSDateComponentsFormatter *timeFormatter;
    dispatch_once(&onceToken, ^{
        timeFormatter = [NSDateComponentsFormatter new];
        timeFormatter.allowedUnits = NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay;
        timeFormatter.unitsStyle = NSDateComponentsFormatterUnitsStyleShort;
        timeFormatter.includesApproximationPhrase = NO;
        timeFormatter.includesTimeRemainingPhrase = NO;
        timeFormatter.collapsesLargestUnit = YES;
        timeFormatter.maximumUnitCount = 1;
    });
    return timeFormatter;
}

@end

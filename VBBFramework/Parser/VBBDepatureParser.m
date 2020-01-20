//
//  VBBDepatureParser.m
//  bvg
//
//  Created by Dennis Oberhoff on 29/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBDepatureParser.h"
#import "NSString+VBB.h"

@interface VBBDepatureParser ()

@property(nonatomic, readwrite, strong) VBBStation *station;
@property(nonatomic, readonly) NSDateFormatter *formatter;

@end

@implementation VBBDepatureParser

- (instancetype)initWithStationId:(NSString *)stationId {
    self = [super init];
    if (self) {
        self.station = [VBBStation objectInRealm:self.realm forPrimaryKey:stationId];
    }
    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    [super parserDidStartDocument:parser];
}

- (void)parseTable:(NSDictionary *)dict {
    NSString *directionId = dict[@"dirnr"];
    NSString *direction = dict[@"dir"];
    NSString *lineKey = [NSString stringWithFormat:@"%@-%@", directionId, direction];
    NSString *lineId = lineKey.sha1;
    
    VBBLine *line = [VBBLine objectInRealm:self.realm forPrimaryKey:lineId];
    if (!line) {
        line = [VBBLine new];
        line.lineId = lineId;
    }

    line.lineEnd = dict[@"dir"];
    line.lineName = dict[@"hafasname"];
    line.departureType = [dict[@"class"] integerValue];
    [self.realm addOrUpdateObject:line];

    if ([self.station.lines indexOfObject:line] == NSNotFound) {
        [self.station.lines addObject:line];
    }
    
    NSString * dateFormatted = [NSString stringWithFormat:@"%@ %@", dict[@"fpDate"], dict[@"fpTime"]];
    NSDate *scheduledDate = [self.formatter dateFromString:dateFormatted];
    NSString *departureKey = [NSString stringWithFormat:@"%@-%@-%@-%@", self.station.stationId, line.lineId, line.lineEnd, dateFormatted];
    NSString *departureId = departureKey.sha1;
    NSNumber *delay = dict[@"e_delay"];
    
    
    VBBDepature *departure = [VBBDepature objectInRealm:self.realm forPrimaryKey:departureId];
    
    if (!departure) {
        departure = [VBBDepature new];
        departure.departureId = departureId;
    }
    
    departure.scheduledDate = scheduledDate;
    departure.delay = delay.doubleValue * 60;
    departure.line = line;
    
    [self.realm addOrUpdateObject:departure];

    if ([self.station.depatures indexOfObject:departure] == NSNotFound) {
        [self.station.depatures addObject:departure];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    if ([elementName isEqualToString:@"Journey"]) [self parseTable:attributeDict];

}

- (NSDateFormatter *)formatter {
    static dispatch_once_t onceToken;
    static NSDateFormatter *formatter;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"dd.MM.yy HH:mm";
        formatter.timeZone = [NSTimeZone timeZoneWithName:@"Europe/Berlin"];
    });
    return formatter;
}

@end

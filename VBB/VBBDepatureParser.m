//
//  VBBDepatureParser.m
//  bvg
//
//  Created by Dennis Oberhoff on 29/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBDepatureParser.h"

@interface VBBDepatureParser ()

@property (nonatomic, readwrite, strong) VBBStation *station;
@property (nonatomic, readonly) NSDateFormatter *formatter;

@end

@implementation VBBDepatureParser

-(instancetype)initWithStationId:(NSString*)stationId {
    self = [super init];
    if (self) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stationId == %@", stationId];
        self.station = [VBBStation objectsInRealm:self.realm withPredicate:predicate].firstObject;
    }
    return self;
}

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    [super parserDidStartDocument:parser];
    [self.realm deleteObjects:self.station.depatures];
}

-(void)parseTable:(NSDictionary*)dict {
    
    VBBDepature *departure = [VBBDepature new];
    NSString *lineId = dict[@"dirnr"];
    NSPredicate *directionPredicate = [NSPredicate predicateWithFormat:@"lineId == %@", lineId];
    VBBLine *line = [VBBLine objectsInRealm:self.realm withPredicate:directionPredicate].firstObject;
    if (!line) {
        line = [VBBLine new];
        line.lineId = lineId;
        line.lineEnd = dict[@"dir"];
        line.lineName = dict[@"hafasname"];
        line.departureType = [dict[@"class"] integerValue];
        [self.realm addObject:line];
    }
    if ([self.station.lines indexOfObject:line] == NSNotFound) [self.station.lines addObject:line];
    
    NSString *dateFormatted = [NSString stringWithFormat:@"%@ %@", dict[@"fpDate"], dict[@"fpTime"]];
    departure.arrivalDate = [self.formatter dateFromString:dateFormatted];
    departure.line = line;
    [self.station.depatures addObject:departure];
    
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    if ([elementName isEqualToString:@"Journey"]) [self parseTable:attributeDict];

}

-(NSDateFormatter*)formatter {
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

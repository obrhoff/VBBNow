//
//  VBBStationParser.m
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBStationParser.h"

@interface VBBStationParser ()

@property (nonatomic, readwrite, strong) NSMutableArray *fetchedStations;

@end

@implementation VBBStationParser

-(void)parserDidStartDocument:(NSXMLParser *)parser {
    self.fetchedStations = [NSMutableArray array];
    [super parserDidStartDocument:parser];
}

-(void)parseStations:(NSDictionary*)dict {
    
    NSString *stationId = dict[@"externalId"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stationId == %@", stationId];
    VBBStation *station = [VBBStation objectsInRealm:self.realm withPredicate:predicate].firstObject;
    if (!station) {
        NSNumber *latitude = @([dict[@"y"] doubleValue] / 1000000);
        NSNumber *longitude = @([dict[@"x"] doubleValue] / 1000000);
        station = [VBBStation new];
        station.stationName = dict[@"n"];
        station.stationId = stationId;
        station.stationClass = [dict[@"class"] integerValue];
        station.stationType = dict[@"t"];
        station.location = [[CLLocation alloc] initWithLatitude:latitude.doubleValue longitude:longitude.doubleValue];
        [self.realm addOrUpdateObject:station];
    }
    [self.fetchedStations addObject:station];

}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
 namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    if ([elementName isEqualToString:@"MLc"]) [self parseStations:attributeDict];

}

-(NSArray *)stations{
    return self.fetchedStations.copy;
}

@end

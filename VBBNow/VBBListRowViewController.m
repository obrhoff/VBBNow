//
//  VBBListRowViewController.m
//  today
//
//  Created by Dennis Oberhoff on 30/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "VBBListRowViewController.h"
#import "VBBStation.h"

#import <FormatterKit/TTTTimeIntervalFormatter.h>

@interface VBBListRowViewController ()

@property (nonatomic, readwrite, strong) CALayer *seperatorLayer;

@end

@implementation VBBListRowViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.seperatorLayer = [CALayer new];
    [self.view setWantsLayer:YES];
    [self.view.layer addSublayer:self.seperatorLayer];
}

-(void)viewDidLayout {
    self.seperatorLayer.frame =  CGRectMake(CGRectGetMaxX(self.timeLabel.frame), CGRectGetMinY(self.stationLabel.frame),
                                            2.5, CGRectGetMinY(self.timeLabel.frame) + CGRectGetMaxY(self.timeDescLabel.frame));
}

-(void)setInformations: (VBBStation *)station {
    
    NSDate *future = [NSDate dateWithTimeInterval:60 sinceDate:[NSDate date]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"arrivalDate > %@", future];
    VBBDepature *nextDepature = [station.depatures objectsWithPredicate:predicate].firstObject;
    NSTimeInterval left = [nextDepature.arrivalDate timeIntervalSinceDate:[NSDate date]];
    
    
    NSArray *timeDescriptions = [[[self timeFormatter] stringForTimeInterval:left] componentsSeparatedByString:@" "];
    self.stationLabel.stringValue = station.stationName;
    self.timeLabel.stringValue =  timeDescriptions.firstObject;
    self.timeDescLabel.stringValue =  timeDescriptions.lastObject;
    self.lineEndLabel.stringValue = nextDepature.line.lineEnd;
    self.lineNameLabel.stringValue = nextDepature.line.lineName;
    
    NSImage *image;
    NSColor *color = [NSColor colorWithWhite:0.5 alpha:0.5];
    
    switch (nextDepature.line.departureType) {
        case 1:
            image = [NSImage imageNamed:@"sbahn"];
            color = [NSColor colorWithRed:0 green:0.6 blue:0.37 alpha:1];
            break;
        case 2:
            image = [NSImage imageNamed:@"ubahn"];
            color = [NSColor colorWithRed:0 green:0.35 blue:0.58 alpha:1];
            break;
        case 4:
            image = [NSImage imageNamed:@"tram"];
            color = [NSColor colorWithRed:0.88 green:0 blue:0 alpha:1];
            break;
        case 8: {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^Bus M\\d+"];
                if ([predicate evaluateWithObject:nextDepature.line.lineName]) {
                    image = [NSImage imageNamed:@"metroBus"];
                    color = [NSColor colorWithRed:1 green:0.44 blue:0 alpha:1];
                } else {
                    image = [NSImage imageNamed:@"bus"];
                    color = [NSColor colorWithRed:0.65 green:0 blue:0.42 alpha:1];
                }
            }
            break;
        case 32 :
            image = [NSImage imageNamed:@"train"];
            color = [NSColor colorWithRed:0.82 green:0 blue:0 alpha:1];
            break;
        default:
            break;
    }
    
    self.seperatorLayer.backgroundColor = color.CGColor;
    self.iconView.image = image;
}

- (NSString *)nibName {
    return NSStringFromClass([self class]);
}

-(void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [self setInformations:representedObject];
}

-(TTTTimeIntervalFormatter*)timeFormatter {
    static dispatch_once_t onceToken;
    static TTTTimeIntervalFormatter *timeFormatter;
    dispatch_once(&onceToken, ^{
        timeFormatter = [TTTTimeIntervalFormatter new];
        timeFormatter.leastSignificantUnit = NSCalendarUnitMinute;
        timeFormatter.usesAbbreviatedCalendarUnits = YES;
        timeFormatter.futureDeicticExpression = nil;
    });
    return timeFormatter;
}

@end

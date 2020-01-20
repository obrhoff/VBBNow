//
//  VBBListRowViewController.m
//  today
//
//  Created by Dennis Oberhoff on 30/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

@import VBBFramework;

#import "VBBListRowViewController.h"

@interface VBBListRowViewController ()

@property(nonatomic, readwrite, strong) CALayer *seperatorLayer;

@end

@implementation VBBListRowViewController

- (void)viewDidLoad {
    self.seperatorLayer = [CALayer new];
    [self.view.layer addSublayer:self.seperatorLayer];
    [super viewDidLoad];
}

- (void)viewDidLayout {
    self.seperatorLayer.frame = CGRectMake(CGRectGetMaxX(self.timeLabel.frame), CGRectGetMinY(self.stationLabel.frame),
            2.5, CGRectGetMinY(self.timeLabel.frame) + CGRectGetMaxY(self.timeDescLabel.frame));
}

- (void)setInformations:(VBBStation *)station {
    NSDate *future = [NSDate dateWithTimeInterval:60 sinceDate:[NSDate date]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"scheduledDate > %@", future];
    VBBDepature *nextDepature = [station.depatures objectsWithPredicate:predicate].firstObject;
    NSTimeInterval seconds = [nextDepature.arrivalDate timeIntervalSinceDate:[NSDate date]];
    NSArray *timeDescriptions = [[[NSDateComponentsFormatter timeFormatter] stringFromTimeInterval:seconds] componentsSeparatedByString:@" "];

    self.stationLabel.stringValue = station.stationName;
    self.timeLabel.stringValue = timeDescriptions.firstObject;
    self.timeDescLabel.stringValue = timeDescriptions.lastObject;
    self.lineEndLabel.stringValue = nextDepature.line.lineEnd;
    self.lineNameLabel.stringValue = nextDepature.line.lineName;

    NSBundle *frameworkBundle = [NSBundle frameworkBundle];
    NSString *assetName =  [VBBLine assetNameForType:nextDepature.line.lineType];
    NSImage *image = [frameworkBundle imageForResource:assetName];
    NSColor *color = [NSColor colorNamed:assetName bundle:frameworkBundle];

    self.seperatorLayer.backgroundColor = color.CGColor;
    self.iconView.image = image;
}

- (NSString *)nibName {
    return NSStringFromClass([self class]);
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    [self setInformations:representedObject];
}

@end

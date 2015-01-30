//
//  VBBListRowViewController.h
//  today
//
//  Created by Dennis Oberhoff on 30/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VBBPersistanceManager.h"

@interface VBBListRowViewController : NSViewController

@property (nonatomic, weak) IBOutlet NSTextField *stationLabel;
@property (nonatomic, weak) IBOutlet NSTextField *directionLabel;
@property (nonatomic, weak) IBOutlet NSTextField *stopLabel;
@property (nonatomic, weak) IBOutlet NSTextField *timeLabel;
@property (nonatomic, weak) IBOutlet NSTextField *timeDescLabel;

@property (nonatomic, weak) IBOutlet NSImageView *iconView;

@end

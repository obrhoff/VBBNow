//
//  AppDelegate.m
//  bvg
//
//  Created by Dennis Oberhoff on 28/01/15.
//  Copyright (c) 2015 Dennis Oberhoff. All rights reserved.
//

#import "AppDelegate.h"
#import "VBBNetworkManager.h"

@interface AppDelegate () <CLLocationManagerDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, readwrite, strong) CLLocationManager *locationManager;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [NSURLCache setSharedURLCache:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {

}

@end
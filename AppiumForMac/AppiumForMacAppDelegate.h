//
//  AppiumForMacAppDelegate.h
//  AppiumForMac
//
//  Created by Dan Cuellar on 7/27/13.
//  Copyright (c) 2013 Appium. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AfMHTTPServer.h"

#define AFM_SERVER [(AppiumForMacAppDelegate*)[[NSApplication sharedApplication] delegate] afmHTTPServer]

@interface AppiumForMacAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property AfMHTTPServer *afmHTTPServer;

@end

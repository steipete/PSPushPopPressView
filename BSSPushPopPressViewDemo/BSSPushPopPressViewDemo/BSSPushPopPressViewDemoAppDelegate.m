//
//  BSSPushPopPressViewDemoAppDelegate.m
//
//  Copyright 2011 Blacksmith Software. All rights reserved.
//

#import "BSSPushPopPressViewDemoAppDelegate.h"
#import "BSSPushPopPressViewDemoViewController.h"

@implementation BSSPushPopPressViewDemoAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL) application: (UIApplication*) application didFinishLaunchingWithOptions: (NSDictionary*) launchOptions {
    self.window.frame = CGRectMake(0, 0, 1024, 768);
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) dealloc {
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end

//
//  PSAppDelegate.h
//  PSPushPopPressViewExample
//
//  Created by Peter Steinberger on 11/16/11.
//  Copyright (c) 2011 Peter Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSExampleViewController;

@interface PSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PSExampleViewController *viewController;

@end
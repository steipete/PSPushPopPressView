//
//  BSSPushPopPressViewDemoViewController.m
//
//  Copyright 2011 Blacksmith Software. All rights reserved.
//

#import "BSSPushPopPressViewDemoViewController.h"
#import "BSSPushPopPressView.h"

@implementation BSSPushPopPressViewDemoViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    BSSPushPopPressView* pushPopPressView = [[BSSPushPopPressView alloc] initWithFrame: CGRectMake(300, 300, 500, 350)];
    UIImageView* imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"sampleimage.jpg"]];
    imageView.frame = CGRectMake(0, 0, 500, 350);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [pushPopPressView addSubview: imageView];
    [imageView release];
    
    [self.view addSubview: pushPopPressView];
}

- (void) viewDidUnload {
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation {
    return YES;
}

@end

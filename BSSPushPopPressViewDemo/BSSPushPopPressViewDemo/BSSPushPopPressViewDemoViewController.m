//
//  BSSPushPopPressViewDemoViewController.m
//
//  Copyright 2011 Blacksmith Software. All rights reserved.
//

#import "BSSPushPopPressViewDemoViewController.h"
#import "BSSPushPopPressView.h"

@implementation BSSPushPopPressViewDemoViewController

@synthesize contentView;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    contentView = [[UIView alloc] initWithFrame: CGRectZero];
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"backgroundImage.png"]];
    backgroundImageView.frame = contentView.bounds;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [contentView addSubview: backgroundImageView];
    
    [self.view addSubview: contentView];
    
    BSSPushPopPressView* pushPopPressView = [[BSSPushPopPressView alloc] initWithFrame: CGRectMake(61, 383, 500, 376)];
    pushPopPressView.delegate = self;
    UIImageView* imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"sampleimage.jpg"]];
    imageView.frame = CGRectMake(0, 0, 500, 376);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [pushPopPressView addSubview: imageView];
    [imageView release];
    
    [self.view addSubview: pushPopPressView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    contentView.frame = CGRectMake(-20, -15, self.view.window.bounds.size.width + 40, self.view.window.bounds.size.height + 30);
}

- (void) viewDidUnload {
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation {
    return YES;
}

- (void) bssPushPopPressViewDidStartManipulation: (BSSPushPopPressView*) pushPopPressView {
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.45];
    [UIView setAnimationBeginsFromCurrentState: YES];
    self.contentView.transform = CGAffineTransformMakeScale(0.97, 0.97);
    [UIView commitAnimations];
}

- (void) bssPushPopPressViewDidFinishManipulation: (BSSPushPopPressView*) pushPopPressView {
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.45];
    [UIView setAnimationBeginsFromCurrentState: YES];
    self.contentView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

@end

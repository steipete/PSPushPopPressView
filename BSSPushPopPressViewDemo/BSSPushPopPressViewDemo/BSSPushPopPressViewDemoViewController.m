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
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"backgroundImage2.png"]];
    backgroundImageView.frame = contentView.bounds;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    backgroundImageView.tag = 661;
    [contentView addSubview: backgroundImageView];
    
    [self.view addSubview: contentView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    contentView.frame = CGRectMake(-20, -15, self.view.window.bounds.size.width + 40, self.view.window.bounds.size.height + 30);
    [contentView viewWithTag: 661].frame = CGRectMake(0, 0, self.view.window.bounds.size.width + 40, self.view.window.bounds.size.height + 30);
    
    BSSPushPopPressView* pushPopPressView = [[BSSPushPopPressView alloc] initWithFrame: CGRectMake(305, 230, 396, 514)];
    pushPopPressView.delegate = self;
    UIImageView* imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"sampleimage.jpg"]];
    imageView.frame = CGRectMake(0, 0, 396, 514);
    imageView.userInteractionEnabled = NO;
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

- (void) bssPushPopPressViewWillAnimateToOriginalFrame: (BSSPushPopPressView*) pushPopPressView duration: (NSTimeInterval) duration {
    NSLog(@"Will animate to original frame");
}

- (void) bssPushPopPressViewDidAnimateToOriginalFrame: (BSSPushPopPressView*) pushPopPressView {
    NSLog(@"Did animate to original frame");
}

- (void) bssPushPopPressViewWillAnimateToFullscreenWindowFrame: (BSSPushPopPressView*) pushPopPressView duration: (NSTimeInterval) duration {
    NSLog(@"Will animate to fullscreen");
}

- (void) bssPushPopPressViewDidAnimateToFullscreenWindowFrame: (BSSPushPopPressView*) pushPopPressView {
    NSLog(@"Did animate to fullscreen");
}


@end

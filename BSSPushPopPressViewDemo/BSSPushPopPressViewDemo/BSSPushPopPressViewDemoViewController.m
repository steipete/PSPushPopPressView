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

- (void) dealloc {
    [pushPopPressView release], pushPopPressView = nil;
    [playPauseButton release], playPauseButton = nil;
    [super dealloc];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    contentView.frame = CGRectMake(-20, -15, self.view.window.bounds.size.width + 40, self.view.window.bounds.size.height + 30);
    [contentView viewWithTag: 661].frame = CGRectMake(0, 0, self.view.window.bounds.size.width + 40, self.view.window.bounds.size.height + 30);
    
    pushPopPressView = [[BSSPushPopPressView alloc] initWithFrame: CGRectMake(305, 230, 396, 514)];
    pushPopPressView.pushPopPressViewDelegate = self;
    UIImageView* imageView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"sampleimage.jpg"]];
    imageView.frame = CGRectMake(0, 0, 396, 514);
    imageView.userInteractionEnabled = NO;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [pushPopPressView addSubview: imageView];
    [imageView release];
    
/*  Uncomment to see how a play/pause button overlayed on the view might work
    playPauseButton = [[UIButton buttonWithType: UIButtonTypeCustom] retain];
    [playPauseButton setBackgroundColor: [UIColor redColor]];
    [playPauseButton setTitle: @"Play" forState: UIControlStateNormal];
    playPauseButton.frame = CGRectMake(150, 225, 96, 64);
    playPauseButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [pushPopPressView addSubview: playPauseButton];
    playPauseButton.tag = 1;
    [playPauseButton addTarget: self action: @selector(playOrPause:) forControlEvents: UIControlEventTouchUpInside];
    playPauseButton.userInteractionEnabled = YES;
 */
    
    [self.view addSubview: pushPopPressView];
}

- (void) viewDidUnload {
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation {
    return YES;
}

- (void) bssPushPopPressViewDidStartManipulation: (BSSPushPopPressView*) pushPopPressView {
    NSLog(@"bssPushPopPressViewDidStartManipulation:");
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.45];
    [UIView setAnimationBeginsFromCurrentState: YES];
    self.contentView.transform = CGAffineTransformMakeScale(0.97, 0.97);
    [UIView commitAnimations];
}

- (void) bssPushPopPressViewDidFinishManipulation: (BSSPushPopPressView*) pushPopPressView {
    NSLog(@"bssPushPopPressViewDidFinishManipulation:");
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationDuration: 0.45];
    [UIView setAnimationBeginsFromCurrentState: YES];
    self.contentView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

- (void) bssPushPopPressViewWillAnimateToOriginalFrame: (BSSPushPopPressView*) pushPopPressView duration: (NSTimeInterval) duration {
    NSLog(@"bssPushPopPressViewWillAnimateToOriginalFrame:duration:");
}

- (void) bssPushPopPressViewDidAnimateToOriginalFrame: (BSSPushPopPressView*) pushPopPressView {
    NSLog(@"bssPushPopPressViewDidAnimateToOriginalFrame:");
}

- (void) bssPushPopPressViewWillAnimateToFullscreenWindowFrame: (BSSPushPopPressView*) pushPopPressView duration: (NSTimeInterval) duration {
    NSLog(@"bssPushPopPressViewWillAnimateToFullscreenWindowFrame:duration:");
}

- (void) bssPushPopPressViewDidAnimateToFullscreenWindowFrame: (BSSPushPopPressView*) pushPopPressView {
    NSLog(@"bssPushPopPressViewDidAnimateToFullscreenWindowFrame:");
}

- (BOOL) bssPushPopPressViewShouldAllowTapToAnimateToOriginalFrame: (BSSPushPopPressView*) pushPopPressView {
    NSLog(@"bssPushPopPressViewShouldAllowTapToAnimateToOriginalFrame:");
    return playPauseButton.tag != 2;
}

- (BOOL) bssPushPopPressViewShouldAllowTapToAnimateToFullscreenWindowFrame: (BSSPushPopPressView*) pushPopPressView {
    NSLog(@"bssPushPopPressViewShouldAllowTapToAnimateToFullscreenWindowFrame:");
    return YES;
}

- (void) bssPushPopPressViewDidReceiveTap: (BSSPushPopPressView*) pushPopPressView {
    NSLog(@"bssPushPopPressViewDidReceiveTap:");
}

- (void) playOrPause: (id) sender {
    if (playPauseButton.tag == 1) {
        [playPauseButton setTitle: @"Pause" forState: UIControlStateNormal];
        playPauseButton.tag = 2;
        [pushPopPressView animateToFullscreenWindowFrame];
    } else if (playPauseButton.tag == 2) {
        playPauseButton.tag = 1;
        [playPauseButton setTitle: @"Play" forState: UIControlStateNormal];
        [pushPopPressView animateToOriginalFrame];
    }
}

@end

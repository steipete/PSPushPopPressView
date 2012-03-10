//
//  PSPushPopPressView.h
//  PSPushPopPressView
//
//  Based on BSSPushPopPressView by Blacksmith Software.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class PSPushPopPressView;

@protocol PSPushPopPressViewDelegate <NSObject>
@optional

/// manipulation starts, user has >= 2 fingers on the view
- (void)pushPopPressViewDidStartManipulation:(PSPushPopPressView *)pushPopPressView;

/// manipulation stopps, user has < 2 fingers on the view
- (void)pushPopPressViewDidFinishManipulation:(PSPushPopPressView *)pushPopPressView;

/// view will animate back to original frame
- (void)pushPopPressViewWillAnimateToOriginalFrame:(PSPushPopPressView *)pushPopPressView duration: (NSTimeInterval)duration;

/// animation to original frame is finished
- (void)pushPopPressViewDidAnimateToOriginalFrame:(PSPushPopPressView *)pushPopPressView;

- (void)pushPopPressViewWillAnimateToFullscreenWindowFrame:(PSPushPopPressView *)pushPopPressView duration: (NSTimeInterval)duration;
- (void)pushPopPressViewDidAnimateToFullscreenWindowFrame:(PSPushPopPressView *)pushPopPressView;

- (BOOL)pushPopPressViewShouldAllowTapToAnimateToOriginalFrame:(PSPushPopPressView *)pushPopPressView;
- (BOOL)pushPopPressViewShouldAllowTapToAnimateToFullscreenWindowFrame:(PSPushPopPressView *)pushPopPressView;

/// only active if allowSingleTapSwitch is enabled (default)
- (void)pushPopPressViewDidReceiveTap:(PSPushPopPressView *)pushPopPressView;

@end

@interface PSPushPopPressView : UIView <UIGestureRecognizerDelegate> {
    UITapGestureRecognizer* tapRecognizer_;
    UILongPressGestureRecognizer* doubleTouchRecognizer;
    UIPanGestureRecognizer* panRecognizer_;
    CGAffineTransform scaleTransform_;
    CGAffineTransform rotateTransform_;
    CGAffineTransform panTransform_;
    CGRect initialFrame_;
	NSInteger initialIndex_;
    BOOL allowSingleTapSwitch_;
    BOOL fullscreen_;
    BOOL ignoreStatusBar_;
	BOOL keepShadow_;
    BOOL fullscreenAnimationActive_;
    BOOL anchorPointUpdated;
}

/// the delegate for the PushPopPressView
@property (nonatomic, unsafe_unretained) id<PSPushPopPressViewDelegate> pushPopPressViewDelegate;

/// returns true if fullscreen is enabled
@property (nonatomic, readonly, getter=isFullscreen) BOOL fullscreen;

/// true if one or more fingers are on the view
@property (nonatomic, readonly, getter=isBeingDragged) BOOL beingDragged;

/// set initialFrame if you change frame after initWithFrame
@property (nonatomic, assign) CGRect initialFrame;

/// allow mode switching via single tap. Defaults to YES.
@property (nonatomic, assign) BOOL allowSingleTapSwitch;

/// if true, [UIScreen mainScreen] is used for coordinates (vs rootView)
@property (nonatomic, assign) BOOL ignoreStatusBar;

/// if true, shadow does not appear/disappear when animating
@property (nonatomic, assign) BOOL keepShadow;

/// animate/move to fullscreen
- (void)moveToFullscreenWindowAnimated:(BOOL)animated;

/// animate/moves to initialFrame size
- (void)moveToOriginalFrameAnimated:(BOOL)animated;

/// align view based on current size (either initialPosition or fullscreen)
- (void)alignViewAnimated:(BOOL)animated bounces:(BOOL)bounces;

@end

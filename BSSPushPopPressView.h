//
// -----------------------------------------------------------------------------
// Copyright (c) 2011 Blacksmith Software

// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
// -----------------------------------------------------------------------------
//
//  BSSPushPopPressView.h
//
//  Copyright 2011 Blacksmith Software. All rights reserved.
//  Modified by Peter Steinberger, 2011.
//

#import <Foundation/Foundation.h>

@class BSSPushPopPressView;

@protocol BSSPushPopPressViewDelegate<NSObject>
@optional
- (void) bssPushPopPressViewDidStartManipulation: (BSSPushPopPressView*) pushPopPressView;
- (void) bssPushPopPressViewDidFinishManipulation: (BSSPushPopPressView*) pushPopPressView;

- (void) bssPushPopPressViewWillAnimateToOriginalFrame: (BSSPushPopPressView*) pushPopPressView duration: (NSTimeInterval) duration;
- (void) bssPushPopPressViewDidAnimateToOriginalFrame: (BSSPushPopPressView*) pushPopPressView;

- (void) bssPushPopPressViewWillAnimateToFullscreenWindowFrame: (BSSPushPopPressView*) pushPopPressView duration: (NSTimeInterval) duration;
- (void) bssPushPopPressViewDidAnimateToFullscreenWindowFrame: (BSSPushPopPressView*) pushPopPressView;

- (BOOL) bssPushPopPressViewShouldAllowTapToAnimateToOriginalFrame: (BSSPushPopPressView*) pushPopPressView;
- (BOOL) bssPushPopPressViewShouldAllowTapToAnimateToFullscreenWindowFrame: (BSSPushPopPressView*) pushPopPressView;

/// only active if allowSingleTapSwitch is enabled (default)
- (void) bssPushPopPressViewDidReceiveTap: (BSSPushPopPressView*) pushPopPressView;

@end

@interface BSSPushPopPressView : UIView<UIGestureRecognizerDelegate> {
    UITapGestureRecognizer* tapRecognizer;

    CGAffineTransform scaleTransform;
    CGAffineTransform rotateTransform;
    CGAffineTransform panTransform;
    CGRect initialFrame;
    
    BOOL allowSingleTapSwitch;
    BOOL fullscreen;
    BOOL fullscreenAnimationActive;
    BOOL beingDragged;
    BOOL gesturesEnded;
    BOOL scaleActive;
    
    NSMutableSet* currentTouches;
}

@property (nonatomic, assign) id<BSSPushPopPressViewDelegate> pushPopPressViewDelegate;

/// returns true if fullscreen is enabled
@property (nonatomic, readonly) BOOL isFullscreen;

/// true if one or more fingers are on the view
@property (nonatomic, readonly, getter=isBeingDragged) BOOL beingDragged;

/// set initialFrame if you change frame after initWithFrame
@property (nonatomic, assign) CGRect initialFrame;

/// allow mode switching via single tap. Defaults to YES.
@property (nonatomic, assign) BOOL allowSingleTapSwitch;

- (void) animateToFullscreenWindowFrame;
- (void) animateToOriginalFrame;

@end

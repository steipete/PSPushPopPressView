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
//  BSSPushPopPressView.m
//
//  Copyright 2011 Blacksmith Software. All rights reserved.
//  Modified by Peter Steinberger, 2011.
//

#import "BSSPushPopPressView.h"
#import <QuartzCore/QuartzCore.h>

#define kBSSAnimationDuration 0.35f
#define kBSSShadowFadeDuration 0.45f
#define kBSSAnimationMoveToOriginalPositionDuration 0.5f

@implementation BSSPushPopPressView

@synthesize pushPopPressViewDelegate;
@synthesize beingDragged;

- (id) initWithFrame: (CGRect) _frame {
    if ((self = [super initWithFrame: _frame])) {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        
        scaleTransform = CGAffineTransformIdentity;
        rotateTransform = CGAffineTransformIdentity;
        panTransform = CGAffineTransformIdentity;
        
        initialFrame = _frame;
        
        UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget: self action: @selector(pinch:)];
        pinchRecognizer.cancelsTouchesInView = NO;
        pinchRecognizer.delaysTouchesBegan = NO;
        pinchRecognizer.delaysTouchesEnded = NO;
        pinchRecognizer.delegate = self;
        [self addGestureRecognizer: pinchRecognizer];
        [pinchRecognizer release];
        
        UIRotationGestureRecognizer* rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget: self action: @selector(rotate:)];
        rotationRecognizer.cancelsTouchesInView = NO;
        rotationRecognizer.delaysTouchesBegan = NO;
        rotationRecognizer.delaysTouchesEnded = NO;
        rotationRecognizer.delegate = self;
        [self addGestureRecognizer: rotationRecognizer];
        [rotationRecognizer release];
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(pan:)];
        panRecognizer.cancelsTouchesInView = NO;
        panRecognizer.delaysTouchesBegan = NO;
        panRecognizer.delaysTouchesEnded = NO;
        panRecognizer.delegate = self;
        panRecognizer.minimumNumberOfTouches = 2;
        panRecognizer.maximumNumberOfTouches = 2;
        [self addGestureRecognizer: panRecognizer];
        [panRecognizer release];
        
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tap:)];
        tapRecognizer.delegate = self;
        tapRecognizer.cancelsTouchesInView = NO;
        tapRecognizer.delaysTouchesBegan = NO;
        tapRecognizer.delaysTouchesEnded = NO; 
        [self addGestureRecognizer: tapRecognizer];
        [tapRecognizer release];
        
        currentTouches = [NSMutableSet new];

        self.layer.shadowRadius = 15.0f;
        self.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
        self.layer.shadowOpacity = 0.4f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        self.layer.shadowOpacity = 0.0f;
    }
    
    return self;
}

- (void) dealloc {
    pushPopPressViewDelegate = nil;
    [currentTouches release], currentTouches = nil;
    [super dealloc];
}

// if frame is set externally, save as new initialFrame
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    // don't accept framechanges for internalFrame when in fullscreen
    if (!self.isFullscreen) {
        initialFrame = frame;
    }
}

// don't manipulate initialFrame inside the view
- (void)setFrameInternal:(CGRect)frame {
    [super setFrame:frame];
}

- (CGRect)windowBounds {
    CGRect windowBounds = self.window.bounds;

    // window is at the very root and doesn't have rotation applied yet
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat tmp = windowBounds.size.width;
        windowBounds.size.width = windowBounds.size.height;
        windowBounds.size.height = tmp;
    }
    return windowBounds;
}

- (void)updateShadowPath {
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)applyShadowAnimated:(BOOL)animated {
    if(animated) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        anim.fromValue = [NSNumber numberWithFloat:0.0f];
        anim.toValue = [NSNumber numberWithFloat:1.0f];
        anim.duration = kBSSShadowFadeDuration;
        [self.layer addAnimation:anim forKey:@"shadowOpacity"];
    }

    [self updateShadowPath];
    self.layer.shadowOpacity = 1.0f;
}

- (void)removeShadowAnimated:(BOOL)animated {

    // TODO: sometimes animates cracy, shadowOpacity animation losses shadowPath transform on certain conditions
    // shadow should also use a "lightSource", maybe it's easier to make a completely custom shadow view.
    if (animated) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        anim.fromValue = [NSNumber numberWithFloat:1.0f];
        anim.toValue = [NSNumber numberWithFloat:0.0f];
        anim.duration = kBSSShadowFadeDuration;
        [self.layer addAnimation:anim forKey:@"shadowOpacity"];
    }

    self.layer.shadowOpacity = 0.0f;
}

- (void)setBeingDragged:(BOOL)newBeingDragged {
    if (newBeingDragged != beingDragged) {
        beingDragged = newBeingDragged;

        if (beingDragged) {
            [self applyShadowAnimated:YES];
        }else {
            [self removeShadowAnimated:YES];
        }
    }
}

- (void) moveViewToOriginalPosition {    
    CGFloat bounceX = panTransform.tx * 0.01 * -1;
    CGFloat bounceY = panTransform.ty * 0.01 * -1;
    
    CGFloat widthDifference = (self.frame.size.width - initialFrame.size.width) * 0.05;
    CGFloat heightDifference = (self.frame.size.height - initialFrame.size.height) * 0.05;

    if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewWillAnimateToOriginalFrame:duration:)]) {
        [self.pushPopPressViewDelegate bssPushPopPressViewWillAnimateToOriginalFrame: self duration:kBSSAnimationMoveToOriginalPositionDuration*1.5f];
    }
    [UIView animateWithDuration: kBSSAnimationMoveToOriginalPositionDuration delay: 0.0
                        options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations: ^{
                         CGRect targetFrame = CGRectMake(initialFrame.origin.x + bounceX + (widthDifference / 2.0), initialFrame.origin.y + bounceY + (heightDifference / 2.0), initialFrame.size.width + (widthDifference * -1), initialFrame.size.height + (heightDifference * -1));
                         rotateTransform = CGAffineTransformIdentity;
                         panTransform = CGAffineTransformIdentity;
                         scaleTransform = CGAffineTransformIdentity;
                         self.transform = CGAffineTransformIdentity;
                         [self setFrameInternal:targetFrame];
                     }
                     completion: ^(BOOL finished) {
                         [UIView animateWithDuration: kBSSAnimationMoveToOriginalPositionDuration/2 delay: 0.0
                                             options:UIViewAnimationOptionAllowUserInteraction animations: ^{
                                                 [self setFrameInternal:initialFrame];
                                             } completion: ^(BOOL finished) {
                                                 if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewDidAnimateToOriginalFrame:)]) {
                                                     [self.pushPopPressViewDelegate bssPushPopPressViewDidAnimateToOriginalFrame: self];
                                                 }
                                             }];
                     }];
}

- (void) startedGesturesWithPinch: (UIPinchGestureRecognizer*) pinch pan: (UIPanGestureRecognizer*) pan rotate: (UIRotationGestureRecognizer*) rotate {
    gesturesEnded = NO;
    if (pinch) {
        scaleActive = YES;
    }
}

/*
 When one gesture ends, the whole view manipulation is ended. In case the user also started a pinch and the pinch is still active, we wait for the pinch to finish as we want to check for a fast pinch movement to open the view in fullscreen or not. If no pinch is active, we can end the manipulation as soon as the first gesture ended.
 */
- (void) endedGesturesWithPinch: (UIPinchGestureRecognizer*) pinch pan: (UIPanGestureRecognizer*) pan rotate: (UIRotationGestureRecognizer*) rotate {
    if (gesturesEnded) return;
    
    if (scaleActive == YES && pinch == nil) return;
    
    gesturesEnded = YES;        
    
    if (pinch) {
        scaleActive = NO;
        if (pinch.velocity >= 15.0) {
            if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewWillAnimateToFullscreenWindowFrame:duration:)]) {
                [self.pushPopPressViewDelegate bssPushPopPressViewWillAnimateToFullscreenWindowFrame: self duration: kBSSAnimationDuration];
            }
            [UIView animateWithDuration: kBSSAnimationDuration delay: 0.0 options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                             animations: ^{
                                 scaleTransform = CGAffineTransformIdentity;
                                 rotateTransform = CGAffineTransformIdentity;
                                 panTransform = CGAffineTransformIdentity;
                                 self.transform = CGAffineTransformIdentity;
                                 [self setFrameInternal:[self windowBounds]];
                             }
                             completion: ^(BOOL finished) {
                                 if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewDidAnimateToFullscreenWindowFrame:)]) {
                                     [self.pushPopPressViewDelegate bssPushPopPressViewDidAnimateToFullscreenWindowFrame: self];
                                 }
                             }];
        } else if (self.frame.size.width > ([self windowBounds].size.width * 0.85)) {
            if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewWillAnimateToFullscreenWindowFrame:duration:)]) {
                [self.pushPopPressViewDelegate bssPushPopPressViewWillAnimateToFullscreenWindowFrame: self duration: kBSSAnimationDuration];
            }
            [UIView animateWithDuration: kBSSAnimationDuration delay: 0.0 options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                             animations: ^{
                                 scaleTransform = CGAffineTransformIdentity;
                                 rotateTransform = CGAffineTransformIdentity;
                                 panTransform = CGAffineTransformIdentity;
                                 self.transform = CGAffineTransformIdentity;
                                 [self setFrameInternal:[self windowBounds]];
                             }
                             completion: ^(BOOL finished) {
                                 if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewDidAnimateToFullscreenWindowFrame:)]) {
                                     [self.pushPopPressViewDelegate bssPushPopPressViewDidAnimateToFullscreenWindowFrame: self];
                                 }
                             }];
        } else {
            [self moveViewToOriginalPosition];
        }
    } else {
        [self moveViewToOriginalPosition];
    }
}

- (void) modifiedGesturesWithPinch: (UIPinchGestureRecognizer*) pinch pan: (UIPanGestureRecognizer*) pan rotate: (UIRotationGestureRecognizer*) rotate {
    if (pinch) {
        scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, pinch.scale, pinch.scale);
    }
    if (rotate) {
        rotateTransform = CGAffineTransformRotate(CGAffineTransformIdentity, rotate.rotation);
    }
    if (pan) {
        CGPoint translation = [pan translationInView: self.superview];
        panTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, translation.x, translation.y);
    }
    
    self.transform = CGAffineTransformConcat(CGAffineTransformConcat(scaleTransform, rotateTransform), panTransform);
}

- (void) pinch: (UIPinchGestureRecognizer*) pinch {
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan: { 
            [self startedGesturesWithPinch: pinch pan: nil rotate: nil];
            break; }
        case UIGestureRecognizerStatePossible: { break; }
        case UIGestureRecognizerStateCancelled: {
            [self endedGesturesWithPinch: pinch pan: nil rotate: nil];
        } break;
        case UIGestureRecognizerStateFailed: { 
        } break; 
        case UIGestureRecognizerStateChanged: {
            [self modifiedGesturesWithPinch: pinch pan: nil rotate: nil];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self endedGesturesWithPinch: pinch pan: nil rotate: nil];
            break; 
        }
    }
}

- (void) rotate: (UIRotationGestureRecognizer*) rotate {
    switch (rotate.state) {
        case UIGestureRecognizerStateBegan: { 
            [self startedGesturesWithPinch: nil pan: nil rotate: rotate];
        } break;
        case UIGestureRecognizerStatePossible: { break; }
        case UIGestureRecognizerStateCancelled: { 
            [self endedGesturesWithPinch: nil pan: nil rotate: rotate];
        } break;
        case UIGestureRecognizerStateFailed: { 
        } break;
        case UIGestureRecognizerStateChanged: {
            [self modifiedGesturesWithPinch: nil pan: nil rotate: rotate];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self endedGesturesWithPinch: nil pan: nil rotate: rotate];
            break; 
        }
    }
}

- (void) pan: (UIPanGestureRecognizer*) pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            [self startedGesturesWithPinch: nil pan: pan rotate: nil];
        } break;
        case UIGestureRecognizerStatePossible: { break; }
        case UIGestureRecognizerStateCancelled: { 
            [self endedGesturesWithPinch: nil pan: pan rotate: nil];
        } break;
        case UIGestureRecognizerStateFailed: { 
        } break;
        case UIGestureRecognizerStateChanged: {
            [self modifiedGesturesWithPinch: nil pan: pan rotate: nil];
            break;
        }
        case UIGestureRecognizerStateEnded: { 
            [self endedGesturesWithPinch: nil pan: pan rotate: nil];
            break; 
        }
    }
}

- (void) tap: (UITapGestureRecognizer*) tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewDidReceiveTap:)]) {
            [self.pushPopPressViewDelegate bssPushPopPressViewDidReceiveTap: self];
        }
        if (CGRectEqualToRect(self.frame, initialFrame)) {
            [self animateToFullscreenWindowFrame];
        } else {
            [self animateToOriginalFrame];
        }
    }
}

- (BOOL) gestureRecognizer: (UIGestureRecognizer*) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer: (UIGestureRecognizer*) otherGestureRecognizer {
    // if the gesture recognizers's view isn't one of our pieces, don't allow simultaneous recognition
    if (gestureRecognizer.view != self)
        return NO;

    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;

    return YES;
}

- (BOOL) gestureRecognizer: (UIGestureRecognizer*) gestureRecognizer shouldReceiveTouch: (UITouch*) touch {
    if ([gestureRecognizer isKindOfClass: [UITapGestureRecognizer class]] && [touch.view isKindOfClass: [UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL notYetStarted = [currentTouches count] < 2;
    [currentTouches unionSet:touches];
    if (notYetStarted && [currentTouches count] >= 2) {
        self.beingDragged = YES;
        [self.pushPopPressViewDelegate bssPushPopPressViewDidStartManipulation: self];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL notYetEnded = [currentTouches count] >= 2;
    [currentTouches minusSet:touches];
    if (notYetEnded && [currentTouches count] < 2) {
        self.beingDragged = NO;
        [self.pushPopPressViewDelegate bssPushPopPressViewDidFinishManipulation: self];
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL notYetEnded = [currentTouches count] >= 2;
    [currentTouches minusSet:touches];
    if (notYetEnded && [currentTouches count] < 2) {
        self.beingDragged = NO;
        [self.pushPopPressViewDelegate bssPushPopPressViewDidFinishManipulation: self];
    }
}

- (BOOL) isFullscreen {
    return CGRectEqualToRect(self.frame, [self windowBounds]);
}

- (void) animateToFullscreenWindowFrame {
    if (self.isFullscreen) return;

    if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewShouldAllowTapToAnimateToFullscreenWindowFrame:)]) {
        if ([self.pushPopPressViewDelegate bssPushPopPressViewShouldAllowTapToAnimateToFullscreenWindowFrame: self] == NO) return;
    }

    if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewWillAnimateToFullscreenWindowFrame:duration:)]) {
        [self.pushPopPressViewDelegate bssPushPopPressViewWillAnimateToFullscreenWindowFrame: self duration:kBSSAnimationDuration*2];
    }

    CGRect windowBounds = [self windowBounds];
    [UIView animateWithDuration:kBSSAnimationDuration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self setFrameInternal:CGRectMake(windowBounds.origin.x - 10, windowBounds.origin.y - 10,windowBounds.size.width + 20, windowBounds.size.height + 20)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:kBSSAnimationDuration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self setFrameInternal:windowBounds];
        } completion:^(BOOL finished) {
            if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewDidAnimateToFullscreenWindowFrame:)]) {
                [self.pushPopPressViewDelegate bssPushPopPressViewDidAnimateToFullscreenWindowFrame: self];
            }
        }];
    }];
}

- (void) animateToOriginalFrame {
    if (self.isFullscreen == NO) return;
    
    if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewShouldAllowTapToAnimateToOriginalFrame:)]) {
        if ([self.pushPopPressViewDelegate bssPushPopPressViewShouldAllowTapToAnimateToOriginalFrame: self] == NO) return;
    }
    
    if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewWillAnimateToOriginalFrame:duration:)]) {
        [self.pushPopPressViewDelegate bssPushPopPressViewWillAnimateToOriginalFrame: self duration:kBSSAnimationDuration*2];
    }

    [UIView animateWithDuration:kBSSAnimationDuration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        [self setFrameInternal:CGRectMake(initialFrame.origin.x + 3, initialFrame.origin.y + 3, initialFrame.size.width - 6, initialFrame.size.height - 6)];
    } completion: ^(BOOL finished) {
        [UIView animateWithDuration:kBSSAnimationDuration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            [self setFrameInternal:initialFrame];
        } completion: ^(BOOL finished) {
            if ([self.pushPopPressViewDelegate respondsToSelector: @selector(bssPushPopPressViewDidAnimateToOriginalFrame:)]) {
                [self.pushPopPressViewDelegate bssPushPopPressViewDidAnimateToOriginalFrame: self];
            }
        }];
    }];
}

@end

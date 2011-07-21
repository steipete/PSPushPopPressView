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
//

#import "BSSPushPopPressView.h"

@implementation BSSPushPopPressView

- (id) initWithFrame: (CGRect) _frame {
    if ((self = [super initWithFrame: _frame])) {
        self.userInteractionEnabled = YES;
        
        scaleTransform = CGAffineTransformIdentity;
        rotateTransform = CGAffineTransformIdentity;
        panTransform = CGAffineTransformIdentity;
        
        initialFrame = _frame;
        
        UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget: self action: @selector(pinch:)];
        pinchRecognizer.delegate = self;
        [self addGestureRecognizer: pinchRecognizer];
        [pinchRecognizer release];
        
        UIRotationGestureRecognizer* rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget: self action: @selector(rotate:)];
        rotationRecognizer.delegate = self;
        [self addGestureRecognizer: rotationRecognizer];
        [rotationRecognizer release];
        
        UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(pan:)];
        panRecognizer.delegate = self;
        panRecognizer.minimumNumberOfTouches = 2;
        panRecognizer.maximumNumberOfTouches = 2;
        [self addGestureRecognizer: panRecognizer];
        [panRecognizer release];
        
        UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tap:)];
        [self addGestureRecognizer: tapRecognizer];
        [tapRecognizer release];
    }
    
    return self;
}

- (void) pinch: (UIPinchGestureRecognizer*) pinch {
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan: { break; }
        case UIGestureRecognizerStatePossible: { break; }
        case UIGestureRecognizerStateCancelled: { break; }
        case UIGestureRecognizerStateFailed: { break; }
        case UIGestureRecognizerStateChanged: {
            scaleTransform = CGAffineTransformScale(CGAffineTransformIdentity, pinch.scale, pinch.scale);
            self.transform = CGAffineTransformConcat(CGAffineTransformConcat(scaleTransform, rotateTransform), panTransform);
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [UIView beginAnimations: nil context: nil];
            [UIView setAnimationBeginsFromCurrentState: YES];
            if (pinch.velocity >= 15.0) {
                scaleTransform = CGAffineTransformIdentity;
                rotateTransform = CGAffineTransformIdentity;
                panTransform = CGAffineTransformIdentity;
                self.transform = CGAffineTransformIdentity;
                self.frame = self.window.bounds;
            } else if (pinch.scale * initialFrame.size.width > (self.window.bounds.size.width * 0.75)) {
                scaleTransform = CGAffineTransformIdentity;
                rotateTransform = CGAffineTransformIdentity;
                panTransform = CGAffineTransformIdentity;
                self.transform = CGAffineTransformIdentity;
                self.frame = self.window.bounds;                
            } else {
                rotateTransform = CGAffineTransformIdentity;
                panTransform = CGAffineTransformIdentity;
                scaleTransform = CGAffineTransformIdentity;
                self.transform = CGAffineTransformIdentity;
                self.frame = initialFrame;
            }
            [UIView commitAnimations];
            break; 
        }
    }
}

- (void) rotate: (UIRotationGestureRecognizer*) rotate {
    switch (rotate.state) {
        case UIGestureRecognizerStateBegan: { break; }
        case UIGestureRecognizerStatePossible: { break; }
        case UIGestureRecognizerStateCancelled: { break; }
        case UIGestureRecognizerStateFailed: { break; }
        case UIGestureRecognizerStateChanged: {
            rotateTransform = CGAffineTransformRotate(CGAffineTransformIdentity, rotate.rotation);
            self.transform = CGAffineTransformConcat(CGAffineTransformConcat(scaleTransform, rotateTransform), panTransform);
            break;
        }
        case UIGestureRecognizerStateEnded: {
            rotateTransform = CGAffineTransformIdentity;
            break; 
        }
    }
}

- (void) pan: (UIPanGestureRecognizer*) pan {
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: { break; }
        case UIGestureRecognizerStatePossible: { break; }
        case UIGestureRecognizerStateCancelled: { break; }
        case UIGestureRecognizerStateFailed: { break; }
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [pan translationInView: self.superview];
            panTransform = CGAffineTransformTranslate(CGAffineTransformIdentity, translation.x, translation.y);
            self.transform = CGAffineTransformConcat(CGAffineTransformConcat(scaleTransform, rotateTransform), panTransform);
            break;
        }
        case UIGestureRecognizerStateEnded: { 
            panTransform = CGAffineTransformIdentity;
            self.transform = CGAffineTransformConcat(CGAffineTransformConcat(scaleTransform, rotateTransform), panTransform);
            break; 
        }
    }
}

- (void) tap: (UITapGestureRecognizer*) tap {
    [UIView beginAnimations: nil context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    if (CGRectEqualToRect(self.frame, initialFrame)) {
        self.frame = self.window.bounds;
    } else {
        self.frame = initialFrame;
    }
    [UIView commitAnimations];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

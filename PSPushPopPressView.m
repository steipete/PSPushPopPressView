//
//  PSPushPopPressView.m
//  PSPushPopPressView
//
//  Based on BSSPushPopPressView by Blacksmith Software.
//

#import "PSPushPopPressView.h"
#import <QuartzCore/QuartzCore.h>

#define kPSAnimationDuration 0.35f
#define kPSShadowFadeDuration 0.45f
#define kPSAnimationMoveToOriginalPositionDuration 0.5f
#define kPSFullscreenAnimationBounce 20
#define kPSEmbeddedAnimationBounceMultiplier 0.05f

@interface PSPushPopPressView() {
    // internal state variables
    UIView *initialSuperview_;
    BOOL fullscreenAnimationActive_;
    BOOL beingDragged_;
    BOOL gesturesEnded_;
    BOOL scaleActive_;
}
@property (nonatomic, getter=isBeingDragged) BOOL beingDragged;
@property (nonatomic, getter=isFullscreen) BOOL fullscreen;
- (CGRect)windowBounds;
@end

@implementation PSPushPopPressView

@synthesize pushPopPressViewDelegate;
@synthesize beingDragged = beingDragged_;
@synthesize fullscreen = fullscreen_;
@synthesize initialFrame = initialFrame_;
@synthesize allowSingleTapSwitch = allowSingleTapSwitch_;
@synthesize ignoreStatusBar = ignoreStatusBar_;

// adapt frame for fullscreen
- (void)detectOrientation {
    if (self.isFullscreen) {
        self.frame = [self windowBounds];
    }
}

- (id)initWithFrame: (CGRect) frame_ {
    if ((self = [super initWithFrame: frame_])) {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;

        scaleTransform_ = CGAffineTransformIdentity;
        rotateTransform_ = CGAffineTransformIdentity;
        panTransform_ = CGAffineTransformIdentity;
        initialFrame_ = frame_;
        allowSingleTapSwitch_ = YES;

        UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget: self action: @selector(pinchPanRotate:)];
        pinchRecognizer.cancelsTouchesInView = NO;
        pinchRecognizer.delaysTouchesBegan = NO;
        pinchRecognizer.delaysTouchesEnded = NO;
        pinchRecognizer.delegate = self;
        [self addGestureRecognizer: pinchRecognizer];

        UIRotationGestureRecognizer* rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget: self action: @selector(pinchPanRotate:)];
        rotationRecognizer.cancelsTouchesInView = NO;
        rotationRecognizer.delaysTouchesBegan = NO;
        rotationRecognizer.delaysTouchesEnded = NO;
        rotationRecognizer.delegate = self;
        [self addGestureRecognizer: rotationRecognizer];

        panRecognizer_ = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(pinchPanRotate:)];
        panRecognizer_.cancelsTouchesInView = NO;
        panRecognizer_.delaysTouchesBegan = NO;
        panRecognizer_.delaysTouchesEnded = NO;
        panRecognizer_.delegate = self;
        panRecognizer_.minimumNumberOfTouches = 2;
        panRecognizer_.maximumNumberOfTouches = 2;
        [self addGestureRecognizer:panRecognizer_];

        tapRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(tap:)];
        tapRecognizer_.delegate = self;
        tapRecognizer_.cancelsTouchesInView = NO;
        tapRecognizer_.delaysTouchesBegan = NO;
        tapRecognizer_.delaysTouchesEnded = NO;
        [self addGestureRecognizer:tapRecognizer_];

        currentTouches_ = [[NSMutableSet alloc] init];

        self.layer.shadowRadius = 15.0f;
        self.layer.shadowOffset = CGSizeMake(5.0f, 5.0f);
        self.layer.shadowOpacity = 0.4f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        self.layer.shadowOpacity = 0.0f;

        // manually track rotations and adapt fullscreen
        // needed if we rotate within a fullscreen animation and miss the autorotate event
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
    }

    return self;
}

- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    pushPopPressViewDelegate = nil;
    currentTouches_ = nil;
}

// don't manipulate initialFrame inside the view
- (void)setFrameInternal:(CGRect)frame {
    [super setFrame:frame];
}

- (void)setInitialFrame:(CGRect)initialFrame {
    initialFrame_ = initialFrame;

    // if we're not in fullscreen, re-set frame
    if (!self.isFullscreen) {
        self.frame = initialFrame;
    }
}

- (UIView *)rootView {
    return self.window.rootViewController.view;
}

- (CGRect)windowBounds {
    // completely fullscreen
    CGRect windowBounds = [self rootView].bounds;

    if (self.ignoreStatusBar) {
        windowBounds = [UIScreen mainScreen].bounds;
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            windowBounds.size.width = windowBounds.size.height;
            windowBounds.size.height = [UIScreen mainScreen].bounds.size.width;
        }
    }
    return windowBounds;
}

- (CGRect)superviewCorrectedInitialFrame {
    UIView *rootView = [self rootView];
    CGRect superviewCorrectedInitialFrame = [rootView convertRect:initialFrame_ fromView:initialSuperview_];
    return superviewCorrectedInitialFrame;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview && self.isBeingDragged) {
        self.beingDragged = NO;

        // do we need to call the delegate?
        BOOL notYetEnded = [currentTouches_ count] >= 2;
        if (notYetEnded) {
            [self.pushPopPressViewDelegate pushPopPressViewDidFinishManipulation:self];
        }
        [currentTouches_ removeAllObjects];
    }
}

- (BOOL)detachViewToWindow:(BOOL)enable {
    BOOL viewChanged = NO;
    UIView *rootView = [self rootView];

    if (enable && !initialSuperview_) {
        initialSuperview_ = self.superview;
        CGRect newFrame = [self.superview convertRect:initialFrame_ toView:rootView];
        [rootView addSubview:self];
        [self setFrameInternal:newFrame];
        viewChanged = YES;
    }else if(!enable) {
        if (initialSuperview_) {
            [initialSuperview_ addSubview:self];
            viewChanged = YES;
        }
        [self setFrameInternal:initialFrame_];
        initialSuperview_ = nil;
    }
    return viewChanged;
}

- (void)updateShadowPath {
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
}

- (void)applyShadowAnimated:(BOOL)animated {
    if(animated) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        anim.fromValue = [NSNumber numberWithFloat:0.0f];
        anim.toValue = [NSNumber numberWithFloat:1.0f];
        anim.duration = kPSShadowFadeDuration;
        [self.layer addAnimation:anim forKey:@"shadowOpacity"];
    }else {
        [self.layer removeAnimationForKey:@"shadowOpacity"];
    }

    [self updateShadowPath];
    self.layer.shadowOpacity = 1.0f;
}

- (void)removeShadowAnimated:(BOOL)animated {
    // TODO: sometimes animates crazy, shadowOpacity animation losses shadowPath transform on certain conditions
    // shadow should also use a "lightSource", maybe it's easier to make a completely custom shadow view.
    if (animated) {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        anim.fromValue = [NSNumber numberWithFloat:1.0f];
        anim.toValue = [NSNumber numberWithFloat:0.0f];
        anim.duration = kPSShadowFadeDuration;
        [self.layer addAnimation:anim forKey:@"shadowOpacity"];
    }else {
        [self.layer removeAnimationForKey:@"shadowOpacity"];
    }

    self.layer.shadowOpacity = 0.0f;
}

- (void)setBeingDragged:(BOOL)newBeingDragged {
    if (newBeingDragged != beingDragged_) {
        beingDragged_ = newBeingDragged;

        if (beingDragged_) {
            [self applyShadowAnimated:YES];
        }else {
            BOOL animate = !self.isFullscreen && !fullscreenAnimationActive_;
            [self removeShadowAnimated:animate];
        }
    }
}

- (void)moveViewToOriginalPositionAnimated:(BOOL)animated bounces:(BOOL)bounces {
    CGFloat bounceX = panTransform_.tx * kPSEmbeddedAnimationBounceMultiplier * -1;
    CGFloat bounceY = panTransform_.ty * kPSEmbeddedAnimationBounceMultiplier * -1;

    // switch coordinates of gestureRecognizer in landscape
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat tmp = bounceY;
        bounceY = bounceX;
        bounceX = tmp;
    }

    __block CGRect correctedInitialFrame = [self superviewCorrectedInitialFrame];
    CGFloat widthDifference = (self.frame.size.width - correctedInitialFrame.size.width) * 0.05;
    CGFloat heightDifference = (self.frame.size.height - correctedInitialFrame.size.height) * 0.05;
    self.fullscreen = NO;

    if ([self.pushPopPressViewDelegate respondsToSelector:@selector(PSPushPopPressViewWillAnimateToOriginalFrame:duration:)]) {
        [self.pushPopPressViewDelegate pushPopPressViewWillAnimateToOriginalFrame:self duration:kPSAnimationMoveToOriginalPositionDuration*1.5f];
    }

    [UIView animateWithDuration:animated ? kPSAnimationMoveToOriginalPositionDuration : 0.f delay: 0.0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         // always reset transforms
                         rotateTransform_ = CGAffineTransformIdentity;
                         panTransform_ = CGAffineTransformIdentity;
                         scaleTransform_ = CGAffineTransformIdentity;
                         self.transform = CGAffineTransformIdentity;

                         if (bounces) {
                             if (abs(bounceX) > 0 || abs(bounceY) > 0) {
                                 CGRect targetFrame = CGRectMake(correctedInitialFrame.origin.x + bounceX + (widthDifference / 2.0), correctedInitialFrame.origin.y + bounceY + (heightDifference / 2.0), correctedInitialFrame.size.width + (widthDifference * -1), correctedInitialFrame.size.height + (heightDifference * -1));
                                 [self setFrameInternal:targetFrame];
                             }else {
                                 // there's reason behind this madness. shadow freaks out when we come from fullscreen, but not if we had transforms.
                                 fullscreenAnimationActive_ = YES;
                                 CGRect targetFrame = CGRectMake(correctedInitialFrame.origin.x + 3, correctedInitialFrame.origin.y + 3, correctedInitialFrame.size.width - 6, correctedInitialFrame.size.height - 6);
                                 //NSLog(@"targetFrame: %@ (superview: %@; initialSuperview: %@)", NSStringFromCGRect(targetFrame), self.superview, self.initialSuperview);
                                 [self setFrameInternal:targetFrame];
                             }
                         }else {
                             [self setFrameInternal:correctedInitialFrame];
                         }
                     }
                     completion: ^(BOOL finished) {
                         //NSLog(@"moveViewToOriginalPositionAnimated [complete] finished:%d, bounces:%d", finished, bounces);
                         fullscreenAnimationActive_ = NO;
                         correctedInitialFrame = [self superviewCorrectedInitialFrame];
                         if (bounces && finished) {
                             [UIView animateWithDuration: kPSAnimationMoveToOriginalPositionDuration/2 delay: 0.0
                                                 options:UIViewAnimationOptionAllowUserInteraction animations: ^{
                                                     [self setFrameInternal:correctedInitialFrame];
                                                 } completion: ^(BOOL finished) {
                                                     if (finished && !self.isBeingDragged) {
                                                         [self detachViewToWindow:NO];
                                                     }
                                                     if ([self.pushPopPressViewDelegate respondsToSelector: @selector(pushPopPressViewDidAnimateToOriginalFrame:)]) {
                                                         [self.pushPopPressViewDelegate pushPopPressViewDidAnimateToOriginalFrame: self];
                                                     }
                                                 }];
                         }else {
                             if (!self.isBeingDragged) {
                                 [self detachViewToWindow:NO];
                             }
                             if ([self.pushPopPressViewDelegate respondsToSelector: @selector(pushPopPressViewDidAnimateToOriginalFrame:)]) {
                                 [self.pushPopPressViewDelegate pushPopPressViewDidAnimateToOriginalFrame: self];
                             }
                         }
                     }];
}

- (void)moveToFullscreenAnimated:(BOOL)animated bounces:(BOOL)bounces {
    if ([self.pushPopPressViewDelegate respondsToSelector: @selector(PSPushPopPressViewWillAnimateToFullscreenWindowFrame:duration:)]) {
        [self.pushPopPressViewDelegate pushPopPressViewWillAnimateToFullscreenWindowFrame: self duration: kPSAnimationDuration];
    }

    BOOL viewChanged = [self detachViewToWindow:YES];
    self.fullscreen = YES;

    __block CGRect windowBounds = [self windowBounds];
    [UIView animateWithDuration: animated ? kPSAnimationDuration : 0.f delay: 0.0
     // view hierarchy change needs some time propagating, don't use UIViewAnimationOptionBeginFromCurrentState when just changed
                        options:(viewChanged ? 0 : UIViewAnimationOptionBeginFromCurrentState) | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         scaleTransform_ = CGAffineTransformIdentity;
                         rotateTransform_ = CGAffineTransformIdentity;
                         panTransform_ = CGAffineTransformIdentity;
                         self.transform = CGAffineTransformIdentity;
                         if (bounces) {
                             [self setFrameInternal:CGRectMake(windowBounds.origin.x - kPSFullscreenAnimationBounce, windowBounds.origin.y - kPSFullscreenAnimationBounce, windowBounds.size.width + kPSFullscreenAnimationBounce*2, windowBounds.size.height + kPSFullscreenAnimationBounce*2)];
                         }else {
                             [self setFrameInternal:[self windowBounds]];
                         }
                     }
                     completion:^(BOOL finished) {
                         windowBounds = [self windowBounds];
                         if (bounces && finished) {
                             [UIView animateWithDuration:kPSAnimationDuration delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
                                 [self setFrameInternal:windowBounds];
                             } completion:^(BOOL finished) {
                                 if ([self.pushPopPressViewDelegate respondsToSelector: @selector(pushPopPressViewDidAnimateToFullscreenWindowFrame:)]) {
                                     [self.pushPopPressViewDelegate pushPopPressViewDidAnimateToFullscreenWindowFrame: self];
                                 }
                             }];
                         }else {
                             if ([self.pushPopPressViewDelegate respondsToSelector: @selector(pushPopPressViewDidAnimateToFullscreenWindowFrame:)]) {
                                 [self.pushPopPressViewDelegate pushPopPressViewDidAnimateToFullscreenWindowFrame: self];
                             }
                         }
                     }];
}

- (void)alignViewAnimated:(BOOL)animated bounces:(BOOL)bounces {
    if (self.frame.size.width > [self windowBounds].size.width) {
        [self moveToFullscreenAnimated:animated bounces:bounces];
    } else {
        [self moveViewToOriginalPositionAnimated:animated bounces:bounces];
    }
}

// disrupt gesture recognizer, which continues to receive touch events even as we set minimumNumberOfTouches to two.
- (void)resetGestureRecognizers {
    panRecognizer_.enabled = NO;
    panRecognizer_.enabled = YES;
}

- (void)startedGesture:(UIGestureRecognizer *)gesture {
    [self detachViewToWindow:YES];
    UIPinchGestureRecognizer *pinch = [gesture isKindOfClass:[UIPinchGestureRecognizer class]] ? (UIPinchGestureRecognizer *)gesture : nil;
    gesturesEnded_ = NO;
    if (pinch) {
        scaleActive_ = YES;
    }
}

/*
 When one gesture ends, the whole view manipulation is ended. In case the user also started a pinch and the pinch is still active, we wait for the pinch to finish as we want to check for a fast pinch movement to open the view in fullscreen or not. If no pinch is active, we can end the manipulation as soon as the first gesture ended.
 */
- (void)endedGesture:(UIGestureRecognizer *)gesture {
    if (gesturesEnded_) return;

    UIPinchGestureRecognizer *pinch = [gesture isKindOfClass:[UIPinchGestureRecognizer class]] ? (UIPinchGestureRecognizer *)gesture : nil;
    if (scaleActive_ == YES && pinch == nil) return;

    gesturesEnded_ = YES;
    if (pinch) {
        scaleActive_ = NO;
        if (pinch.velocity >= 2.0f) {
            [self moveToFullscreenAnimated:YES bounces:YES];
        } else {
            [self alignViewAnimated:YES bounces:YES];
        }
    } else {
        [self alignViewAnimated:YES bounces:YES];
    }
}

- (void)modifiedGesture:(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
        UIPinchGestureRecognizer *pinch = (UIPinchGestureRecognizer *)gesture;
        scaleTransform_ = CGAffineTransformScale(CGAffineTransformIdentity, pinch.scale, pinch.scale);
    }
    else if ([gesture isKindOfClass:[UIRotationGestureRecognizer class]]) {
        UIRotationGestureRecognizer *rotate = (UIRotationGestureRecognizer *)gesture;
        rotateTransform_ = CGAffineTransformRotate(CGAffineTransformIdentity, rotate.rotation);
    }
    else if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gesture;
        CGPoint translation = [pan translationInView: self.superview];
        panTransform_ = CGAffineTransformTranslate(CGAffineTransformIdentity, translation.x, translation.y);
    }

    self.transform = CGAffineTransformConcat(CGAffineTransformConcat(scaleTransform_, rotateTransform_), panTransform_);
}

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];

        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)pinchPanRotate:(UIGestureRecognizer *)gesture {
    [self adjustAnchorPointForGestureRecognizer:gesture];

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            [self startedGesture:gesture];
            break; }
        case UIGestureRecognizerStatePossible: { break; }
        case UIGestureRecognizerStateCancelled: {
            [self endedGesture:gesture];
        } break;
        case UIGestureRecognizerStateFailed: {
        } break;
        case UIGestureRecognizerStateChanged: {
            [self modifiedGesture:gesture];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self endedGesture:gesture];
            break;
        }
    }
}

- (void)tap:(UITapGestureRecognizer *)tap {
    if (self.allowSingleTapSwitch) {
        if (tap.state == UIGestureRecognizerStateEnded) {
            if ([self.pushPopPressViewDelegate respondsToSelector: @selector(pushPopPressViewDidReceiveTap:)]) {
                [self.pushPopPressViewDelegate pushPopPressViewDidReceiveTap: self];
            }

            if (!self.isFullscreen) {
                [self moveToFullscreenWindowAnimated:YES];
            } else {
                [self moveToOriginalFrameAnimated:YES];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    // if the gesture recognizers's view isn't one of our pieces, don't allow simultaneous recognition
    if (gestureRecognizer.view != self)
        return NO;

    // if the gesture recognizers are on different views, don't allow simultaneous recognition
    if (gestureRecognizer.view != otherGestureRecognizer.view)
        return NO;

    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [touch.view isKindOfClass: [UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // sometimes, the system gets confused and doesn't send us touchesEnded/touchesCancelled-Events. Compensate and filter cancelled touches.
    NSSet *cancelledTouches = [currentTouches_ filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"phase = %d", UITouchPhaseCancelled]];
    [currentTouches_ minusSet:cancelledTouches];

    BOOL notYetStarted = [currentTouches_ count] < 2;
    [currentTouches_ unionSet:touches];
    if (notYetStarted && [currentTouches_ count] >= 2) {
        self.beingDragged = YES;
        [self.pushPopPressViewDelegate pushPopPressViewDidStartManipulation: self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.beingDragged = NO;
    BOOL notYetEnded = [currentTouches_ count] >= 2;
    [currentTouches_ minusSet:touches];
    if (notYetEnded && [currentTouches_ count] < 2) {
        [self resetGestureRecognizers];
        [self.pushPopPressViewDelegate pushPopPressViewDidFinishManipulation: self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.beingDragged = NO;
    BOOL notYetEnded = [currentTouches_ count] >= 2;
    [currentTouches_ minusSet:touches];
    if (notYetEnded && [currentTouches_ count] < 2) {
        [self resetGestureRecognizers];
        [self.pushPopPressViewDelegate pushPopPressViewDidFinishManipulation: self];
    }
}

- (void)moveToFullscreenWindowAnimated:(BOOL)animated {
    if (self.isFullscreen) return;

    if ([self.pushPopPressViewDelegate respondsToSelector: @selector(PSPushPopPressViewShouldAllowTapToAnimateToFullscreenWindowFrame:)]) {
        if ([self.pushPopPressViewDelegate pushPopPressViewShouldAllowTapToAnimateToFullscreenWindowFrame: self] == NO) return;
    }

    [self moveToFullscreenAnimated:animated bounces:YES];
}

- (void)moveToOriginalFrameAnimated:(BOOL)animated {
    if (self.isFullscreen == NO) return;

    if ([self.pushPopPressViewDelegate respondsToSelector: @selector(PSPushPopPressViewShouldAllowTapToAnimateToOriginalFrame:)]) {
        if ([self.pushPopPressViewDelegate pushPopPressViewShouldAllowTapToAnimateToOriginalFrame: self] == NO) return;
    }

    [self moveViewToOriginalPositionAnimated:animated bounces:YES];
}

// enable/disable single tap detection
- (void)setAllowSingleTapSwitch:(BOOL)allowSingleTapSwitch {
    if (allowSingleTapSwitch_ != allowSingleTapSwitch) {
        allowSingleTapSwitch_ = allowSingleTapSwitch;
        tapRecognizer_.enabled = allowSingleTapSwitch;
    }
}

@end

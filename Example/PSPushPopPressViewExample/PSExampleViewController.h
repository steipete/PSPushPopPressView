//
//  PSViewController.h
//  PSPushPopPressViewExample
//
//  Created by Peter Steinberger on 11/16/11.
//  Copyright (c) 2011 Peter Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSPushPopPressView.h"

@interface PSExampleViewController : UIViewController <PSPushPopPressViewDelegate> {
    NSUInteger *activeCount_;
    UIView *containerView_;
    PSPushPopPressView *pushPopPressView_;
    PSPushPopPressView *pushPopPressVideoView_;
}

@end

# PSPushPopPressView
PSPushPopPressView is a custom view that provides direct manipulation for your content - like the images and videos in [Our Choice by Push Pop Press](http://pushpoppress.com/ourchoice/). All credit for coming up with the interaction and use of such an interaction goes to Push Pop Press. This view tries to imitate the interaction they have perfected in Our Choice.

Credits go to [Martin Reichart](https://twitter.com/martinr_vienna) by Blacksmith Software, who sent me a initial implementation.

**Be sure to test this on an real iPad, not the Simulator - it's much more awesome to feel it. And use all of your fingers, you can manipulate multiple views concurrently!**

![PSPushPopPressView](http://f.cl.ly/items/2Q1b3e2N0i3Q1J3P232B/photo.png)

Zoom, Rotate, Drag - everything at the same time. In this example, the background is zoomed out and transparency is added while the transform is active.

## Features
* Two-finger direct manipulation support to scale, pan and rotate
* Tap support to go into fullscreen and back to the original frame (delegate can block this individually and this is also disabled if you add a button as a subview and the user tapped the button)
* Fully animates when going into fullscreen or back to the view's original frame
* Semi-realistic bounce effect for scale and position depending on "distance" of view relative to it's target appearance (e.g. when the view needs to move a lot back to it's position there is more bounce than we the view only needs to move a little; also applied to changes in scale)
* Detaches from the current view and docks on the main view, so that your view always expands to the full screen. This is especially useful if you're adding PSPushPopPressView's in a complex view hierarchy.

## ARC
PSPushPopPressView uses ARC and works with iOS 4.0 upwards. You need at least Xcode 4.2 with LLVM 3.0 to compile it.

## How to use it
Create an instance of PSPushPopPressView, insert it into your view hierarchy and you're done.

```objc
    // create the push pop press container
    PSPushPopPressView *pushPopPressView = [[PSPushPopPressView alloc] initWithFrame:CGRectMake(140, 20, 500, 400)];
    pushPopPressView.pushPopPressViewDelegate = self;
    [self.view addSubview:pushPopPressView];
```
You can add any UIView to the container. Just make sure it's autoresizable (else it won't look that great).
Also note that adding subviews which offer userInteraction on their own (e.g. UIWebView or UIScrollView) might mess up the interaction with the view.
    
```objc
    // add a cat image to the push pop press view
    UIImageView *catImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat.jpg"]];
    catImage.frame = pushPopPressView.bounds;
    catImage.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    catImage.clipsToBounds = YES;
    [pushPopPressView addSubview:catImageView];
```

This is just a simple example. In the Example project, there's code how to embed video this way, and also code that 'zooms out' the whole view like you've probably seen in OurChoice.

You can set yourself as a PSPushPopPressView to receive callbacks when the user starts/stops manipulating the view or when the view will/did go into fullscreen or back to it's original frame.


## ToDo/Known Issues
- Shadow animation is tricky, and sometimes the animation looks pretty bad.

- Touches are sometimes not correctly recognized, which leads to manipulation even though the delegates tell you no one's dragging it atm.

- When a animating and rotating at the same time, sometimes the view frame is reset incorrectly.

Don't worry - it works pretty well, and is used for month now in production - people love it!
 

## License
PSPushPopPressView is released under the MIT-license (see the LICENSE file)

## Support / Contact / Bugs / Features

I happily accept pull requests, and feel free to contact [Peter](https://twitter.com/steipete) or [Martin](https://twitter.com/martinr_vienna) on Twitter.
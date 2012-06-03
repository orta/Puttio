//
//  FGalleryPhotoView.m
//  FGallery
//
//  Created by Grant Davis on 5/19/10.
//  Copyright 2011 Grant Davis Interactive, LLC. All rights reserved.
//

#import "FGalleryPhotoView.h"

@interface FGalleryPhotoView (Private)
- (UIImage*)createHighlightImageWithFrame:(CGRect)rect;
- (void)killActivityIndicator;
- (void)startTapTimer;
- (void)stopTapTimer;
- (CGRect)rectAroundPoint:(CGPoint)point atZoomScale:(CGFloat)zoomScale;
@end



@implementation FGalleryPhotoView
@synthesize photoDelegate;
@synthesize imageView;
@synthesize activity = _activity;
@synthesize button = _button;


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	self.userInteractionEnabled = YES;
	self.clipsToBounds = YES;
	self.delegate = self;
	self.contentMode = UIViewContentModeCenter;
	self.maximumZoomScale = 3.0;
	self.minimumZoomScale = 1.0;
	self.decelerationRate = .85;
	self.contentSize = CGSizeMake(frame.size.width, frame.size.height);
	
	// create the image view
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self addSubview:imageView];
	
	// create an activity inidicator
	_activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[self addSubview:_activity];
	
	return self;
}


- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action
{
	self = [self initWithFrame:frame];
	
	// fit them images!
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	
	// disable zooming
	self.minimumZoomScale = 1.0;
	self.maximumZoomScale = 1.0;
	
	// allow buttons to be clicked
	[self setUserInteractionEnabled:YES];
	
	// but don't allow zooming/panning
	self.scrollEnabled = NO;
	
	// create button
	_button = [[UIButton alloc] initWithFrame:CGRectZero];
	[_button setBackgroundColor:[UIColor clearColor]];
	[_button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_button];
	
	// create outline
	[self.layer setBorderWidth:1.0];
	[self.layer setBorderColor:[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:.25] CGColor]];
	
	return self;
}

- (void)resetZoom
{
	_isZoomed = NO;
	[self stopTapTimer];
	[self setZoomScale:self.minimumZoomScale animated:NO];
	[self zoomToRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height ) animated:NO];
	self.contentSize = CGSizeMake(self.frame.size.width * self.zoomScale, self.frame.size.height * self.zoomScale );
}

- (void)setFrame:(CGRect)theFrame
{
	// store position of the image view if we're scaled or panned so we can stay at that point
	CGPoint imagePoint = imageView.frame.origin;
	
	[super setFrame:theFrame];
	
	// update content size
	self.contentSize = CGSizeMake(theFrame.size.width * self.zoomScale, theFrame.size.height * self.zoomScale );
	
	// resize image view and keep it proportional to the current zoom scale
	imageView.frame = CGRectMake( imagePoint.x, imagePoint.y, theFrame.size.width * self.zoomScale, theFrame.size.height * self.zoomScale);
	
	// center the activity indicator
	[_activity setCenter:CGPointMake(theFrame.size.width * .5, theFrame.size.height * .5)];
	
	// update button
	if( _button )
	{
		// resize the button
		_button.frame = CGRectMake(0, 0, theFrame.size.width, theFrame.size.height);
		
		// create a fresh image for button highlight state
		[_button setImage:[self createHighlightImageWithFrame:theFrame] forState:UIControlStateHighlighted];
	}
}


- (UIImage*)createHighlightImageWithFrame:(CGRect)rect
{
	if( rect.size.width == 0 || rect.size.height == 0 ) return nil;
	
	// create a tint layer for the selected state of the button
	UIGraphicsBeginImageContext(CGSizeMake(rect.size.width, rect.size.height));
	CALayer *blankLayer = [CALayer layer];
	[blankLayer setFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
	[blankLayer setBackgroundColor:[[UIColor colorWithRed:0 green:0 blue:0 alpha:.4] CGColor]];
	[blankLayer renderInContext: UIGraphicsGetCurrentContext()];
	UIImage *clearImg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return clearImg;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	
	if (touch.tapCount == 2) {
		[self stopTapTimer];
		
        if (self.zoomScale == self.maximumZoomScale) {
            [self setZoomScale:self.minimumZoomScale animated:YES];
        }else{
            CGPoint tapCenter = [touch locationInView:imageView];
            CGFloat newScale = MIN(self.zoomScale * 1.4, self.maximumZoomScale);
            CGRect maxZoomRect = [self rectAroundPoint:tapCenter atZoomScale:newScale];
            [self zoomToRect:maxZoomRect animated:YES];    
        }
	}
}
- (CGRect)rectAroundPoint:(CGPoint)point atZoomScale:(CGFloat)zoomScale {
    
    // Define the shape of the zoom rect.
    CGSize boundsSize = self.bounds.size;
    
    // Modify the size according to the requested zoom level.
    // For example, if we're zooming in to 0.5 zoom, then this will increase the bounds size
    // by a factor of two.
    CGSize scaledBoundsSize = CGSizeMake(boundsSize.width / zoomScale,
                                         boundsSize.height / zoomScale);
    
    CGRect rect = CGRectMake(point.x - scaledBoundsSize.width / 2,
                             point.y - scaledBoundsSize.height / 2,
                             scaledBoundsSize.width,
                             scaledBoundsSize.height);
    
    return rect;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([[event allTouches] count] == 1 ) {
		UITouch *touch = [[event allTouches] anyObject];
		if( touch.tapCount == 1 ) {
			
			if(_tapTimer ) [self stopTapTimer];
			[self startTapTimer];
		}
	}
}

- (void)startTapTimer
{
	_tapTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:.5] interval:.5 target:self selector:@selector(handleTap) userInfo:nil repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:_tapTimer forMode:NSDefaultRunLoopMode];
	
}
- (void)stopTapTimer
{
	if([_tapTimer isValid])
		[_tapTimer invalidate];
	
	_tapTimer = nil;
}

- (void)handleTap
{
	// tell the controller
	if([photoDelegate respondsToSelector:@selector(didTapPhotoView:)])
		[photoDelegate didTapPhotoView:self];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	if( self.zoomScale == self.minimumZoomScale ) _isZoomed = NO;
	else _isZoomed = YES;
}


- (void)killActivityIndicator
{
	[_activity stopAnimating];
	[_activity removeFromSuperview];
	_activity = nil;
}

- (void)dealloc {
	[self stopTapTimer];
	
	
	[self killActivityIndicator];
	
	
}


@end

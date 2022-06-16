// Popup.m
//
// Created by Jeff Mascia
// Copyright (c) 2013-2014 Kullect Inc. (http://kullect.com)
//
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

#import "Popup.h"

static NSInteger const kAnimationOptionCurveIOS7 = (7 << 16);

PopupLayout PopupLayoutMake(PopupHorizontalLayout horizontal, PopupVerticalLayout vertical)
{
  PopupLayout layout;
  layout.horizontal = horizontal;
  layout.vertical = vertical;
  return layout;
}

const PopupLayout PopupLayoutCenter = { PopupHorizontalLayoutCenter, PopupVerticalLayoutCenter };


@interface NSValue (PopupLayout)
+ (NSValue*)valueWithPopupLayout:(PopupLayout)layout;
- (PopupLayout)PopupLayoutValue;
@end


@interface Popup () {
  // views
  UIView* _backgroundView;
  UIView* _containerView;
  
  // state flags
  BOOL _isBeingShown;
  BOOL _isShowing;
  BOOL _isBeingDismissed;
}

- (void)updateForInterfaceOrientation;
- (void)didChangeStatusBarOrientation:(NSNotification*)notification;

// Used for calling dismiss:YES from selector because you can't pass primitives, thanks objc
- (void)dismiss;

@end


@implementation Popup

@synthesize backgroundView = _backgroundView;
@synthesize containerView = _containerView;
@synthesize isBeingShown = _isBeingShown;
@synthesize isShowing = _isShowing;
@synthesize isBeingDismissed = _isBeingDismissed;


- (void)dealloc {
  [NSObject cancelPreviousPerformRequestsWithTarget:self];

  // stop listening to notifications
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id)init {
  return [self initWithFrame:[[UIScreen mainScreen] bounds]];
}


- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
		self.alpha = 0;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.autoresizesSubviews = YES;
    
    self.shouldDismissOnBackgroundTouch = YES;
    self.shouldDismissOnContentTouch = NO;
    
    self.showType = PopupShowTypeShrinkIn;
    self.dismissType = PopupDismissTypeShrinkOut;
    self.maskType = PopupMaskTypeDimmed;
    self.dimmedMaskAlpha = 0.5;
    
    _isBeingShown = NO;
    _isShowing = NO;
    _isBeingDismissed = NO;
    
    _backgroundView = [[UIView alloc] init];
    _backgroundView.backgroundColor = [UIColor clearColor];
    _backgroundView.userInteractionEnabled = NO;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _backgroundView.frame = self.bounds;
    
    _containerView = [[UIView alloc] init];
    _containerView.autoresizesSubviews = NO;
    _containerView.userInteractionEnabled = YES;
    _containerView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_backgroundView];
    [self addSubview:_containerView];
    
    // register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangeStatusBarOrientation:)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
  }
  return self;
}


#pragma mark - UIView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  
  UIView* hitView = [super hitTest:point withEvent:event];
  if (hitView == self) {
    
    // Try to dismiss if backgroundTouch flag set.
    if (_shouldDismissOnBackgroundTouch) {
      [self dismiss:YES];
    }
    
    // If no mask, then return nil so touch passes through to underlying views.
    if (_maskType == PopupMaskTypeNone) {
      return nil;
    } else {
      return hitView;
    }
    
  } else {
    
    // If view is within containerView and contentTouch flag set, then try to hide.
    if ([hitView isDescendantOfView:_containerView]) {
      if (_shouldDismissOnContentTouch) {
        [self dismiss:YES];
      }
    }
    return hitView;
  }
}


#pragma mark - Class Public

+ (Popup*)popupWithContentView:(UIView*)contentView
{
  Popup* popup = [[[self class] alloc] init];
  popup.contentView = contentView;
  return popup;
}


+ (Popup*) popupWithContentView:(UIView*)contentView
                         showType:(PopupShowType)showType
                      dismissType:(PopupDismissType)dismissType
                         maskType:(PopupMaskType)maskType
         dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
            dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch
{
  Popup* popup = [[[self class] alloc] init];
  popup.contentView = contentView;
  popup.showType = showType;
  popup.dismissType = dismissType;
  popup.maskType = maskType;
  popup.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch;
  popup.shouldDismissOnContentTouch = shouldDismissOnContentTouch;
  return popup;
}


+ (void)dismissAllPopups {
  NSArray* windows = [[UIApplication sharedApplication] windows];
  for (UIWindow* window in windows) {
    [window forEachPopupDoBlock:^(Popup *popup) {
      [popup dismiss:NO];
    }];
  }
}


#pragma mark - Public

- (void)show {
  [self showWithLayout:PopupLayoutCenter];
}


- (void)showWithLayout:(PopupLayout)layout {
  [self showWithLayout:layout duration:0.0];
}


- (void)showWithDuration:(NSTimeInterval)duration {
  [self showWithLayout:PopupLayoutCenter duration:duration];
}


- (void)showWithLayout:(PopupLayout)layout duration:(NSTimeInterval)duration {
  NSDictionary* parameters = @{@"layout" : [NSValue valueWithPopupLayout:layout],
                               @"duration" : @(duration)};
  [self showWithParameters:parameters];
}


- (void)showAtCenter:(CGPoint)center inView:(UIView*)view {
  [self showAtCenter:center inView:view withDuration:0.0];
}


- (void)showAtCenter:(CGPoint)center inView:(UIView *)view withDuration:(NSTimeInterval)duration {
  NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
  [parameters setValue:[NSValue valueWithCGPoint:center] forKey:@"center"];
  [parameters setValue:@(duration) forKey:@"duration"];
  [parameters setValue:view forKey:@"view"];
  [self showWithParameters:[NSDictionary dictionaryWithDictionary:parameters]];
}


- (void)dismiss:(BOOL)animated {
  
  if (_isShowing && !_isBeingDismissed) {
    _isBeingShown = NO;
    _isShowing = NO;
    _isBeingDismissed = YES;
    
    // cancel previous dismiss requests (i.e. the dismiss after duration call).
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];

    [self willStartDismissing];
    
    if (self.willStartDismissingCompletion != nil) {
      self.willStartDismissingCompletion();
    }
    
    dispatch_async( dispatch_get_main_queue(), ^{

      // Animate background if needed
      void (^backgroundAnimationBlock)(void) = ^(void) {
          self->_backgroundView.alpha = 0.0;
      };
      
        if (animated && (self->_showType != PopupShowTypeNone)) {
        // Make fade happen faster than motion. Use linear for fades.
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:backgroundAnimationBlock
                         completion:NULL];
      } else {
        backgroundAnimationBlock();
      }
      
      // Setup completion block
      void (^completionBlock)(BOOL) = ^(BOOL finished) {
        
        [self removeFromSuperview];
        
          self->_isBeingShown = NO;
          self->_isShowing = NO;
          self->_isBeingDismissed = NO;
        
        [self didFinishDismissing];
        
        if (self.didFinishDismissingCompletion != nil) {
          self.didFinishDismissingCompletion();
        }
      };
      
      NSTimeInterval bounce1Duration = 0.13;
      NSTimeInterval bounce2Duration = (bounce1Duration * 2.0);
      
      // Animate content if needed
      if (animated) {
          switch (self->_dismissType) {
          case PopupDismissTypeFadeOut: {
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                self->_containerView.alpha = 0.0;
                             } completion:completionBlock];
            break;
          }
            
          case PopupDismissTypeGrowOut: {
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                self->_containerView.alpha = 0.0;
                               self->_containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             } completion:completionBlock];
            break;
          }
            
          case PopupDismissTypeShrinkOut: {
            [UIView animateWithDuration:0.15
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               self->_containerView.alpha = 0.0;
                               self->_containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                             } completion:completionBlock];
            break;
          }
            
          case PopupDismissTypeSlideOutToTop: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = self->_containerView.frame;
                               finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                               self->_containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            break;
          }
            
          case PopupDismissTypeSlideOutToBottom: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = self->_containerView.frame;
                               finalFrame.origin.y = CGRectGetHeight(self.bounds);
                               self->_containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            break;
          }
            
          case PopupDismissTypeSlideOutToLeft: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = self->_containerView.frame;
                               finalFrame.origin.x = -CGRectGetWidth(finalFrame);
                               self->_containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            break;
          }
            
          case PopupDismissTypeSlideOutToRight: {
            [UIView animateWithDuration:0.30
                                  delay:0
                                options:kAnimationOptionCurveIOS7
                             animations:^{
                               CGRect finalFrame = self->_containerView.frame;
                               finalFrame.origin.x = CGRectGetWidth(self.bounds);
                               self->_containerView.frame = finalFrame;
                             }
                             completion:completionBlock];
            
            break;
          }
            
          case PopupDismissTypeBounceOut: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               self->_containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  self->_containerView.alpha = 0.0;
                                                  self->_containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                                                }
                                                completion:completionBlock];
                             }];
            
            break;
          }
            
          case PopupDismissTypeBounceOutToTop: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = self->_containerView.frame;
                               finalFrame.origin.y += 40.0;
                               self->_containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = self->_containerView.frame;
                                                  finalFrame.origin.y = -CGRectGetHeight(finalFrame);
                                                  self->_containerView.frame = finalFrame;
                                                }
                                                completion:completionBlock];
                             }];
            
            break;
          }
            
          case PopupDismissTypeBounceOutToBottom: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = self->_containerView.frame;
                               finalFrame.origin.y -= 40.0;
                               self->_containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = self->_containerView.frame;
                                                  finalFrame.origin.y = CGRectGetHeight(self.bounds);
                                                  self->_containerView.frame = finalFrame;
                                                }
                                                completion:completionBlock];
                             }];
            
            break;
          }
            
          case PopupDismissTypeBounceOutToLeft: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = self->_containerView.frame;
                               finalFrame.origin.x += 40.0;
                               self->_containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = self->_containerView.frame;
                                                  finalFrame.origin.x = -CGRectGetWidth(finalFrame);
                                                  self->_containerView.frame = finalFrame;
                                                }
                                                completion:completionBlock];
                             }];
            break;
          }
            
          case PopupDismissTypeBounceOutToRight: {
            [UIView animateWithDuration:bounce1Duration
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^(void){
                               CGRect finalFrame = self->_containerView.frame;
                               finalFrame.origin.x -= 40.0;
                               self->_containerView.frame = finalFrame;
                             }
                             completion:^(BOOL finished){
                               
                               [UIView animateWithDuration:bounce2Duration
                                                     delay:0
                                                   options:UIViewAnimationOptionCurveEaseIn
                                                animations:^(void){
                                                  CGRect finalFrame = self->_containerView.frame;
                                                  finalFrame.origin.x = CGRectGetWidth(self.bounds);
                                                  self->_containerView.frame = finalFrame;
                                                }
                                                completion:completionBlock];
                             }];
            break;
          }
            
          default: {
            self.containerView.alpha = 0.0;
            completionBlock(YES);
            break;
          }
        }
      } else {
        self.containerView.alpha = 0.0;
        completionBlock(YES);
      }
      
    });
  }
}


#pragma mark - Private

- (void)showWithParameters:(NSDictionary*)parameters {
  
  // If popup can be shown
  if (!_isBeingShown && !_isShowing && !_isBeingDismissed) {
    _isBeingShown = YES;
    _isShowing = NO;
    _isBeingDismissed = NO;
    
    [self willStartShowing];
    
    dispatch_async( dispatch_get_main_queue(), ^{
      
      // Prepare by adding to the top window.
      if(!self.superview){
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        
        for (UIWindow *window in frontToBackWindows) {
          if (window.windowLevel == UIWindowLevelNormal) {
            [window addSubview:self];
            
            break;
          }
        }
      }
      
      // Before we calculate layout for containerView, make sure we are transformed for current orientation.
      [self updateForInterfaceOrientation];
      
      // Make sure we're not hidden
      self.hidden = NO;
      self.alpha = 1.0;
      
      // Setup background view
        self->_backgroundView.alpha = 0.0;
        if (self->_maskType == PopupMaskTypeDimmed) {
            self->_backgroundView.backgroundColor = [UIColor colorWithRed:(0.0/255.0f) green:(0.0/255.0f) blue:(0.0/255.0f) alpha:self.dimmedMaskAlpha];
      } else {
          self->_backgroundView.backgroundColor = [UIColor clearColor];
      }
      
      // Animate background if needed
      void (^backgroundAnimationBlock)(void) = ^(void) {
          self->_backgroundView.alpha = 1.0;
      };
      
        if (self->_showType != PopupShowTypeNone) {
        // Make fade happen faster than motion. Use linear for fades.
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:backgroundAnimationBlock
                         completion:NULL];
      } else {
        backgroundAnimationBlock();
      }
      
      // Determine duration. Default to 0 if none provided.
      NSTimeInterval duration;
      NSNumber* durationNumber = [parameters valueForKey:@"duration"];
      if (durationNumber != nil) {
        duration = [durationNumber doubleValue];
      } else {
        duration = 0.0;
      }
      
      // Setup completion block
      void (^completionBlock)(BOOL) = ^(BOOL finished) {
          self->_isBeingShown = NO;
          self->_isShowing = YES;
          self->_isBeingDismissed = NO;
        
        [self didFinishShowing];
        
        if (self.didFinishShowingCompletion != nil) {
          self.didFinishShowingCompletion();
        }
        
        // Set to hide after duration if greater than zero.
        if (duration > 0.0) {
          [self performSelector:@selector(dismiss) withObject:nil afterDelay:duration];
        }
      };
      
      // Add contentView to container
      if (self.contentView.superview != self->_containerView) {
        [self->_containerView addSubview:self.contentView];
      }
      
      // Re-layout (this is needed if the contentView is using autoLayout)
      [self.contentView layoutIfNeeded];
      
      // Size container to match contentView
      CGRect containerFrame = self->_containerView.frame;
      containerFrame.size = self.contentView.frame.size;
      self->_containerView.frame = containerFrame;
      // Position contentView to fill it
      CGRect contentViewFrame = self.contentView.frame;
      contentViewFrame.origin = CGPointZero;
      self.contentView.frame = contentViewFrame;
      
      // Reset self->_containerView's constraints in case contentView is uaing autolayout.
        UIView* contentView = self->_contentView;
      NSDictionary* views = NSDictionaryOfVariableBindings(contentView);
      
        [self->_containerView removeConstraints:self->_containerView.constraints];
        [self->_containerView addConstraints:
       [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|"
                                               options:0
                                               metrics:nil
                                                 views:views]];
      
        [self->_containerView addConstraints:
       [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|"
                                               options:0
                                               metrics:nil
                                                 views:views]];
      
      // Determine final position and necessary autoresizingMask for container.
      CGRect finalContainerFrame = containerFrame;
      UIViewAutoresizing containerAutoresizingMask = UIViewAutoresizingNone;
      
      // Use explicit center coordinates if provided.
      NSValue* centerValue = [parameters valueForKey:@"center"];
      if (centerValue != nil) {
        
        CGPoint centerInView = [centerValue CGPointValue];
        CGPoint centerInSelf;
        
        // Convert coordinates from provided view to self. Otherwise use as-is.
        UIView* fromView = [parameters valueForKey:@"view"];
        if (fromView != nil) {
          centerInSelf = [self convertPoint:centerInView fromView:fromView];
        } else {
          centerInSelf = centerInView;
        }
        
        finalContainerFrame.origin.x = (centerInSelf.x - CGRectGetWidth(finalContainerFrame)/2.0);
        finalContainerFrame.origin.y = (centerInSelf.y - CGRectGetHeight(finalContainerFrame)/2.0);
        containerAutoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
      }
      
      // Otherwise use relative layout. Default to center if none provided.
      else {
        
        NSValue* layoutValue = [parameters valueForKey:@"layout"];
        PopupLayout layout;
        if (layoutValue != nil) {
          layout = [layoutValue PopupLayoutValue];
        } else {
          layout = PopupLayoutCenter;
        }
        
        switch (layout.horizontal) {
            
          case PopupHorizontalLayoutLeft: {
            finalContainerFrame.origin.x = 0.0;
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleRightMargin;
            break;
          }
            
          case PopupHorizontalLayoutLeftOfCenter: {
            finalContainerFrame.origin.x = floorf(CGRectGetWidth(self.bounds)/3.0 - CGRectGetWidth(containerFrame)/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            break;
          }
            
          case PopupHorizontalLayoutCenter: {
            finalContainerFrame.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(containerFrame))/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            break;
          }
            
          case PopupHorizontalLayoutRightOfCenter: {
            finalContainerFrame.origin.x = floorf(CGRectGetWidth(self.bounds)*2.0/3.0 - CGRectGetWidth(containerFrame)/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            break;
          }
            
          case PopupHorizontalLayoutRight: {
            finalContainerFrame.origin.x = CGRectGetWidth(self.bounds) - CGRectGetWidth(containerFrame);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin;
            break;
          }
            
          default:
            break;
        }
        
        // Vertical
        switch (layout.vertical) {
            
          case PopupVerticalLayoutTop: {
            finalContainerFrame.origin.y = 0;
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleBottomMargin;
            break;
          }
            
          case PopupVerticalLayoutAboveCenter: {
            finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds)/3.0 - CGRectGetHeight(containerFrame)/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
          }
            
          case PopupVerticalLayoutCenter: {
            finalContainerFrame.origin.y = floorf((CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame))/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
          }
            
          case PopupVerticalLayoutBelowCenter: {
            finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds)*2.0/3.0 - CGRectGetHeight(containerFrame)/2.0);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            break;
          }
            
          case PopupVerticalLayoutBottom: {
            finalContainerFrame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame);
            containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin;
            break;
          }
            
          default:
            break;
        }
      }
      
        self->_containerView.autoresizingMask = containerAutoresizingMask;
      
      // Animate content if needed
        switch (self->_showType) {
        case PopupShowTypeFadeIn: {
          
            self->_containerView.alpha = 0.0;
            self->_containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
            self->_containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.15
                                delay:0
                              options:UIViewAnimationOptionCurveLinear
                           animations:^{
              self->_containerView.alpha = 1.0;
                           }
                           completion:completionBlock];
          break;
        }
          
        case PopupShowTypeGrowIn: {
          
            self->_containerView.alpha = 0.0;
          // set frame before transform here...
          CGRect startFrame = finalContainerFrame;
            self->_containerView.frame = startFrame;
            self->_containerView.transform = CGAffineTransformMakeScale(0.85, 0.85);
          
          [UIView animateWithDuration:0.15
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
              self->_containerView.alpha = 1.0;
                             // set transform before frame here...
              self->_containerView.transform = CGAffineTransformIdentity;
              self->_containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          
          break;
        }
          
        case PopupShowTypeShrinkIn: {
            self->_containerView.alpha = 0.0;
          // set frame before transform here...
          CGRect startFrame = finalContainerFrame;
            self->_containerView.frame = startFrame;
            self->_containerView.transform = CGAffineTransformMakeScale(1.25, 1.25);
          
          [UIView animateWithDuration:0.15
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
              self->_containerView.alpha = 1.0;
                             // set transform before frame here...
              self->_containerView.transform = CGAffineTransformIdentity;
              self->_containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case PopupShowTypeSlideInFromTop: {
            self->_containerView.alpha = 1.0;
            self->_containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.y = -CGRectGetHeight(finalContainerFrame);
            self->_containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.30
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
              self->_containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case PopupShowTypeSlideInFromBottom: {
            self->_containerView.alpha = 1.0;
            self->_containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.y = CGRectGetHeight(self.bounds);
            self->_containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.30
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
              self->_containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case PopupShowTypeSlideInFromLeft: {
            self->_containerView.alpha = 1.0;
            self->_containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.x = -CGRectGetWidth(finalContainerFrame);
            self->_containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.30
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
              self->_containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case PopupShowTypeSlideInFromRight: {
            self->_containerView.alpha = 1.0;
            self->_containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.x = CGRectGetWidth(self.bounds);
            self->_containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.30
                                delay:0
                              options:kAnimationOptionCurveIOS7 // note: this curve ignores durations
                           animations:^{
              self->_containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          
          break;
        }
          
        case PopupShowTypeBounceIn: {
            self->_containerView.alpha = 0.0;
          // set frame before transform here...
          CGRect startFrame = finalContainerFrame;
            self->_containerView.frame = startFrame;
            self->_containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
          
          [UIView animateWithDuration:0.6
                                delay:0.0
               usingSpringWithDamping:0.8
                initialSpringVelocity:15.0
                              options:0
                           animations:^{
              self->_containerView.alpha = 1.0;
              self->_containerView.transform = CGAffineTransformIdentity;
                           }
                           completion:completionBlock];
          
          break;
        }
          
        case PopupShowTypeBounceInFromTop: {
            self->_containerView.alpha = 1.0;
            self->_containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.y = -CGRectGetHeight(finalContainerFrame);
            self->_containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.6
                                delay:0.0
               usingSpringWithDamping:0.8
                initialSpringVelocity:10.0
                              options:0
                           animations:^{
              self->_containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case PopupShowTypeBounceInFromBottom: {
            self->_containerView.alpha = 1.0;
            self->_containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.y = CGRectGetHeight(self.bounds);
            self->_containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.6
                                delay:0.0
               usingSpringWithDamping:0.8
                initialSpringVelocity:10.0
                              options:0
                           animations:^{
              self->_containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case PopupShowTypeBounceInFromLeft: {
            self->_containerView.alpha = 1.0;
            self->_containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.x = -CGRectGetWidth(finalContainerFrame);
            self->_containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.6
                                delay:0.0
               usingSpringWithDamping:0.8
                initialSpringVelocity:10.0
                              options:0
                           animations:^{
              self->_containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        case PopupShowTypeBounceInFromRight: {
            self->_containerView.alpha = 1.0;
            self->_containerView.transform = CGAffineTransformIdentity;
          CGRect startFrame = finalContainerFrame;
          startFrame.origin.x = CGRectGetWidth(self.bounds);
            self->_containerView.frame = startFrame;
          
          [UIView animateWithDuration:0.6
                                delay:0.0
               usingSpringWithDamping:0.8
                initialSpringVelocity:10.0
                              options:0
                           animations:^{
              self->_containerView.frame = finalContainerFrame;
                           }
                           completion:completionBlock];
          break;
        }
          
        default: {
          self.containerView.alpha = 1.0;
          self.containerView.transform = CGAffineTransformIdentity;
          self.containerView.frame = finalContainerFrame;
          
          completionBlock(YES);
          
          break;
        }
      }
      
    });
  }
}


- (void)dismiss {
  [self dismiss:YES];
}


- (void)updateForInterfaceOrientation {
  
  // We must manually fix orientation prior to iOS 8
  if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {

    UIInterfaceOrientation orientation = [[[[[UIApplication sharedApplication] windows] firstObject] windowScene] interfaceOrientation];
    CGFloat angle;
    
    switch (orientation) {
      case UIInterfaceOrientationPortraitUpsideDown:
        angle = M_PI;
        break;
      case UIInterfaceOrientationLandscapeLeft:
        angle = -M_PI/2.0f;;
        
        break;
      case UIInterfaceOrientationLandscapeRight:
        angle = M_PI/2.0f;
        
        break;
      default: // as UIInterfaceOrientationPortrait
        angle = 0.0;
        break;
    }
    
    self.transform = CGAffineTransformMakeRotation(angle);
  }

  self.frame = self.window.bounds;
}


#pragma mark - Notification handlers

- (void)didChangeStatusBarOrientation:(NSNotification*)notification {
  [self updateForInterfaceOrientation];
}


#pragma mark - Subclassing

- (void)willStartShowing {
  
}


- (void)didFinishShowing {
  
}


- (void)willStartDismissing {
  
}


- (void)didFinishDismissing {
  
}

@end




#pragma mark - Categories

@implementation UIView(Popup)


- (void)forEachPopupDoBlock:(void (^)(Popup* popup))block {
  for (UIView *subview in self.subviews)
  {
    if ([subview isKindOfClass:[Popup class]])
    {
      block((Popup *)subview);
    } else {
      [subview forEachPopupDoBlock:block];
    }
  }
}


- (void)dismissPresentingPopup {
  
  // Iterate over superviews until you find a Popup and dismiss it, then gtfo
  UIView* view = self;
  while (view != nil) {
    if ([view isKindOfClass:[Popup class]]) {
      [(Popup*)view dismiss:YES];
      break;
    }
    view = [view superview];
  }
}

@end




@implementation NSValue (PopupLayout)

+ (NSValue *)valueWithPopupLayout:(PopupLayout)layout
{
  return [NSValue valueWithBytes:&layout objCType:@encode(PopupLayout)];
}

- (PopupLayout)PopupLayoutValue
{
  PopupLayout layout;
  
  [self getValue:&layout];
  
  return layout;
}

@end

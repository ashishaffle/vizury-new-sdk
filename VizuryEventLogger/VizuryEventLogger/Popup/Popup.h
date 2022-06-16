// Popup.h
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

#import <UIKit/UIKit.h>

// PopupShowType: Controls how the popup will be presented.
typedef NS_ENUM(NSInteger, PopupShowType) {
	PopupShowTypeNone = 0,
	PopupShowTypeFadeIn,
  PopupShowTypeGrowIn,
  PopupShowTypeShrinkIn,
  PopupShowTypeSlideInFromTop,
  PopupShowTypeSlideInFromBottom,
  PopupShowTypeSlideInFromLeft,
  PopupShowTypeSlideInFromRight,
  PopupShowTypeBounceIn,
  PopupShowTypeBounceInFromTop,
  PopupShowTypeBounceInFromBottom,
  PopupShowTypeBounceInFromLeft,
  PopupShowTypeBounceInFromRight,
};

// PopupDismissType: Controls how the popup will be dismissed.
typedef NS_ENUM(NSInteger, PopupDismissType) {
	PopupDismissTypeNone = 0,
	PopupDismissTypeFadeOut,
  PopupDismissTypeGrowOut,
  PopupDismissTypeShrinkOut,
  PopupDismissTypeSlideOutToTop,
  PopupDismissTypeSlideOutToBottom,
  PopupDismissTypeSlideOutToLeft,
  PopupDismissTypeSlideOutToRight,
  PopupDismissTypeBounceOut,
  PopupDismissTypeBounceOutToTop,
  PopupDismissTypeBounceOutToBottom,
  PopupDismissTypeBounceOutToLeft,
  PopupDismissTypeBounceOutToRight,
};

// PopupHorizontalLayout: Controls where the popup will come to rest horizontally.
typedef NS_ENUM(NSInteger, PopupHorizontalLayout) {
  PopupHorizontalLayoutCustom = 0,
  PopupHorizontalLayoutLeft,
  PopupHorizontalLayoutLeftOfCenter,
  PopupHorizontalLayoutCenter,
  PopupHorizontalLayoutRightOfCenter,
  PopupHorizontalLayoutRight,
};

// PopupVerticalLayout: Controls where the popup will come to rest vertically.
typedef NS_ENUM(NSInteger, PopupVerticalLayout) {
  PopupVerticalLayoutCustom = 0,
	PopupVerticalLayoutTop,
  PopupVerticalLayoutAboveCenter,
  PopupVerticalLayoutCenter,
  PopupVerticalLayoutBelowCenter,
  PopupVerticalLayoutBottom,
};

// PopupMaskType
typedef NS_ENUM(NSInteger, PopupMaskType) {
	PopupMaskTypeNone = 0, // Allow interaction with underlying views.
	PopupMaskTypeClear, // Don't allow interaction with underlying views.
	PopupMaskTypeDimmed, // Don't allow interaction with underlying views, dim background.
};

// PopupLayout structure and maker functions
struct PopupLayout {
  PopupHorizontalLayout horizontal;
  PopupVerticalLayout vertical;
};
typedef struct PopupLayout PopupLayout;

extern PopupLayout PopupLayoutMake(PopupHorizontalLayout horizontal, PopupVerticalLayout vertical);

extern const PopupLayout PopupLayoutCenter;



@interface Popup : UIView

// This is the view that you want to appear in Popup.
// - Must provide contentView before or in willStartShowing.
// - Must set desired size of contentView before or in willStartShowing.
@property (nonatomic, strong) UIView* contentView;

// Animation transition for presenting contentView. default = shrink in
@property (nonatomic, assign) PopupShowType showType;

// Animation transition for dismissing contentView. default = shrink out
@property (nonatomic, assign) PopupDismissType dismissType;

// Mask prevents background touches from passing to underlying views. default = dimmed.
@property (nonatomic, assign) PopupMaskType maskType;

// Overrides alpha value for dimmed background mask. default = 0.5
@property (nonatomic, assign) CGFloat dimmedMaskAlpha;

// If YES, then popup will get dismissed when background is touched. default = YES.
@property (nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;

// If YES, then popup will get dismissed when content view is touched. default = NO.
@property (nonatomic, assign) BOOL shouldDismissOnContentTouch;

// Block gets called after show animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishShowingCompletion)(void);

// Block gets called when dismiss animation starts. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^willStartDismissingCompletion)(void);

// Block gets called after dismiss animation finishes. Be sure to use weak reference for popup within the block to avoid retain cycle.
@property (nonatomic, copy) void (^didFinishDismissingCompletion)(void);

// Convenience method for creating popup with default values (mimics UIAlertView).
+ (Popup*)popupWithContentView:(UIView*)contentView;

// Convenience method for creating popup with custom values.
+ (Popup*)popupWithContentView:(UIView*)contentView
                         showType:(PopupShowType)showType
                      dismissType:(PopupDismissType)dismissType
                         maskType:(PopupMaskType)maskType
         dismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
            dismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;

// Dismisses all the popups in the app. Use as a fail-safe for cleaning up.
+ (void)dismissAllPopups;

// Show popup with center layout. Animation determined by showType.
- (void)show;

// Show with specified layout.
- (void)showWithLayout:(PopupLayout)layout;

// Show and then dismiss after duration. 0.0 or less will be considered infinity.
- (void)showWithDuration:(NSTimeInterval)duration;

// Show with layout and dismiss after duration.
- (void)showWithLayout:(PopupLayout)layout duration:(NSTimeInterval)duration;

// Show centered at point in view's coordinate system. If view is nil use screen base coordinates.
- (void)showAtCenter:(CGPoint)center inView:(UIView*)view;

// Show centered at point in view's coordinate system, then dismiss after duration.
- (void)showAtCenter:(CGPoint)center inView:(UIView *)view withDuration:(NSTimeInterval)duration;

// Dismiss popup. Uses dismissType if animated is YES.
- (void)dismiss:(BOOL)animated;


#pragma mark Subclassing
@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, assign, readonly) BOOL isBeingShown;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, assign, readonly) BOOL isBeingDismissed;

- (void)willStartShowing;
- (void)didFinishShowing;
- (void)willStartDismissing;
- (void)didFinishDismissing;

@end


#pragma mark - UIView Category
@interface UIView(Popup)
- (void)forEachPopupDoBlock:(void (^)(Popup* popup))block;
- (void)dismissPresentingPopup;
@end


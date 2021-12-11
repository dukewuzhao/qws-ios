//
//  UIView+Wen_Additions.h
//  SunDemo
//
//  Created by nil on 14-1-5.
//  Copyright (c) 2014年 温世波. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Wen_Additions)
/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat v_left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat v_top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat v_right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat v_bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat v_width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat v_height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat v_centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat v_centerY;

/**
 * Return the x coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenX;

/**
 * Return the y coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenY;

/**
 * Return the x coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/**
 * Return the y coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/**
 * Return the view frame on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGRect screenFrame;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint v_origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize v_size;

/**
 * Return the width in portrait or the height in landscape.
 */
@property (nonatomic, readonly) CGFloat orientationWidth;

/**
 * Return the height in portrait or the width in landscape.
 */
@property (nonatomic, readonly) CGFloat orientationHeight;

/**
 * Finds the first descendant view (including this view) that is a member of a particular class.
 */
- (UIView*)descendantOrSelfWithClass:(Class)cls;

/**
 * Finds the first ancestor view (including this view) that is a member of a particular class.
 */
- (UIView*)ancestorOrSelfWithClass:(Class)cls;

/**
 * Removes all subviews.
 */
- (void)removeAllSubviews;

/**
 * Calculates the offset of this view from another view in screen coordinates.
 *
 * otherView should be a parent view of this view.
 */
- (CGPoint)offsetFromView:(UIView*)otherView;

/**
 * Set view's layer bound color
 */
- (void)setBorderColor:(UIColor *)borderColor width:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius;

/**
 * The view controller whose view contains this view.
 */
- (UIViewController*)viewController;

@end

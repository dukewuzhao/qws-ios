//
//  G100PageControl.h
//  G100
//
//  Created by yuhanle on 16/7/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

#define G100PAGECONTROL_DID_UPDATE_NOTIFICATION @"G100PageControlDidUpdate"

@protocol G100PagerControlDelegate;

@interface G100PageControl : UIView

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) CGFloat dotRadius;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, copy) NSString *pattern;
@property (nonatomic, weak) id <G100PagerControlDelegate> delegate;

@property (nonatomic, assign) CGSize dotSize;
@property (nonatomic, assign) CGFloat dotSpacing;

- (void)setImage:(UIImage *)normalImage highlightedImage:(UIImage *)highlightedImage forKey:(NSString *)key;

- (void)appearWithDuration:(NSTimeInterval)duration animation:(BOOL)animated;
- (void)dismissWithDuration:(NSTimeInterval)duration animation:(BOOL)animaited;

@end

@protocol G100PagerControlDelegate <NSObject>

@optional
- (BOOL)pageView:(G100PageControl *)pageView shouldUpdateToPage:(NSInteger)newPage;
- (void)pageView:(G100PageControl *)pageView didUpdateToPage:(NSInteger)newPage;

- (void)pageViewDidTapped:(G100PageControl *)pageView;

@end
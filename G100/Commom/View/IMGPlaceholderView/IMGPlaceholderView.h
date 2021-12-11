//
//  IMGPlaceholderView.h
//  IMGPlaceholderView
//
//  Created by yuhanle on 2017/1/12.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIImageView+WebCache.h>

@interface IMGPlaceholderView : UIImageView

- (void)iph_setImageWithURL:(NSURL *)url;

- (void)iph_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)iph_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock;

- (void)iph_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

- (void)iph_setImageWithURL:(NSURL *)url showHUD:(BOOL)showHUD;

- (void)iph_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder showHUD:(BOOL)showHUD;

- (void)iph_setImageWithURL:(NSURL *)url showHUD:(BOOL)showHUD completed:(SDWebImageCompletionBlock)completedBlock;

- (void)iph_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder showHUD:(BOOL)showHUD completed:(SDWebImageCompletionBlock)completedBlock;

@end

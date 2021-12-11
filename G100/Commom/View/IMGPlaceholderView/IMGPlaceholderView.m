//
//  IMGPlaceholderView.m
//  IMGPlaceholderView
//
//  Created by yuhanle on 2017/1/12.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import "IMGPlaceholderView.h"
#import <XXNibBridge/XXNibBridge.h>

@interface IMGPlaceholderView () <XXNibBridge>

@property (nonatomic, weak) IBOutlet UIImageView *img_bgView;
@property (nonatomic, weak) IBOutlet UIImageView *img_logoView;
@property (nonatomic, weak) IBOutlet UIImageView *img_containerView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *img_waitActivitor;
@property (nonatomic, weak) IBOutlet UILabel *img_faildHintLabel;

@end

@implementation IMGPlaceholderView

- (void)setImage:(UIImage *)image {
    self.img_bgView.alpha = 1.0;
    self.img_logoView.alpha = 1.0;
    self.img_containerView.image = image;
    [self.img_waitActivitor stopAnimating];
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [self.img_bgView setContentMode:contentMode];
    [self.img_containerView setContentMode:contentMode];
}

- (void)iph_setImageWithURL:(NSURL *)url {
    [self iph_setImageWithURL:url placeholderImage:nil showHUD:NO completed:nil];
}

- (void)iph_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self iph_setImageWithURL:url placeholderImage:placeholder showHUD:NO completed:nil];
}

- (void)iph_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {
    [self iph_setImageWithURL:url placeholderImage:nil showHUD:NO completed:completedBlock];
}

- (void)iph_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self iph_setImageWithURL:url placeholderImage:placeholder showHUD:NO completed:completedBlock];
}

- (void)iph_setImageWithURL:(NSURL *)url showHUD:(BOOL)showHUD {
    [self iph_setImageWithURL:url placeholderImage:nil showHUD:showHUD completed:nil];
}

- (void)iph_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder showHUD:(BOOL)showHUD {
    [self iph_setImageWithURL:url placeholderImage:nil showHUD:showHUD completed:nil];
}

- (void)iph_setImageWithURL:(NSURL *)url showHUD:(BOOL)showHUD completed:(SDWebImageCompletionBlock)completedBlock {
    [self iph_setImageWithURL:url placeholderImage:nil showHUD:showHUD completed:completedBlock];
}

- (void)iph_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder showHUD:(BOOL)showHUD completed:(SDWebImageCompletionBlock)completedBlock {
    // 是否有占位图
    if (placeholder) {
        self.img_bgView.alpha = 1.0;
        self.img_logoView.alpha = 0.0;
        
        self.img_bgView.image = placeholder;
    }else {
        self.img_bgView.alpha = 1.0;
        self.img_logoView.alpha = 1.0;
    }
    
    // 是否显示HUD 视图
    if (showHUD) {
        [self.img_waitActivitor startAnimating];
    }else {
        [self.img_waitActivitor stopAnimating];
    }
    
    self.img_faildHintLabel.alpha = 0.0;
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.img_waitActivitor stopAnimating];
            
            if (!error) {
                self.img_bgView.alpha = 0.0;
                self.img_logoView.alpha = 0.0;
                self.img_faildHintLabel.alpha = 0.0;
                self.img_containerView.image = image;
            }else {
                self.img_faildHintLabel.alpha = 1.0;
            }
            
            if (completedBlock) {
                completedBlock(image, error, cacheType, imageURL);
            }
        });
    }];
}

@end

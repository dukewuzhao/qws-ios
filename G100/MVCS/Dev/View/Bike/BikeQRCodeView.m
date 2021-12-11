//
//  BikeQRCodeView.m
//  G100
//
//  Created by yuhanle on 16/8/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "BikeQRCodeView.h"
#import "QRCodeGenerator.h"
#import <SDImageCache.h>

@interface BikeQRCodeView ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

@end

@implementation BikeQRCodeView

+ (instancetype)loadViewFromNibWithTitle:(NSString *)title qrcode:(NSString *)qrcode {
    BikeQRCodeView *view = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    [view showOpenQRCodeWithTitle:title qrCode:qrcode];
    return view;
}

- (void)showOpenQRCodeWithTitle:(NSString *)title qrCode:(NSString *)qrCode {
    self.titleLabel.text = title;
    
    NSMutableString *realHttpUrl = [NSMutableString stringWithString:qrCode];
    // 先匹配模板
    if ([qrCode hasContainString:@"{version}"]) {
        // 需要版本号
        realHttpUrl = [[realHttpUrl stringByReplacingOccurrencesOfString:@"{version}" withString:[NSString stringWithFormat:@"V%@", [[G100InfoHelper shareInstance] appVersion]]] mutableCopy];
    }
    
    if ([qrCode hasContainString:@"{platform}"]) {
        // 需要平台
        realHttpUrl = [[realHttpUrl stringByReplacingOccurrencesOfString:@"{platform}" withString:@"ios"] mutableCopy];
    }
    
    qrCode = [realHttpUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    __block UIImage * qrImage = nil;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        if ([[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:qrCode]) {
            qrImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:qrCode];
        }else {
            if ([[SDImageCache sharedImageCache] diskImageExistsWithKey:qrCode]) {
                qrImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:qrCode];
            }else{
                qrImage = [QRCodeGenerator qrImageForString:qrCode
                                                  imageSize:500];
                [[SDImageCache sharedImageCache] storeImage:qrImage forKey:qrCode toDisk:YES];
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.qrImageView.image = qrImage;
            [self.indicatorView stopAnimating];
        });
    });
}

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    [super showInVc:vc view:view animation:animation];
    
    if (![self superview]) {
        self.frame = view.bounds;
        [view addSubview:self];
    }
}

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    [super dismissWithVc:self.popVc animation:animation];
    
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(self.containerView.frame, touchPoint)) {
        return;
    }
    
    [self dismissWithVc:self.popVc animation:YES];
}

@end

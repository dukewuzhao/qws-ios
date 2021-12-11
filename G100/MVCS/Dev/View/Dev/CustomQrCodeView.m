//
//  CustomQrCodeView.m
//  G100
//
//  Created by Tilink on 15/7/10.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "CustomQrCodeView.h"
#import "QRCodeGenerator.h"
#import <SDImageCache.h>

@interface CustomQrCodeView ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorView;

/**
 设备的二维码
 */
@property (copy, nonatomic) NSString *qrNumber;

@end

@implementation CustomQrCodeView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = KEY_WINDOW.bounds;
    
    self.qrLabel.userInteractionEnabled = YES;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] init];
    [longPressGesture addTarget:self action:@selector(copyDeviceQrcodeText:)];
    [self.qrLabel addGestureRecognizer:longPressGesture];
}

-(void)showOpenQRCodeWithVc:(UIViewController *)vc view:(UIView *)view image:(UIImage *)image devName:(NSString *)devName qrCode:(NSString *)qrCode other:(id)other {
    if (!qrCode) {
        return;
    }
    
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
    
    [super showInVc:vc view:view animation:YES];
    [self showOpenQRCodeWithImage:image devName:devName qrCode:qrCode qrNum:nil other:other];
    
    if (![self superview]) {
        [self.indicatorView startAnimating];
        
        [view addSubview:self];
    }
}

- (void)showOpenQRCodeWithVc:(UIViewController *)vc view:(UIView *)view image:(UIImage *)image devName:(NSString *)devName qrCode:(NSString *)qrCode qrNumber:(NSString *)qrNumber other:(id)other
{
    if (!qrCode) {
        return;
    }
    
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
    
    [super showInVc:vc view:view animation:YES];
    [self showOpenQRCodeWithImage:image devName:devName qrCode:qrCode qrNum:qrNumber other:other];
    
    if (![self superview]) {
        [self.indicatorView startAnimating];
        
        [view addSubview:self];
    }
}

-(void)showOpenQRCodeWithImage:(UIImage *)image
                       devName:(NSString *)devName
                        qrCode:(NSString *)qrCode
                         qrNum:(NSString *)qrNum
                         other:(id)other {
    self.devNameLabel.text = devName;
    self.qrLabel.text =  qrNum;
    
    self.qrNumber = qrNum;
    
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
            self.qrCodeImageView.image = qrImage;
            [self.indicatorView stopAnimating];
        });
    });
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.boxView.frame, point)) {
        return;
    }
    
    [super dismissWithVc:self.popVc animation:YES];
    
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

- (void)saveImageToPhoto {
    UIGraphicsBeginImageContextWithOptions(self.boxView.frame.size, NO, 0.0);
    [self.boxView drawViewHierarchyInRect:self.boxView.bounds afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    
    [self dismissWithVc:self.popVc animation:YES];
    [self.popVc showHint:msg];
}

- (void)copyDeviceQrcodeText:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.qrNumber;
        [self.popVc showHint:@"已复制至粘帖板"];
    }
}

- (IBAction)longPress:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self saveImageToPhoto];
    }
}

@end

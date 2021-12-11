//
//  WechatQRView.m
//  G100
//
//  Created by William on 15/10/10.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "WechatQRView.h"

@interface WechatQRView ()

@end

@implementation WechatQRView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = KEY_WINDOW.bounds;
}

- (void)saveImageToPhoto {
    UIImage *wechatQRImage = [UIImage imageNamed:@"ic_weixinqrcode"];
    UIImageWriteToSavedPhotosAlbum(wechatQRImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
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

- (void)showInVc:(UIViewController *)vc view:(UIView *)view animation:(BOOL)animation {
    [super showInVc:vc view:view animation:animation];
    
    if (![self superview]) {
        [view addSubview:self];
    }
}

- (void)dismissWithVc:(UIViewController *)vc animation:(BOOL)animation {
    [super dismissWithVc:vc animation:animation];
    
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

- (IBAction)longPress:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self saveImageToPhoto];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.WechatBoxView.frame, point)) {
        return;
    }
    
    [self dismissWithVc:self.popVc animation:YES];
}

@end

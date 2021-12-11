//
//  ServiceHintView.m
//  G100
//
//  Created by Tilink on 15/4/20.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "ServiceHintView.h"

@implementation ServiceHintView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame = KEY_WINDOW.bounds;
    self.messageView.layer.masksToBounds = YES;
    self.messageView.layer.cornerRadius = 6.0f;
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.text = @"如果在支付过程中遇到问题，请联系客服后重试";
    [self.messageLabel sizeToFit];
    
    [self.iKnowButton setExclusiveTouch:YES];
    [self.iKnowButton setBackgroundImage:[[UIImage imageNamed:@"ic_location_sure_bg"]resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
}

-(NSAttributedString *)hintText {
    NSString * pre = @"如果在支付过程中遇到问题，请联系客服后重试。";
    NSString * mid = @"客服电话：";
    NSString * back = @"400-920-2890";
    NSMutableAttributedString * o = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@\n%@%@", pre, mid, back]];
    UIFont * font = [UIFont systemFontOfSize:18];
    [o addAttributes:@{
                       NSFontAttributeName : font,
                       NSForegroundColorAttributeName:[UIColor blackColor]
                       } range:NSMakeRange(0, pre.length)];
    [o addAttributes:@{
                       NSFontAttributeName : font,
                       NSForegroundColorAttributeName:[UIColor darkGrayColor]
                       } range:NSMakeRange(pre.length + 1, mid.length)];
    [o addAttributes:@{
                       NSFontAttributeName : font,
                       NSForegroundColorAttributeName:MyNavColor
                       } range:NSMakeRange(pre.length + 1 + mid.length, back.length)];
    return o;
}

- (IBAction)iKnowBtnEvent:(UIButton *)sender {
    
    if (_sureEvent) {
        self.sureEvent();
    }
    
    [self dismissWithVc:self.popVc animation:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.messageView.frame, point)) {
        return;
    }
    
    [self dismissWithVc:self.popVc animation:YES];
}

-(void)show {
    // 屏蔽当前页面的所有点击
    [self showInVc:CURRENTVIEWCONTROLLER view:CURRENTVIEWCONTROLLER.view animation:YES];
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

@end

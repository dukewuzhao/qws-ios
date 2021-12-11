//
//  G100MsgAllSelDeleteView.m
//  G100
//
//  Created by yuhanle on 16/3/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MsgAllSelDeleteView.h"

@implementation G100MsgAllSelDeleteView

+ (instancetype)allSelDeleteView {
    G100MsgAllSelDeleteView * msgDeleteView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    return msgDeleteView;
}

- (void)showAllSelDeleteView
{
    self.hidden = NO;
    self.allSelectBtn.selected = NO;
    if ([_delegate respondsToSelector:@selector(msgAllSelDeleteViewWillAppear)]) {
        [_delegate msgAllSelDeleteViewWillAppear];
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height);
    } completion:^(BOOL finished) {
        if ([_delegate respondsToSelector:@selector(msgAllSelDeleteViewDidAppear)]) {
            [_delegate msgAllSelDeleteViewDidAppear];
        }
    }];
}

- (void)hideAllSelDeleteView
{
    self.allSelectBtn.selected = NO;
    if ([_delegate respondsToSelector:@selector(msgAllSelDeleteViewWillDisAppear)]) {
        [_delegate msgAllSelDeleteViewWillDisAppear];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        
        if ([_delegate respondsToSelector:@selector(msgAllSelDeleteViewDidDisAppear)]) {
            [_delegate msgAllSelDeleteViewDidDisAppear];
        }
    }];
}

- (IBAction)allSelectBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if ([_delegate respondsToSelector:@selector(msgAllSelDeleteView:index:sender:)]) {
        [_delegate msgAllSelDeleteView:self index:0 sender:sender];
    }
}

- (IBAction)deleteBtnClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(msgAllSelDeleteView:index:sender:)]) {
        [_delegate msgAllSelDeleteView:self index:1 sender:sender];
    }
}

- (void)allSelectStatus:(BOOL)status {
    self.allSelectBtn.selected = status;    
}

@end

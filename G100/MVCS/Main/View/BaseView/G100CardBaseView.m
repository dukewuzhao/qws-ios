//
//  G100CardBaseView.m
//  G100
//
//  Created by William on 16/6/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100CardBaseView.h"
@interface G100CardBaseView ()

@property (strong, nonatomic) CAShapeLayer *circleLayer;

@property (strong, nonatomic) UIBezierPath *circleSmall;

@property (strong, nonatomic) UIView *selectedMaskView;

@end

@implementation G100CardBaseView

- (void)drawRect:(CGRect)rect {
    // Create the path
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect
//                                                   byRoundingCorners:UIRectCornerAllCorners
//                                                         cornerRadii:CGSizeMake(8.0f, 8.0f)];
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = rect;
//    maskLayer.path = maskPath.CGPath;
//    self.layer.mask = maskLayer;
}

- (void)setNeedSingleCtrl:(BOOL)needSingleCtrl {
    _needSingleCtrl = needSingleCtrl;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_needSingleCtrl) {
        if (![self.selectedMaskView superview]) {
            [self addSubview:self.selectedMaskView];
            [self.selectedMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_needSingleCtrl) {
        if ([self.selectedMaskView superview]) {
            [self.selectedMaskView removeFromSuperview];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!_needSingleCtrl) {
        if ([self.selectedMaskView superview]) {
            [self.selectedMaskView removeFromSuperview];
        }
    }
}

- (UIView *)selectedMaskView {
    if (!_selectedMaskView) {
        _selectedMaskView = [[UIView alloc] init];
        _selectedMaskView.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.1f];
    }
    return _selectedMaskView;
}

@end

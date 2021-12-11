//
//  G100CustomOptions.m
//  G100
//
//  Created by Tilink on 15/3/13.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100CustomOptions.h"

@interface G100CustomOptions ()

// 单选按钮
@property (strong, nonatomic) UIView * blaskView;
@property (assign, nonatomic) BOOL currentSelect;

@end

@implementation G100CustomOptions

-(void)configOptionWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message {
    self.currentSelect = _selected;
    self.frame = frame;
    self.monthLabel.text = title;
    self.priceLabel.text = message;
}

-(void)configUIWithFrame:(CGRect)frame image:(UIImage *)image Title:(NSString *)title message:(NSString *)message {
    self.currentSelect = _selected;
    self.frame = frame;
    self.leftImageView.image = image;
    self.nameLabel.text = title;
    self.bottomLabel.text = message;
}

-(void)configRankWithFrame:(CGRect)frame image:(NSString *)image Title:(NSString *)title {
    self.currentSelect = _selected;
    self.frame = frame;
    self.rankImageView.image = [UIImage imageNamed:image];
    self.rankNameLabel.text = title;
}

-(void)setSelected:(BOOL)selected {
    // 更改button的选中状态
    _selectButton.selected = selected;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!_blaskView) {
        self.blaskView = [[UIView alloc]initWithFrame:self.bounds];
        self.blaskView.backgroundColor = MySelectedColor;
    }

    [self addSubview:self.blaskView];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.blaskView removeFromSuperview];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.frame, point)) {
        return;
    }
    
    [self.blaskView removeFromSuperview];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.frame, point)) {
        return;
    }
    
    [self.blaskView removeFromSuperview];
}

- (IBAction)selectBtnClick:(UIButton *)sender {
    
}

@end

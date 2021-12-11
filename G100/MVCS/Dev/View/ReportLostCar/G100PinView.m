//
//  G100PinView.m
//  G100
//
//  Created by yuhanle on 16/3/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100PinView.h"

@interface G100PinView ()

@property (nonatomic, strong) UIButton * button;

@end

@implementation G100PinView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGRect newFrame = self.frame;
        newFrame.size = CGSizeMake(40, 40);
        self.frame = newFrame;
        
        [self setupView];
    }
    return self;
}

- (void)setupView {
    _button = [UIButton buttonWithType:UIButtonTypeCustom];
    [_button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_button setImage:[[UIImage imageNamed:@"ic_findcar_lost_pin"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self addSubview:_button];
}

- (void)setImage:(NSString *)image {
    [_button setImage:[[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _button.frame = self.bounds;
    _calloutView.center = CGPointMake(self.frame.size.width / 2.0, -_calloutView.frame.size.height / 2.0 - 3);
}

- (void)buttonClick:(UIButton *)button {
    button.selected = !button.selected;
    
    [self setSelected:button.selected animated:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (!_title.length && !_content.length) {
        return;
    }
    
    if (selected) {
        if (self.calloutView == nil) {
            self.calloutView = [[G100PaopaoView alloc] init];
            [self.calloutView showInfoWithTitle:_title content:_content];
            self.calloutView.center = CGPointMake(self.frame.size.width / 2.0, -_calloutView.frame.size.height / 2.0 - 3);
        }
        
        [self addSubview:self.calloutView];
    }else {
        [self.calloutView removeFromSuperview];
        self.calloutView = nil;
    }
    
    _button.selected = selected;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    [self.calloutView removeFromSuperview];
    self.calloutView = nil;
    
    [self setSelected:_button.selected animated:YES];
}

- (void)setContent:(NSString *)content {
    _content = content;
    
    [self.calloutView removeFromSuperview];
    self.calloutView = nil;
    
    [self setSelected:_button.selected animated:YES];
}

- (void)setInfoWithTitle:(NSString *)title content:(NSString *)content {
    _title = title;
    _content = content;
    
    [self.calloutView removeFromSuperview];
    self.calloutView = nil;
    
    [self setSelected:_button.selected animated:YES];
}

@end

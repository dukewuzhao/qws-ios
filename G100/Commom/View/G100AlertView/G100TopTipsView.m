//
//  G100TopTipsView.m
//  G100
//
//  Created by 温世波 on 15/10/29.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100TopTipsView.h"

const CGFloat defaultHeight = 30;

@interface G100TopTipsView ()

@property (strong, nonatomic) UILabel * tipsLable;
@property (strong, nonatomic) UIImageView * rightIndicatorView;
@property (strong, nonatomic) UITapGestureRecognizer * tapGesture;

@property (assign, nonatomic) CGRect tipsLastRect;

@end

@implementation G100TopTipsView

-(instancetype)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)color tips:(NSString *)tips {
    if (frame.size.height < defaultHeight) {
        frame.size.height = defaultHeight;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        self.tips = tips;
        self.tipsBackgroundColor = color;
    }
    
    return self;
}

-(void)setTips:(NSString *)tips {
    if (_tips != tips)
    {
        _tips = [tips copy];
        self.tipsLable.text = tips;
        // 根据tips的内容调整界面UI
        [self updateTipsViewWithTips:tips];
    }
}

-(void)setTipsColor:(UIColor *)tipsColor {
    if (_tipsColor != tipsColor) {
        _tipsColor = [tipsColor copy];
        self.tipsLable.backgroundColor = tipsColor;
    }
}

-(void)setClickEnable:(BOOL)clickEnable {
    if (_clickEnable != clickEnable) {
        _clickEnable = clickEnable;
        if (clickEnable) {
            self.rightIndicatorView.hidden = NO;
            UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction)];
            self.tapGesture = tapGesture;
            [self addGestureRecognizer:tapGesture];
        }else {
            if (_tapGesture) {
                [self removeGestureRecognizer:_tapGesture];
            }
        }
    }
}

-(void)setTipsBackgroundColor:(UIColor *)tipsBackgroundColor {
    if (_tipsBackgroundColor != tipsBackgroundColor) {
        _tipsBackgroundColor = tipsBackgroundColor;
        self.backgroundColor = tipsBackgroundColor;
    }
}

-(void)setEdgeInsetsMargin:(UIEdgeInsets)edgeInsetsMargin {
    __weak UIView * wself = self;
    [_tipsLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(wself).with.insets(edgeInsetsMargin);
    }];
}

-(UILabel *)tipsLable {
    if (!_tipsLable) {
        _tipsLable = [[UILabel alloc]init];
        _tipsLable.translatesAutoresizingMaskIntoConstraints = NO;
        _tipsLable.font = [UIFont systemFontOfSize:16];
        _tipsLable.textColor = [UIColor grayColor];
        _tipsLable.textAlignment = NSTextAlignmentCenter;
        _tipsLable.backgroundColor = [UIColor clearColor];
        [self addSubview:_tipsLable];
        
        UIEdgeInsets padding = UIEdgeInsetsMake(5, 10, 5, 10);
        
        __weak UIView * wself = self;
        [_tipsLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(wself).with.insets(padding);
        }];
    }
    
    return _tipsLable;
}

-(UIImageView *)rightIndicatorView {
    if (!_rightIndicatorView) {
        _rightIndicatorView = [[UIImageView alloc]init];
        _rightIndicatorView.image = [UIImage imageNamed:@"ic_cell_selected"];
        [self addSubview:_rightIndicatorView];
        
        __weak UIView * wself = self;
        [_rightIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(-20);
            make.width.equalTo(@18);
            make.height.equalTo(@15);
            make.centerY.equalTo(wself.mas_centerY);
        }];
    }
    
    return _rightIndicatorView;
}

-(void)tapGestureAction {
    if (_clickEnableBlock) {
        self.clickEnableBlock();
    }
}

-(void)showInView:(UIView *)view animation:(BOOL)animation {
    if (![self superview]) {
        [view addSubview:self];
    }
    
    CGPoint point = view.center;
    
    if (animation)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = point;
                         } completion:^(BOOL isFinshed)
         {
             
         }];
    }
    else
    {
        self.center = point;
    }
}

-(void)showInView:(UIView *)view animation:(BOOL)animation afterHide:(NSTimeInterval)delay finishedBlock:(void (^)())finishedBlock {
    if (![self superview]) {
        [view addSubview:self];
    }
    
    CGPoint point = view.center;
    
    if (animation)
    {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.center = point;
                         } completion:^(BOOL isFinshed)
         {
             
         }];
    }
    else
    {
        self.center = point;
    }
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, delay); // 延时5秒后消失
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_after(time, globalQueue, ^{
        [self dismissWithAnimation:YES];
        
        if (finishedBlock) {
            finishedBlock();
        }
    });
}

-(void)dismissWithAnimation:(BOOL)animation {
    if ([self superview]) {
        
        if (animation)
        {
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.hidden = YES;
                             } completion:^(BOOL isFinshed)
             {
                 [self removeFromSuperview];
             }];
        }
        else
        {
            [self removeFromSuperview];
        }
    }
}

-(void)updateTipsViewWithTips:(NSString *)tips {
    CGRect labelFrame = _tipsLastRect;
    // 先计算出lable的高度
    CGSize labelSize = [tips boundingRectWithSize:CGSizeMake(labelFrame.size.width, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:nil context:nil].size;
    
    CGFloat marginH = labelSize.height > 20 ? labelSize.height - labelFrame.size.height : 0;
    
    CGRect rect = self.frame;
    rect.size.height += marginH;
    self.frame = rect;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    self.tipsLastRect = _tipsLable.frame;
}

@end

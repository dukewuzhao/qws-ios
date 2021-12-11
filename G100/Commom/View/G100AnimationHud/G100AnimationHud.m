//
//  G100AnimationHud.m
//  G100
//
//  Created by 温世波 on 15/11/19.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100AnimationHud.h"

@interface G100AnimationHud ()

@property (weak, nonatomic) IBOutlet UIImageView *animationImageView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@end

@implementation G100AnimationHud

+ (instancetype)animationHud {
    G100AnimationHud * animationHud = [[[NSBundle mainBundle] loadNibNamed:@"G100AnimationHud" owner:self options:nil] lastObject];
    return animationHud;
}

- (void)showInView:(UIView *)view animation:(BOOL)animation {
    self.frame = view.bounds;
    
    if (![self superview]) {
        [view addSubview:self];
    }
    
    if (animation) {
        
    }
    
    [self startAnimationWithTime:1.5];
}

- (void)startAnimation {
    [self startAnimationWithTime:1.5];
}

- (void)dismissWithAnimation:(BOOL)animation {
    [self stopAnimation];
    
    if ([self superview]) {
        [self removeFromSuperview];
    }
}

- (void)startAnimationWithTime:(NSTimeInterval)time {
    NSMutableArray * imgArrays = [NSMutableArray array];
    for (NSInteger i = 0; i <= 21; i++) {
        NSString * imgName = [NSString stringWithFormat:@"ic_animaion%@", @(i)];
        [imgArrays addObject:[UIImage imageNamed:imgName]];
    }
    
    self.animationImageView.animationImages = imgArrays;
    self.animationImageView.animationDuration = time;
    self.animationImageView.animationRepeatCount = 0;
    [self.animationImageView startAnimating];
}

- (void)stopAnimation {
    [self.animationImageView stopAnimating];
}

- (void)setHintText:(NSString *)hintText {
    _hintText = hintText.copy;
    
    self.hintLabel.text = hintText;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

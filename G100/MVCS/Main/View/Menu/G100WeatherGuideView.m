//
//  G100WeatherGuideView.m
//  G100
//
//  Created by yuhanle on 2017/6/5.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100WeatherGuideView.h"

@implementation G100WeatherGuideView

+ (instancetype)loadXibView {
    NSArray *xibView = [[NSBundle mainBundle] loadNibNamed:@"G100WeatherGuideView" owner:nil options:nil];
    return [xibView lastObject];
}

- (IBAction)iKnowEvent:(UIButton *)sender {
    if (_iKnowBlock) {
        self.iKnowBlock();
    }
    
    [self removeFromSuperview];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *aColor = [UIColor whiteColor];
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    
    CGContextAddEllipseInRect(context, CGRectMake((rect.size.width - 240)/2.0, 120, 240, 128)); //椭圆
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end

//
//  G100TrackFuncView.m
//  G100
//
//  Created by 曹晓雨 on 2017/8/21.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100TrackFuncView.h"
@interface G100TrackFuncView()
@property (nonatomic, assign) int currentSpeed;
@end

@implementation G100TrackFuncView

+ (instancetype)loadXibView {
    G100TrackFuncView *xibView = [[[NSBundle mainBundle] loadNibNamed:@"G100TrackFuncView" owner:self options:nil] lastObject];
    xibView.layer.masksToBounds = YES;
    xibView.layer.cornerRadius = 5;
    return xibView;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    self.currentSpeed = 1;
}
- (IBAction)btnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 2) {
        if (self.currentSpeed >= 16) {
            self.currentSpeed = 1;
        }else{
          self.currentSpeed = self.currentSpeed * 2;
        }
        [self.speeddBtn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"speed%d",self.currentSpeed]] forState:UIControlStateNormal];
        if([self.delegate respondsToSelector:@selector(speedBtnClicked:)]){
            [self.delegate speedBtnClicked:self.currentSpeed];
        }
    }
    if ([self.delegate respondsToSelector:@selector(btnClickedWithTag:)]) {
        [self.delegate btnClickedWithTag:btn.tag];
    }
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

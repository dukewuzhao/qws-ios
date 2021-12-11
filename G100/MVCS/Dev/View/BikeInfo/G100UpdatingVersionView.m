//
//  G100UpdatingVersionView.m
//  G100
//
//  Created by 曹晓雨 on 2017/10/23.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100UpdatingVersionView.h"

@implementation G100UpdatingVersionView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.reDetectionBtn.layer.masksToBounds = YES;
    self.reDetectionBtn.layer.cornerRadius = 20.0f;
    
    self.progressView.layer.masksToBounds = YES;
    self.progressView.layer.cornerRadius = 2.0f;
}

+ (instancetype)loadG100UpdatingVersionView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100UpdatingVersionView" owner:self options:nil] lastObject];
}

- (IBAction)reDetectionBtnClicked:(UIButton *)sender {
    if (_bottomBtnBlock) {
        self.bottomBtnBlock();
    }
}

#pragma mark - Public Method
- (void)showUpdateHint:(NSString *)hint warnning:(BOOL)warnning {
    self.hintLabel.text = hint;
    
    if (warnning) {
        self.reDetectionBtn.hidden = NO;
        self.hintLabel.textColor = [UIColor colorWithHexString:@"ff7200"];
    }else {
        self.hintLabel.textColor = [UIColor colorWithHexString:@"959595"];
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

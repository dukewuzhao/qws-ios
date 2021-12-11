//
//  G100FindBikeView.m
//  G100
//
//  Created by sunjingjing on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100FindBikeView.h"
#import "NSDate+TimeString.h"

@implementation G100FindBikeView

+ (instancetype)showView {
    return [[[NSBundle mainBundle] loadNibNamed:@"G100FindBikeView" owner:nil options:nil] firstObject];
}

+ (float)heightWithWidth:(float)width {
    return width * 30/207;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.redDotImageView.hidden = YES;
}

- (void)setDevLostModel:(G100DevFindLostDomain *)devLostModel {
    _devLostModel = devLostModel;
    [self updateUI];
}

- (void)updateUI {
    int day = [NSDate getTimeIntervalDaysFromNowWithDateStr: self.devLostModel.time];
    if (day == 0) {
        self.timeLabel.text = @"今天";
    }else if (day == 1){
        self.timeLabel.text = @"昨天";
    }else{
        self.timeLabel.text = self.devLostModel.time;
    }
    self.recordShow.text = self.devLostModel.desc;
}

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(viewTapToPushRecordFindBikeWithView:)]) {
        [self.delegate viewTapToPushRecordFindBikeWithView:self];
    }
}

@end

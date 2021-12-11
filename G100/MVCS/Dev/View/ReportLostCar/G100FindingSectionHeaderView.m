//
//  G100FindingSectionHeaderView.m
//  G100
//
//  Created by William on 16/4/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100FindingSectionHeaderView.h"
#import "NSDate+TimeString.h"

@interface G100FindingSectionHeaderView ()

@property (strong, nonatomic) IBOutlet UILabel *timeIntervalLabel;

- (IBAction)changeMode:(UIButton *)sender;

@end

@implementation G100FindingSectionHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.changeModeBtn setExclusiveTouch:YES];
}

+ (instancetype)findingSectionHeaderView {
    G100FindingSectionHeaderView * sectionHeaderView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    return sectionHeaderView;
}

- (void)setLostMinute:(NSInteger)minute {
    NSInteger days = minute/(60*24);
    NSInteger hours = minute%(60*24)/60;
    NSInteger minutes = minute%(60*24)%60;
    
    self.timeIntervalLabel.text = [NSString stringWithFormat:@"已寻车%@天%@小时%@分钟",@(days),@(hours),@(minutes)];
}

- (IBAction)changeMode:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(findingSectionHearder:changeModeBtn:)]) {
        [self.delegate findingSectionHearder:self changeModeBtn:sender];
    }
}
@end

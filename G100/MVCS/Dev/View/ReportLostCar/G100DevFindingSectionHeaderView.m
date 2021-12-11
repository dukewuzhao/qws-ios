//
//  G100DevFindingSectionHeaderView.m
//  G100
//
//  Created by William on 16/4/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevFindingSectionHeaderView.h"
#import "NSDate+TimeString.h"

@interface G100DevFindingSectionHeaderView ()

@property (nonatomic, strong) NSString * time;

@end

@implementation G100DevFindingSectionHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

+ (instancetype)findingHeaderWithTime:(NSString *)time {
    G100DevFindingSectionHeaderView * findingHeaderView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
    findingHeaderView.time = time;
    return findingHeaderView;
}

-(void)setTime:(NSString *)time {
    NSString * timeStr = [NSDate getWeekTimeStrWithDateStr:time];
    self.timeLabel.text = timeStr;
}

@end

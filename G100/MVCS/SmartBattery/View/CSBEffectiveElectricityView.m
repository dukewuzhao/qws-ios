//
//  CSBEffectiveElecView.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/13.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "CSBEffectiveElectricityView.h"
#import "CSBCircleView.h"
#import "CSBCycleCircleView.h"

#import "UILabeL+AjustFont.h"
#import "NSDate+TimeString.h"

#import "CSBEffectiveBatteyView.h"
#import "CSBEffectiveBatteryRepeteView.h"

@interface CSBEffectiveElectricityView ()
@property (nonatomic, strong)CSBCircleView *circleView;
@property (nonatomic, strong)CSBCycleCircleView *cycleCircleView;
@property (nonatomic, strong)UIImageView *backImageView;
@property (nonatomic, strong)CSBEffectiveBatteyView *batteryView;
@property (nonatomic, strong)CSBEffectiveBatteryRepeteView *batteryRepeteView;
@end
@implementation CSBEffectiveElectricityView

+ (instancetype)showView
{
    CSBEffectiveElectricityView *view = [[[NSBundle mainBundle]loadNibNamed:@"CSBEffectiveElectricityView" owner:nil options:nil] lastObject];
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.circleView = [[CSBCircleView alloc]initWithFrame:CGRectZero];
    self.circleView.progress = 0;
    [self.circleBackView addSubview:self.circleView];
    
    self.cycleCircleView = [[CSBCycleCircleView alloc]initWithFrame:CGRectZero];
    [self.circleBackView addSubview:self.cycleCircleView];
    self.cycleCircleView.hidden = YES;
    
    
    self.batteryView = [CSBEffectiveBatteyView showView];
    self.batteryView.frame = CGRectMake(0, 0, self.batteryBackView.frame.size.width, self.batteryBackView.frame.size.height);
    
    
    self.batteryRepeteView = [CSBEffectiveBatteryRepeteView showView];
    self.batteryRepeteView.frame = CGRectMake(0, 0, self.batteryBackView.frame.size.width, self.batteryBackView.frame.size.height);

    
    _backImageView = [[UIImageView alloc]init];
    [self addSubview:_backImageView];
    [_backImageView setImage:[UIImage imageNamed:@"circlePattern"]];
    
    [UILabel adjustAllLabel:self multiple:0.5];
    
    [self.circleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.bottom.equalTo(self.circleBackView);
    }];
    
    [self.cycleCircleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.left.bottom.equalTo(self.circleBackView);
    }];
    
    [_backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.cycleCircleView);
    }];
}

- (void)setShowBackImgView:(BOOL)showBackImgView
{
    if (!showBackImgView) {
        _backImageView.hidden = YES;
    }
}
-(void)setType:(CircleViewType)type
{
    _type = type;
    
    if (type == DefaultCircleView) {
        self.circleView.hidden = NO;
        self.cycleCircleView.hidden = YES;
         [self.batteryBackView addSubview:self.batteryView];
    }else
    {
        self.circleView.hidden = YES;
        self.cycleCircleView.hidden = NO;
        [self.batteryBackView addSubview:self.batteryRepeteView];
    }
}

- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain
{
    _batteryDomain = batteryDomain;
    
    self.circleView.batteryDomain = _batteryDomain;
    self.cycleCircleView.batteryDomain = _batteryDomain;
    self.batteryRepeteView.batteryDomain = _batteryDomain;
    self.batteryView.batteryDomain = _batteryDomain;
    
    self.batteryTypeLabel.text = [_batteryDomain getBatteryType];
    self.batteyVoltageLabel.text = [NSString stringWithFormat:@"%.2f", _batteryDomain.rated_v];

    self.batteryUsedTimeLabel.text = [NSString stringWithFormat:@"您的电池已使用了%@",[NSDate getDateIntervalWithDays:_batteryDomain.use_duration]];
    
    if (self.type == DefaultCircleView) {
        if (_batteryDomain.performance.valid_c * 1.00/ _batteryDomain.performance.rated_c < 0.3) {
            self.hintView.hidden = NO;
            if (!self.circleView.hidden) {
                self.hintView.text = @"电池有效率已低于30%,已严重损耗建议更换电池";
            }
        }else {
            self.hintView.text = @"";
        }
    }else if (self.type == CycleCircleView) {
        if (_batteryDomain.use_cycle.use_num >= _batteryDomain.use_cycle.rated_num) {
            if (!self.cycleCircleView.hidden) {
                self.hintView.text = [NSString stringWithFormat:@"电池循环次数已满%ld次,建议更换电池", _batteryDomain.use_cycle.rated_num];
            }
        }else {
            self.hintView.text = @"";
        }
    }else {
        self.hintView.text = @"";
    }
}

- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain animated:(BOOL)animated {
    [self setBatteryDomain:batteryDomain];
    
    if (self.type == DefaultCircleView) {
        [self.circleView setBatteryDomain:batteryDomain animated:animated];
    }else if (self.type == CycleCircleView) {
        [self.cycleCircleView setBatteryDomain:batteryDomain animated:animated];
    }else {
        
    }
}

- (IBAction)helpBtnAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(helpBtnClicked)]) {
        [self.delegate helpBtnClicked];
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

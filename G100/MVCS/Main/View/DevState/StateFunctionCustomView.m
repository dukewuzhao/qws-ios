//
//  StateFunctionCustomView.m
//  G100
//
//  Created by William on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "StateFunctionCustomView.h"
#import "XXNibBridge.h"
#import "G100ClickEffectView.h"
#import "UIImage+Tint.h"

#define ImageTintColor [UIColor colorWithRed:0.00 green:0.76 blue:0.64 alpha:1.00]

@interface StateFunctionCustomView () <XXNibBridge, G100TapAnimationDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *first;
@property (strong, nonatomic) IBOutlet UIImageView *second;
@property (strong, nonatomic) IBOutlet UIImageView *third;
@property (strong, nonatomic) IBOutlet UIImageView *plus;
@property (strong, nonatomic) IBOutlet UILabel *dayUnitLabel;
@property (strong, nonatomic) IBOutlet UILabel *remainderLabel;
@property (strong, nonatomic) IBOutlet UILabel *functionLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *firstWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *secondWidthConstraint;
@property (strong, nonatomic) IBOutlet G100ClickEffectView *clickEffectView;

@property (strong, nonatomic) UIView *expiredTipsView;

@end

@implementation StateFunctionCustomView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clickEffectView.delegate = self;
    self.remainderLabel.font = [UIFont systemFontOfSize:11];
    self.functionLabel.font = [UIFont systemFontOfSize:12];
    self.plus.image = [[UIImage imageNamed:@"gps_plus"]imageWithTintColor:ImageTintColor];
    _dayUnitLabel.textColor = ImageTintColor;
}

+ (instancetype)loadStateFunctionCustomView {
    return [[[NSBundle mainBundle] loadNibNamed:@"StateFunctionCustomView" owner:self options:nil]lastObject];
}

#pragma mark - G100TapAnimationDelegate
- (void)viewTouchedEndWithView:(UIView *)touchedView touchPoint:(CGPoint)point{
    if (self.tapAction) {
        self.tapAction();
    }
    //self.left_days = arc4random()%50;
}

- (void)setLeft_days:(NSInteger)left_days {
    _left_days = left_days;
    
    if (left_days <= 0) {
        // 服务已过期
        if (![self.expiredTipsView superview]) {
            [self insertSubview:self.expiredTipsView belowSubview:self.clickEffectView];
            
            [self.expiredTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        self.first.hidden = YES;
        self.second.hidden = YES;
        self.third.hidden = YES;
        self.plus.hidden = YES;
        self.dayUnitLabel.hidden = YES;
        self.remainderLabel.hidden = YES;
        self.functionLabel.hidden = YES;
        
        self.expiredTipsView.hidden = NO;
        
        return;
    }else {
        self.first.hidden = NO;
        self.second.hidden = NO;
        self.third.hidden = NO;
        self.plus.hidden = NO;
        self.dayUnitLabel.hidden = NO;
        self.remainderLabel.hidden = NO;
        self.functionLabel.hidden = NO;
        
        self.expiredTipsView.hidden = YES;
    }
    
    if (left_days > 999) {
        self.plus.hidden = NO;
        _dayUnitLabel.textColor = ImageTintColor;
        UIImage * num9 = [[UIImage imageNamed:@"gps_num9"]imageWithTintColor:ImageTintColor];
        
        self.first.image = num9 ;
        self.second.image = num9 ;
        self.third.image = num9;
        self.firstWidthConstraint.constant = self.secondWidthConstraint.constant = 12;
    }else{
        self.plus.hidden = YES;
        if (left_days <= 999 && left_days > 99) {
              _dayUnitLabel.textColor = ImageTintColor;
            self.firstWidthConstraint.constant = self.secondWidthConstraint.constant = 12;
            UIImage * firstImage = [[UIImage imageNamed:[NSString stringWithFormat:@"gps_num%@",@(left_days/100)]] imageWithTintColor:ImageTintColor];
            UIImage * secondImage = [[UIImage imageNamed:[NSString stringWithFormat:@"gps_num%@",@(left_days%100/10)]] imageWithTintColor:ImageTintColor];
            UIImage * thirdImage = [[UIImage imageNamed:[NSString stringWithFormat:@"gps_num%@",@(left_days%100%10)]] imageWithTintColor:ImageTintColor];
            self.first.image = firstImage;
            self.second.image = secondImage;
            self.third.image = thirdImage;
        }else{
            self.firstWidthConstraint.constant = 0;
            if (left_days <= 99 && left_days > 9) {
                self.secondWidthConstraint.constant = 12;
                UIImage * secondImage = [[UIImage imageNamed:[NSString stringWithFormat:@"gps_num%@",@(left_days/10)]]imageWithTintColor:ImageTintColor];
                UIImage * thirdImage = [[UIImage imageNamed:[NSString stringWithFormat:@"gps_num%@",@(left_days%10)]]imageWithTintColor:ImageTintColor];
                if (left_days <= 15) {
                    self.second.image = [secondImage imageWithTintColor:[UIColor colorWithHexString:@"fff000"]];
                    self.third.image = [thirdImage imageWithTintColor:[UIColor colorWithHexString:@"fff000"]];
                    _dayUnitLabel.textColor = [UIColor colorWithHexString:@"fff000"];
                }else{
                    self.second.image = secondImage;
                    self.third.image = thirdImage;
                }
            }else if (left_days <= 9) {
                self.secondWidthConstraint.constant = 0;
                UIImage * thirdImage = [UIImage imageNamed:[NSString stringWithFormat:@"gps_num%@",@(left_days)]];
                self.third.image = [thirdImage imageWithTintColor:[UIColor colorWithHexString:@"fff000"]];
                _dayUnitLabel.textColor = [UIColor colorWithHexString:@"fff000"];

            }
        }
    }
}

- (UIView *)expiredTipsView {
    if (!_expiredTipsView) {
        _expiredTipsView = [[UIView alloc] init];
        _expiredTipsView.backgroundColor = [UIColor clearColor];
        
        UILabel *expiredLabel = [[UILabel alloc] init];
        expiredLabel.text = @"已过期";
        expiredLabel.textColor = [UIColor colorWithHexString:@"FFF100"];
        expiredLabel.font = [UIFont boldSystemFontOfSize:17];
        
        [_expiredTipsView addSubview:expiredLabel];
        
        UILabel *hintLabel = [[UILabel alloc] init];
        hintLabel.text = @"流量服务";
        hintLabel.textColor = [UIColor colorWithRed:0.66 green:0.66 blue:0.66 alpha:1.00];
        hintLabel.font = [UIFont systemFontOfSize:12];
        
        [_expiredTipsView addSubview:hintLabel];
        
        [expiredLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@15);
            make.height.equalTo(@36);
            make.centerX.equalTo(_expiredTipsView);
        }];
        
        [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(expiredLabel.mas_bottom).with.offset(5);
            make.centerX.equalTo(_expiredTipsView);
        }];
    }
    return _expiredTipsView;
}

@end

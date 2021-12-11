//
//  G100DevInfoView.m
//  G100
//
//  Created by William on 16/7/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevInfoView.h"

@interface G100DevInfoView ()

@property (strong, nonatomic) IBOutlet UILabel *batteryLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *accStateLabel;

@end

@implementation G100DevInfoView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, -3);
    self.layer.shadowOpacity = 0.6;
    self.layer.shadowRadius = 3;
}

+ (instancetype)loadDevInfoView {
    return [[[NSBundle mainBundle]loadNibNamed:@"G100DevInfoView" owner:self options:nil]lastObject];
}

- (void)setBattery:(CGFloat)battery {
    _battery = battery;
    
    if (battery <= 0) {
        self.batteryLabel.text = @"--";
    }else{
        self.batteryLabel.text = [NSString stringWithFormat:@"%d", (int)(battery*100)];
    }
}

- (void)setDistance:(CGFloat)distance {
    _distance = distance;
    
    if (distance == -1) {
        self.distanceLabel.text = @"--";
        return;
    }
    
    NSInteger mileN = (NSInteger)distance;
    CGFloat mileD = distance-mileN;
    NSInteger mileDN = mileD *10;
    
    NSString *result = nil;
    if (distance >= 10) {
        result = [NSString stringWithFormat:@"%d", (int)distance];
    }else if (distance < 1.0 && distance >= 0) {
        NSInteger dotNum;
        if (mileDN == 0) {
            dotNum = 0;
        }else {
            dotNum = 5;
        }

        result = [NSString stringWithFormat:@"%.1f", dotNum/10.0];
    }else {
        NSInteger dotNum;
        if (mileDN >= 0 && mileDN < 5) {
            dotNum = 0;
        }else if (mileDN >= 5 && mileDN < 10) {
            dotNum = 5;
        }else {
            dotNum = 10;
        }
        
        CGFloat tmp = mileN + dotNum/10.0;
        result = [NSString stringWithFormat:@"%.1f", tmp/1.0];
    }
    
    self.distanceLabel.text = result;
}

- (void)setAccState:(BOOL)accState {
    _accState = accState;
    
    if (!accState) {
        self.accStateLabel.textColor = [UIColor whiteColor];
        self.accStateLabel.backgroundColor = [UIColor blackColor];
    }else {
        self.accStateLabel.textColor = [UIColor blackColor];
        self.accStateLabel.backgroundColor = [UIColor whiteColor];
    }
    self.accStateLabel.text = accState?@"已打开":@"已关闭";
}

@end

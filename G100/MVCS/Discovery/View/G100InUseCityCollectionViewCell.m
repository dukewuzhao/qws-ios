//
//  G100InUseCityCollectionViewCell.m
//  G100
//
//  Created by 天奕 on 15/12/25.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100InUseCityCollectionViewCell.h"
#import "G100ServiceCityDataDomain.h"

@implementation G100InUseCityCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setLabelText:(NSString *)text {
    self.inUseCityLabel.text = text;
}

- (void)setCityDomain:(G100ServiceCityDomain *)cityDomain {
    _cityDomain = cityDomain;
    
    self.inUseCityLabel.text = cityDomain.city;

    if (cityDomain.serviceflag == 0) {
        self.noUseCityFlag.hidden = NO;
        self.noUseCityFlag.text = @"未开通";
    }else if (cityDomain.serviceflag == 1) {
        self.noUseCityFlag.hidden = YES;
    }else if (cityDomain.serviceflag == 2) {
        self.noUseCityFlag.hidden = NO;
        self.noUseCityFlag.text = @"即将开通";
    }else {
        self.noUseCityFlag.hidden = YES;
    }
}

@end

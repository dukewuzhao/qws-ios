//
//  G100WeatherGuideView.h
//  G100
//
//  Created by yuhanle on 2017/6/5.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"

@interface G100WeatherGuideView : G100PopBoxBaseView

@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (copy, nonatomic) void (^iKnowBlock)();

+ (instancetype)loadXibView;

@end

//
//  G100NoWeatherView.h
//  G100
//
//  Created by sunjingjing on 16/7/12.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100NoWeatherView : UIView

/**
 *  初始化动画imageView
 */
@property (weak, nonatomic) IBOutlet UIImageView *aniImageView;


@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

+ (instancetype)showView;

@end

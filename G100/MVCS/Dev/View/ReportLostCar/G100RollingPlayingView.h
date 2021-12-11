//
//  G100RollingPlayingView.h
//  G100
//
//  Created by William on 16/4/15.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100RollingPlayingView : UIScrollView

@property (nonatomic, strong) UILabel * rollingLabel;

- (void)setRollingText:(NSString*)text;

@end

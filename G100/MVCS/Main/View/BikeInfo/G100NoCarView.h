//
//  G100NoCarView.h
//  G100
//
//  Created by sunjingjing on 16/7/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100CardBaseView.h"
#import "G100ClickEffectView.h"

@protocol G100AddCarDelegate <NSObject>

@optional
- (void)buttonClickedToAddCar:(UIButton *)button;
- (void)viewTouchedToPushWithView:(UIView *)touchedView;

@end

@interface G100NoCarView : UIView <G100TapAnimationDelegate>

@property(nonatomic,weak) id<G100AddCarDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *mapStaticView;
@property (weak, nonatomic) IBOutlet UILabel *noLabel;

+ (instancetype)showView;

@end

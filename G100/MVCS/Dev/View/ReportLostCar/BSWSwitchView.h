//
//  BSWSwitchView.h
//  G100
//
//  Created by yuhanle on 16/3/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BSWSwitchView;
@protocol BSWSwitchViewDelegate <NSObject>

@optional
- (void)bswSwitchViewValueChanged:(BSWSwitchView *)switchView index:(NSInteger)index;

-(void)bswSwitchViewClick:(BSWSwitchView *)switchView sender:(UIButton *)button;

@end

@interface BSWSwitchView : UIView

+ (instancetype)switchView;

@property (nonatomic, weak) id <BSWSwitchViewDelegate> delegate;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSArray * dataArray;

- (void)setTitleLabelText:(NSString *)titleText;

@end

//
//  G100TopHintView.h
//  G100
//
//  Created by 曹晓雨 on 2017/4/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol G100TopViewClickActionDelegate <NSObject>

- (void)topViewClicked;

@end

@interface G100TopHintView : UIView

/** view的背景颜色 */
@property (nonatomic, strong) NSString *hintText;

@property (nonatomic, strong) UIColor *viewBackgroudColor;
/** 文字颜色 */
@property (nonatomic, strong) UIColor *labelTextColor;
/** 文字字体 */
@property (nonatomic, strong) UIFont *lableTextFont;

/**点击view触发方法 */
@property (nonatomic, assign) id<G100TopViewClickActionDelegate> delegate;

/**
 初始化一个topView

 @param hintText view上label的文字
 @return
 */
- (instancetype)initWithDefaultHintText;

/**
 获取topView的高度

 @return
 */
- (CGFloat)getHeightOfTopHintView;

@end

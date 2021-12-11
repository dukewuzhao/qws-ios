//
//  G100MyInsurancesHeaderView.h
//  G100
//
//  Created by 曹晓雨 on 2016/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PageControlAlignmentCenter, //默认
    PageControlAlignmentRight
} PageControlAlignment;

@class G100ScrollView;
@protocol G100ScrollViewDelegate <NSObject>

- (void)selectedScrollViewAtIndex:(NSInteger)index OnScrollView:(G100ScrollView *)scrollView;

@end

@interface G100ScrollView : UIView

@property (nonatomic, strong) NSArray *imageUrlArr;

@property (nonatomic, assign) CGFloat autoScrollInterval;

@property (nonatomic, assign) PageControlAlignment pageControlAlignment;

@property (nonatomic, assign) BOOL pageControlHidden;

@property (nonatomic, weak) id <G100ScrollViewDelegate> delegate;

/**
 创建轮播图

 @param frame 轮播图的frame
 @param imageArr 图片数组 支持本地图片和url String
 @return
 */
+ (instancetype)createScrollViewWithFrame:(CGRect)frame imagesArr:(NSArray *)imageArr;

/**
  创建轮播图

 @param frame 轮播图的frame
 @param imageUrl 图片数组 支持本地图片和url String
 @return 
 */
+ (instancetype)createScrollViewWithFrame:(CGRect)frame imageUrlArr:(NSArray *)imageUrl;

@end

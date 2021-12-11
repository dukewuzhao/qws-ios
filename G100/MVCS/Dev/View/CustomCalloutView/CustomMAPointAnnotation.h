//
//  CustomMAPointAnnotation.h
//  G100
//
//  Created by Tilink on 15/10/10.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "PositionDomain.h"

@interface CustomMAPointAnnotation : MAPointAnnotation

@property (assign, nonatomic) BOOL isVisible; //!< 标注是否可见 默认可见
@property (assign, nonatomic) BOOL isCenter; //!< 判断选中后是否在屏幕中央
@property (assign, nonatomic) BOOL selected; //!< 标注是否选中
@property (assign, nonatomic) int type; //!< 0：起点 1：终点 2：人 3：车 4：途经点 5：丢车点 6：找车位置
@property (assign, nonatomic) int degree; //!< 标注当前位置角度

@property (nonatomic, assign) NSInteger index; //!< 选择设备的索引序号 用于GPS页面 0开始

@property (strong, nonatomic) PositionDomain * positionDomain; //!< 标注点传递的callout吹出框显示的信息

@end

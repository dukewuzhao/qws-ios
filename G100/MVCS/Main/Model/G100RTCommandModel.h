//
//  G100RTCommandModel.h
//  G100
//
//  Created by yuhanle on 2017/4/18.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface G100RTCommandModel : NSObject

@property (nonatomic, assign) BOOL rt_dots; //!< 是否有小红点
@property (nonatomic, assign) BOOL rt_empty; //!< 是否是空键
@property (nonatomic, assign) int rt_status; //!< 当前选中的控制器模式 0 无 1 蓝牙 2 GPS
@property (nonatomic, assign) int rt_command; //!< 指令id
@property (nonatomic, assign) int rt_type; // 指令type
@property (nonatomic, copy) NSString *rt_image; //!< 图片资源名
@property (nonatomic, copy) NSString *rt_title; //!< 标题
@property (nonatomic, assign) BOOL rt_enable; //!< 是否可点击
@property (nonatomic, copy) NSString *tintColorStr; //!< 图片渲染颜色

+ (instancetype)rt_commandEmpty;
+ (instancetype)rt_commandModelWithTitle:(NSString *)rt_Title image:(NSString *)rt_Image command:(int)rt_Command;

@end

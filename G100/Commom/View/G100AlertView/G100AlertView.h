//
//  G100AlertView.h
//  G100
//
//  Created by Tilink on 15/2/9.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100PopBoxBaseView.h"

#define KROWHEIGHT 60

typedef enum : NSUInteger {
    G100AlertViewStyleDefault = 0,
    G100AlertViewStyleInput,
    G100AlertViewDatePicker,
    G100AlertViewDelayService,
    G100AlertViewDevSelect,
    G100AlertViewRankView,
    G100AlertViewCitySelect
} G100AlertViewStyle;
typedef void(^G100Alert)();
typedef void(^G100AlertObject) (id obj);
typedef void(^G100AlertTf)(NSInteger index, NSString * string); // 用于textfield回传

@interface G100AlertView : G100PopBoxBaseView

@property (copy, nonatomic) G100Alert alertBlock;
@property (copy, nonatomic) G100AlertObject alertObject;
@property (copy, nonatomic) G100AlertTf alertBlockTF;
@property (copy, nonatomic) NSString * title;
@property (copy, nonatomic) NSString * message;

@property (assign, nonatomic) G100AlertViewStyle alertStyle;
@property (assign, nonatomic) NSInteger maxCount;

// shows popup alert animated.
- (void)show;

- (void)hide;

// 快速创建
/**
 确定 1  取消 0
 */
+ (void)G100AlertWithTitle:(NSString *)title message:(NSString *)message alertBlock:(G100Alert)alertBlock;
/**
 修改头像 && 性别
 */
+ (void)G100AlertWithTitle:(NSString *)title alertBlock:(G100Alert)alertBlock btnTitleArr:(NSArray *)btnTitle;
/**
 昵称修改
 */
+ (instancetype)G100AlertWithTitle:(NSString *)title placehoder:(NSString *)holder alertBlock:(G100AlertTf)alertBlock;
/**
 生日选择 picker
 */
+ (void)G100DatePickerWithTitle:(NSString *)title current:(NSString *)dateStr alertBlock:(G100AlertObject)alertBlock;
/**
 常住地选择 picker
 */
+ (void)G100CityPickerWithTitle:(NSString *)title current:(NSString *)areaStr alertBlock:(G100AlertObject)alertBlock;
/**
 延长服务期  options中是选项的view
 */
+ (void)G100AlertWithTitle:(NSString *)title options:(NSArray *)options alertBlock:(G100Alert)alertBlock style:(G100AlertViewStyle)style;

@end

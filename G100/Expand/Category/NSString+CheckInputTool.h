//
//  NSString+CheckInputTool.h
//  G100
//
//  Created by Tilink on 15/10/23.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Tool.h"

@interface NSString (CheckInputTool)

/**
 *  检查身份证
 *
 *  @param idCard 身份证号
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkIdCard:(NSString *)idCard;

/**
 *  检查被保人姓名
 *
 *  @param idname 被保人姓名
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkName:(NSString *)idname;

/**
 *  电动车名称检测
 *
 *  @param devname devname
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkDevname:(NSString *)devname;
/**
 *  电动车辆名称检测
 *
 *  @param devname devname
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkBikeName:(NSString *)bikeName;
/**
 *  用户名检测
 *
 *  @param username 用户名
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkUsername:(NSString *)username;

/**
 *  密码合法性检测
 *
 *  @param password 密码
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkPassword:(NSString *)password;

/**
 *  合法性检测
 *
 *  @param label    提示文案
 *  @param password 密码
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkPassword:(NSString *)label password:(NSString *)password;

/**
 *  验证码合法性
 *
 *  @param vc 验证码
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkVC:(NSString *)vc;

/**
 *  手机号合法性检测
 *
 *  @param phone 手机号
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkPhoneNum:(NSString *)phone;

/**
 *  手机号合法性检测
 *
 *  @param label 提示文案
 *  @param phone 手机号
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkPhoneNum:(NSString *)label phone:(NSString *)phone;

/**
 *  昵称检测
 *
 *  @param nickname 昵称
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkNickname:(NSString *)nickname;

/**
 *  昵称长度检测
 *
 *  @param nickname 昵称
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkNicknameLen:(NSString *)nickname;

/**
 *  车辆电压检测
 *
 *  @param voltage 电压
 *
 *  @return 合法则返回nil
 */
+ (NSString *)checkBikeVoltage:(NSString *)voltage;

/**
 车辆电池类型检测
 
 @param batteryType 电池类型
 @return   合法则返回nil
 */
+ (NSString *)checkBikeBatteryType:(NSString *)batteryType;

@end

//
//  NSString+CheckInputTool.m
//  G100
//
//  Created by Tilink on 15/10/23.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "NSString+CheckInputTool.h"

@implementation NSString (CheckInputTool)

-(BOOL)matches:(NSString *)predicateFormat {
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", predicateFormat];
    return [predicate evaluateWithObject:self];
}

/**
 *  检查身份证
 *
 *  @param idCard 身份证号
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkIdCard:(NSString *)idCard {
    if (idCard == nil) {
        return @"身份证不能为空";
    }
    idCard = [idCard trim];
    if (idCard.length == 0) {
        return @"身份证不能为空";
    }
    if (idCard.length != 18) {
        return @"身份证长度不正确";
    }
    if (![NSString isDigitsOnly:[idCard substringToIndex:17]]) {
        return @"身份证包含非法字符";
    }
    if (![[idCard substringFromIndex:17] matches:@"^[\\d,x,X]{1}+$"]) {
        return @"身份证包含非法字符";
    }
    
    return nil;
}

/**
 *  检查被保人姓名
 *
 *  @param idname 被保人姓名
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkName:(NSString *)idname {
    if ([NSString isEmpty:idname]) {
        return @"姓名不能为空";
    }
    if ([NSString hasWhiteSpace:idname]) {
        return @"姓名不能包含空格";
    }
    if (![idname matches:@"^[\u4e00-\u9fa5]+$"]) {
        return @"只能输入中文姓名";
    }
    
    return nil;
}

/**
 *  电动车名称检测
 *
 *  @param devname devname
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkDevname:(NSString *)devname {
    if ([NSString isEmpty:devname]) {
        return @"电动车名称不能为空";
    }
    if ([devname hasContainString:@" "]) {
        return @"电动车名称不能包含空格";
    }
    if (devname.length > 10) {
        return @"电动车名称太长，请输入10位以内的名称";
    }
    
    return nil;
}

/**
 *  电动车辆名称检测
 *
 *  @param devname devname
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkBikeName:(NSString *)bikeName {
    if ([NSString isEmpty:bikeName]) {
        return @"电动车名称不能为空";
    }
    if ([bikeName hasContainString:@" "]) {
        return @"电动车名称不能包含空格";
    }
    if (bikeName.length > 10) {
        return @"电动车名称太长，请输入10位以内的名称";
    }
    
    return nil;
}

/**
 *  车辆电压检测
 *
 *  @param voltage 电压
 *
 *  @return 合法则返回nil
 */
+ (NSString *)checkBikeVoltage:(NSString *)voltage
{
    if ([NSString isEmpty:voltage]) {
        return @"电压不能为空";
    }
    if (voltage.integerValue < 10) {
        return @"电压不能小于10";
    }
    if (voltage.integerValue > 100) {
        return @"电压不能大于100";
    }
    
    return nil;
         
}

/**
 车辆电池类型检测
 
 @param batteryType 电池类型
 @return   合法则返回nil
 */
+ (NSString *)checkBikeBatteryType:(NSString *)batteryType
{
    if ([NSString isEmpty:batteryType]) {
        return @"电池类型不能为空";
    }
    return nil;
}
/**
 *  用户名检测
 *
 *  @param username 用户名
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkUsername:(NSString *)username {
    if ([NSString isEmpty:username]) {
        return @"用户名不能为空";
    }
    if (![username matches:@"^(?!_)(?!.*?_$)[a-zA-Z0-9_]+$"]) {
        return @"用户名格式有误";
    }
    
    return nil;
}

/**
 *  密码合法性检测
 *
 *  @param password 密码
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkPassword:(NSString *)password {
    return [NSString checkPassword:nil password:password];
}

/**
 *  合法性检测
 *
 *  @param label    提示文案
 *  @param password 密码
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkPassword:(NSString *)label password:(NSString *)password {
    if ([NSString isEmpty:password]) {
        return label == nil ? @"密码不能为空" : [NSString stringWithFormat:@"%@不能为空", label];
    }else {
        if (password.length < 6 || password.length > 16) {
            return [NSString stringWithFormat:@"请输入6~16位的%@，密码只能输入数字和字符", label == nil ? @"密码" : label];
        }
        if (![password matches:@"[a-zA-Z0-9]+"]) {
            return [NSString stringWithFormat:@"%@中包含非法字符，密码只能输入数字和字符", label == nil ? @"密码" : label];
        }
    }
    
    return nil;
}

/**
 *  验证码合法性
 *
 *  @param vc 验证码
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkVC:(NSString *)vc {
    if ([NSString isEmpty:vc]) {
        return @"验证码不能为空";
    }
    if (vc.length != 4 || ![NSString isDigitsOnly:vc]) {
        return @"验证码通常为4位数字";
    }
    
    return nil;
}

/**
 *  手机号合法性检测
 *
 *  @param phone 手机号
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkPhoneNum:(NSString *)phone {
    return [NSString checkPhoneNum:nil phone:phone];
}

/**
 *  手机号合法性检测
 *
 *  @param label 提示文案
 *  @param phone 手机号
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkPhoneNum:(NSString *)label phone:(NSString *)phone {
    if ([NSString isEmpty:phone]) {
        return [NSString stringWithFormat:@"%@不能为空", label == nil ? @"手机号" : label];
    }    
    if (![phone isValidateMobile]) {
        return [NSString stringWithFormat:@"%@不正确", label == nil ? @"手机号" : label];
    }
    if (phone.length != 11) {
        return [NSString stringWithFormat:@"%@长度不正确", label == nil ? @"手机号" : label];
    }
    if (![NSString isDigitsOnly:phone]) {
        return [NSString stringWithFormat:@"%@包含非数字字符", label == nil ? @"手机号" : label];
    }
    
    return nil;
}

/**
 *  昵称检测
 *
 *  @param nickname 昵称
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkNickname:(NSString *)nickname {
    if ([NSString isEmpty:nickname]) {
        return @"昵称不能为空";
    }
    if ([nickname hasContainString:@" "]) {
        return @"昵称不能包含空格";
    }
    
    return [NSString checkNicknameLen:nickname];
}

/**
 *  昵称长度检测
 *
 *  @param nickname 昵称
 *
 *  @return 合法则返回nil
 */
+(NSString *)checkNicknameLen:(NSString *)nickname {
    if (nickname != nil && nickname.length > 10) {
        return @"昵称过长，请输入10位以内的昵称";
    }
    return nil;
}

@end

//
//  NSString+Tool.h
//  YanYi
//
//  Created by 王清健 on 14-11-14.
//  Copyright (c) 2014年 王清健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Tool)

/**
 * 判断是否是电话号
 * return 返回判断的结果
 */
- (BOOL)isValidateMobile;
/**
 * 判断是否是邮箱号
 * return 返回判断的结果
 */
-(BOOL)isValidateEmail;
/**
 * 判断是否是QQ号
 * return 返回判断的结果
 */
-(BOOL)isValidateQQ;
/**
 * 判断是否是符合的密码
 * return 返回判断的结果
 */
+ (BOOL)validatePassword:(NSString *)passWord;
/**
 * 判断是否是身份证号
 * return 返回判断的结果
 */
+ (BOOL)validateIdentityCard: (NSString *)identityCard;
/**
 *  判断是否是url
 *
 *  @param url url
 *
 *  @return yes/no
 */
+ (BOOL)validateUrl:(NSString *)url;
/**
 得到身份证的生日****这个方法中不做身份证校验，请确保传入的是正确身份证
 */
+ (NSString *)getIDCardBirthday:(NSString *)card;
/**
 得到身份证的性别（1男2女）****这个方法中不做身份证校验，请确保传入的是正确身份证
 */
+ (NSInteger)getIDCardSex:(NSString *)card;
/**
 * 隐藏手机号等重要信息
 */
+ (NSString *)shieldImportantInfo:(NSString *)info;

/**
 *  判断是否包含某个子串
 *
 *  @param subString 子字符串
 *
 *  @return 是否包含
 */
- (BOOL)hasContainString:(NSString *)subString;

/**
 *  字符串自适应宽高
 */
- (CGSize)calculateSize:(CGSize)size font:(UIFont *)font;
/**
 *  数字 -> 十一
 *
 *  @param arabicStr 数字字符串
 *
 *  @return 十一
 */
+(NSString *)arabictoHanzi:(NSString *)arabicStr;
/**
 *  判断是否空串 全部空格属于空
 *
 *  @param str 字符串
 *
 *  @return 结果
 */
+(BOOL)isEmpty:(NSString *)str;
/** 
 *  判断字符串中空格的个数
 *
 *  @param str 字符串
 *  @return 结果
 */
+(NSInteger)hasWhiteSpace:(NSString *)str;

/**
 *  判断字符串是否全部是数字
 *
 *  @param string 字符串
 *
 *  @return 结果
 */
+(BOOL)isDigitsOnly:(NSString *)string;

/**
 *  去除字符串中的空格
 *
 *  @return 结果
 */
-(NSString *)trim;

/**
 *  版本号比较方法
 *
 *  @param versionA 版本号1
 *  @param versionB 版本号2
 *
 *  @return 是否大
 */
+ (BOOL)isVersion:(NSString*)versionA biggerThanVersion:(NSString*)versionB;

/**
 *  参数拼接URL
 *
 *  @param para 参数
 *
 *  @return 拼接后的URL
 */
- (NSString *)appendUrlWithParamter:(NSString *)para;

/**
 *  获取图像验证码url后面的sessionid参数值
 *
 *  @param picvcurl 图像验证码url
 *
 *  @return sessionid
 */
+ (NSString *)getSessionidWithStr:(NSString *)picvcurl;

/**
 *  获取图像验证码picvc
 *
 *  @param picvcurl 图像验证码url
 *
 *  @return 新picvc
 */
+ (NSString *)getPicNameWithPicvcurl:(NSString *)picvcurl;

/**
 返回中文字符个数

 @param strtemp 原字符串

 @return 字符个数
 */
+ (NSInteger)unicodeLengthOfString:(NSString*)strtemp;

/**
 判断字符串是否是360骑卫士的 Host
 
 @return YES/NO
 */
- (BOOL)is360qwsHost;

/**
 判断字符串中是否包含表情

 @return YES/NO
 */
- (BOOL)stringContainsEmoji;

/**
 判断字符串中表情个数

 @return 表情个数
 */
- (NSInteger)countForEmoji;

/**
 截取字符串 包含表情字符

 @param to 截取长度
 @return 截取结果
 */
- (NSString *)subEmojiStringToIndex:(NSUInteger)to;

/**
 限制长度截取字符串 考虑emoji表情截取问题

 @param string 原字符串
 @param index 限制长度
 @return 新的字符串
 */
- (NSString *)subStringWith:(NSString *)string ToIndex:(NSInteger)index;

/**
 计算两个时间字符串相差时长
 
 @param startTime 开始时间
 @param endTime 结束时间
 @return 时长
 */
+ (NSString *)getTotalTimeWithStartTime:(NSString *)startTime endTime:(NSString *)endTime;

@end

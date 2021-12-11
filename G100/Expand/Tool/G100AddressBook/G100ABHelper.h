//
//  G100ABHelper.h
//  AddressBookDemo
//
//  Created by William on 16/6/7.
//  Copyright © 2016年 William. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum {
    ABHelperCanNotConncetToAddressBook,
    ABHelperExistSpecificContact,
    ABHelperNotExistSpecificContact
};

typedef NSUInteger ABHelperCheckExistResultType;

@class ABPerson;
@interface G100ABHelper : NSObject

+ (BOOL)openSystemAppSettingPage;

+ (BOOL)canOpenSystemAppSettingPage;

+ (void)checkAddressBookAuthorization:(void (^)(bool isAuthorized))block;

/**
 *  添加联系人
 *
 *  @param name  联系人姓名
 *  @param num   电话号码
 *  @param label 电话号码的标签备注
 *
 *  @return YES/NO
 */
+ (BOOL)addContactName:(NSString *)name phoneNum:(NSString *)num withLabel:(NSString *)label;
/**
 *  添加联系人(多个)
 *
 *  @param name   联系人姓名
 *  @param nums   电话号码
 *  @param labels 电话号码的标签备注
 *
 *  @return YES/NO
 */
+ (BOOL)addContactName:(NSString *)name phoneNums:(NSArray *)nums withLabels:(NSArray *)labels;
/**
 *  添加联系人(多个)
 *
 *  @param name   联系人姓名
 *  @param nums   电话号码
 *  @param note   备注信息
 *
 *  @return YES/NO
 */
+ (BOOL)addContactName:(NSString *)name phoneNums:(NSArray *)nums withNote:(NSString *)note;
/**
 *  查询指定号码是否已存在于通讯录
 *
 *  @param phoneNum 电话号码
 *
 *  @return ABHelperCheckExistResultType
 */
+ (ABHelperCheckExistResultType)existPhone:(NSString *)phoneNum;
/**
 *  查询指定联系人是否已存在于通讯录
 *
 *  @param name 联系人名
 *
 *  @return ABHelperCheckExistResultType
 */
+ (ABHelperCheckExistResultType)existRecordName:(NSString *)name;

/**
 根据用户名查询通讯录用户信息

 @param name 用户名
 @return 通讯录用户信息
 */
+ (ABPerson *)searchRecordName:(NSString *)name;
/**
 *  给指定号码的机主插入新的联系方式
 *
 *  @param num   新的电话号码
 *  @param label 新的电话对应的标签
 *  @param inNum 指定唯一标识的号码
 *
 *  @return YES/NO
 */
+ (BOOL)insertPhoneNum:(NSString *)num withLabel:(NSString *)label inContactNum:(NSString *)inNum;
/**
 替换指定号码成新的联系方式
 
 @param num 新的电话号码
 @param label 新的电话对应的标签
 @param inNum 指定唯一标识的号码
 @return YES/NO
 */
+ (BOOL)replacePhoneNum:(NSString *)num withLabel:(NSString *)label inContactNum:(NSString *)inNum;

/**
 删除指定联系人号码
 
 @param num 联系人号码
 @param deleteAccount 是否删除联系人账户
 @return YES/NO
 */
+ (BOOL)deletePhoneNum:(NSString *)num deleteAccount:(BOOL)deleteAccount;

/**
 删除指定联系人
 
 @param name 联系人名称
 @return YES/NO
 */
+ (BOOL)deletePhoneName:(NSString *)name;

@end

@interface ABPerson : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, strong) NSArray *phones;

@end

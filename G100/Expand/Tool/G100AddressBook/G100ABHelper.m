//
//  G100ABHelper.m
//  AddressBookDemo
//
//  Created by William on 16/6/7.
//  Copyright © 2016年 William. All rights reserved.
//

#import "G100ABHelper.h"
#import <AddressBook/AddressBook.h>

@interface G100ABHelper ()

@end

@implementation G100ABHelper

// 单列模式
+ (G100ABHelper*)shareControl {
    static G100ABHelper *instance;
    @synchronized(self) {
        if(!instance) {
            instance = [[G100ABHelper alloc] init];
        }
    }
    return instance;
}

+(BOOL)openSystemAppSettingPage {
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        return YES;
    }else {
        return [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

+(BOOL)canOpenSystemAppSettingPage {
    return YES;
}

+(void)checkAddressBookAuthorization:(void (^)(bool isAuthorized))block {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    if (authStatus != kABAuthorizationStatusAuthorized) {
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (error)
                 {
                     NSLog(@"Error: %@", (__bridge NSError *)error);
                 }
                 else if (!granted)
                 {
                     
                     block(NO);
                 }
                 else
                 {
                     block(YES);
                 }
             });
         });
    }
    else
    {
        block(YES);
    }
}

+ (BOOL)addContactName:(NSString *)name phoneNum:(NSString *)num withLabel:(NSString *)label
{
    return [[G100ABHelper shareControl] addContactName:name phoneNum:num withLabel:label];
}
// 添加联系人（联系人名称、号码、号码备注标签）
- (BOOL)addContactName:(NSString*)name phoneNum:(NSString*)num withLabel:(NSString*)label
{
    // 创建一条空的联系人
    ABRecordRef record = ABPersonCreate();
    CFErrorRef error;
    // 设置联系人的名字
    ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)name, &error);
    // 添加联系人电话号码以及该号码对应的标签名
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)num, (__bridge CFTypeRef)label, NULL);
    ABRecordSetValue(record, kABPersonPhoneProperty, multi, &error);
    
    ABAddressBookRef addressBook = nil;
    // 如果为iOS6以上系统，需要等待用户确认是否允许访问通讯录。
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    // 将新建联系人记录添加如通讯录中
    BOOL success = ABAddressBookAddRecord(addressBook, record, &error);
    if (!success) {
        return NO;
    }else{
        // 如果添加记录成功，保存更新到通讯录数据库中
        success = ABAddressBookSave(addressBook, &error);
        return success ? YES : NO;
    }
}

+ (BOOL)addContactName:(NSString *)name phoneNums:(NSArray *)nums withLabels:(NSArray *)labels {
    return [[G100ABHelper shareControl] addContactName:name phoneNums:nums withLabels:labels withNote:nil];
}
+ (BOOL)addContactName:(NSString *)name phoneNums:(NSArray *)nums withNote:(NSString *)note {
    return [[G100ABHelper shareControl] addContactName:name phoneNums:nums withLabels:nil withNote:note];
}

- (BOOL)addContactName:(NSString *)name phoneNums:(NSArray *)nums withLabels:(NSArray *)labels withNote:(NSString *)note {
    // 创建一条空的联系人
    ABRecordRef record = ABPersonCreate();
    CFErrorRef error;
    // 设置联系人的名字
    ABRecordSetValue(record, kABPersonFirstNameProperty, (__bridge CFTypeRef)name, &error);
    // 添加联系人电话号码以及该号码对应的标签名
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABPersonPhoneProperty);
    for (NSInteger i = 0; i < nums.count; i++) {
        ABMultiValueInsertValueAndLabelAtIndex(multi, (__bridge CFTypeRef)(nums[i]), (__bridge CFTypeRef)(labels ? labels[i] : @""), i, NULL);
    }
    
    ABRecordSetValue(record, kABPersonPhoneProperty, multi, &error);
    ABRecordSetValue(record, kABPersonNoteProperty, (__bridge CFTypeRef)note, &error);
    
    ABAddressBookRef addressBook = nil;
    // 如果为iOS6以上系统，需要等待用户确认是否允许访问通讯录。
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    // 将新建联系人记录添加如通讯录中
    BOOL success = ABAddressBookAddRecord(addressBook, record, &error);
    if (!success) {
        return NO;
    }else{
        // 如果添加记录成功，保存更新到通讯录数据库中
        success = ABAddressBookSave(addressBook, &error);
        return success ? YES : NO;
    }
}

+ (ABHelperCheckExistResultType)existPhone:(NSString *)phoneNum
{
    return [[G100ABHelper shareControl] existPhone:phoneNum];
}

// 指定号码是否已经存在
- (ABHelperCheckExistResultType)existPhone:(NSString*)phoneNum
{
    ABAddressBookRef addressBook = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    CFArrayRef records;
    if (addressBook) {
        // 获取通讯录中全部联系人
        records = ABAddressBookCopyArrayOfAllPeople(addressBook);
    }else{
#ifdef DEBUG
        NSLog(@"can not connect to address book");
#endif
        return ABHelperCanNotConncetToAddressBook;
    }
    
    // 遍历全部联系人，检查是否存在指定号码
    for (int i=0; i<CFArrayGetCount(records); i++) {
        ABRecordRef record = CFArrayGetValueAtIndex(records, i);
        CFTypeRef items = ABRecordCopyValue(record, kABPersonPhoneProperty);
        CFArrayRef phoneNums = ABMultiValueCopyArrayOfAllValues(items);
        if (phoneNums) {
            for (int j=0; j<CFArrayGetCount(phoneNums); j++) {
                NSString *phone = (NSString*)CFArrayGetValueAtIndex(phoneNums, j);
                if ([phone isEqualToString:phoneNum]) {
                    return ABHelperExistSpecificContact;
                }
            }
        }
    }
    
    CFRelease(addressBook);
    return ABHelperNotExistSpecificContact;
}

+ (ABHelperCheckExistResultType)existRecordName:(NSString *)name {
    return [[G100ABHelper shareControl] existRecordName:name];
}

+ (ABPerson *)searchRecordName:(NSString *)name {
    ABPerson *person = [[ABPerson alloc] init];
    person.name = name;
    
    ABAddressBookRef addressBook = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    CFArrayRef records;
    if (addressBook) {
        // 获取通讯录中全部联系人
        records = ABAddressBookCopyArrayOfAllPeople(addressBook);
    }else{
#ifdef DEBUG
        NSLog(@"can not connect to address book");
#endif
        return nil;
    }
    
    // 遍历全部联系人，检查是否存在指定号码
    for (int i = 0; i < CFArrayGetCount(records); i++) {
        ABRecordRef record = CFArrayGetValueAtIndex(records, i);
        CFTypeRef personFirstName = ABRecordCopyValue(record, kABPersonFirstNameProperty);
        CFTypeRef note = ABRecordCopyValue(record, kABPersonNoteProperty);
        CFTypeRef items = ABRecordCopyValue(record, kABPersonPhoneProperty);
        CFArrayRef phoneNums = ABMultiValueCopyArrayOfAllValues(items);
        NSString *personName = (NSString *)personFirstName;
        if ([personName isEqualToString:name]) {
            person.note = (NSString *)note;
            person.phones = (NSArray *)phoneNums;
            return person;
        }
    }
    
    CFRelease(addressBook);
    return nil;
}

// 指定联系人是否已经存在
- (ABHelperCheckExistResultType)existRecordName:(NSString*)name {
    ABAddressBookRef addressBook = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    CFArrayRef records;
    if (addressBook) {
        // 获取通讯录中全部联系人
        records = ABAddressBookCopyArrayOfAllPeople(addressBook);
    }else{
#ifdef DEBUG
        NSLog(@"can not connect to address book");
#endif
        return ABHelperCanNotConncetToAddressBook;
    }
    
    // 遍历全部联系人，检查是否存在指定号码
    for (int i=0; i<CFArrayGetCount(records); i++) {
        ABRecordRef record = CFArrayGetValueAtIndex(records, i);
        CFTypeRef personFirstName = ABRecordCopyValue(record, kABPersonFirstNameProperty);
        NSString *personName = (NSString*)personFirstName;
        if ([personName isEqualToString:name]) {
            return ABHelperExistSpecificContact;
        }
    }
    
    CFRelease(addressBook);
    return ABHelperNotExistSpecificContact;
}

+ (BOOL)insertPhoneNum:(NSString *)num withLabel:(NSString *)label inContactNum:(NSString *)inNum {
    return [[G100ABHelper shareControl] insertPhoneNum:num withLabel:label inContactNum:inNum];
}

- (BOOL)insertPhoneNum:(NSString *)num withLabel:(NSString *)label inContactNum:(NSString *)inNum {
    if ([[G100ABHelper shareControl] existPhone:inNum] == ABHelperNotExistSpecificContact) {
        return NO;
    }
    
    BOOL success = NO;
    if ([[G100ABHelper shareControl] existPhone:num] == ABHelperNotExistSpecificContact) {
        ABAddressBookRef addressBook = nil;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
        {
            addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            //等待同意后向下执行
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                dispatch_semaphore_signal(sema);
            });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
            dispatch_release(sema);
        }
        else
        {
            addressBook = ABAddressBookCreate();
        }
        CFArrayRef records;
        if (addressBook) {
            // 获取通讯录中全部联系人
            records = ABAddressBookCopyArrayOfAllPeople(addressBook);
        }else{
#ifdef DEBUG
            NSLog(@"can not connect to address book");
#endif
            return NO;
        }
        
        // 遍历全部联系人，检查是否存在指定号码
        for (int i=0; i<CFArrayGetCount(records); i++) {
            ABRecordRef record = CFArrayGetValueAtIndex(records, i);
            CFTypeRef items = ABRecordCopyValue(record, kABPersonPhoneProperty);
            CFArrayRef phoneNums = ABMultiValueCopyArrayOfAllValues(items);
            if (phoneNums) {
                BOOL isExist = NO;
                ABMutableMultiValueRef multiValueRef =ABMultiValueCreateMutable(kABStringPropertyType);
                for (int j=0; j<CFArrayGetCount(phoneNums); j++) {
                    NSString *phone = (NSString*)CFArrayGetValueAtIndex(phoneNums, j);
                    CFStringRef oldLabel = ABMultiValueCopyLabelAtIndex(items, j);
                    ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFTypeRef)phone, oldLabel, NULL);
                    if ([phone isEqualToString:inNum]) {
                        isExist = YES;
                        success = ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFTypeRef)num, (__bridge CFTypeRef)label, NULL);
                    }
                }
                
                if (isExist) {
                    success = ABRecordSetValue(record, kABPersonPhoneProperty, multiValueRef, NULL);
                    success = ABAddressBookSave(addressBook, NULL);
                }
            }
        }
        
        CFRelease(addressBook);
    }
    
    return success;
}

+ (BOOL)replacePhoneNum:(NSString *)num withLabel:(NSString *)label inContactNum:(NSString *)inNum {
    return [[G100ABHelper shareControl] replacePhoneNum:num withLabel:label inContactNum:inNum];
}

- (BOOL)replacePhoneNum:(NSString *)num withLabel:(NSString *)label inContactNum:(NSString *)inNum {
    if ([[G100ABHelper shareControl] existPhone:inNum] != ABHelperExistSpecificContact) {
        return NO;
    }
    
    BOOL success = NO;
    ABAddressBookRef addressBook = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    CFArrayRef records;
    if (addressBook) {
        // 获取通讯录中全部联系人
        records = ABAddressBookCopyArrayOfAllPeople(addressBook);
    }else{
#ifdef DEBUG
        NSLog(@"can not connect to address book");
#endif
        return NO;
    }
    
    // 遍历全部联系人，检查是否存在指定号码
    for (int i=0; i<CFArrayGetCount(records); i++) {
        ABRecordRef record = CFArrayGetValueAtIndex(records, i);
        CFTypeRef items = ABRecordCopyValue(record, kABPersonPhoneProperty);
        CFArrayRef phoneNums = ABMultiValueCopyArrayOfAllValues(items);
        if (phoneNums) {
            BOOL isExist = NO;
            ABMutableMultiValueRef multiValueRef =ABMultiValueCreateMutable(kABStringPropertyType);
            for (int j=0; j<CFArrayGetCount(phoneNums); j++) {
                NSString *phone = (NSString*)CFArrayGetValueAtIndex(phoneNums, j);
                CFStringRef oldLabel = ABMultiValueCopyLabelAtIndex(items, j);
                ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFTypeRef)phone, oldLabel, NULL);
                if ([phone isEqualToString:inNum]) {
                    isExist = YES;
                    success = ABMultiValueReplaceValueAtIndex(multiValueRef, (__bridge CFTypeRef)num, (__bridge CFIndex)j);
                }
            }
            
            if (isExist) {
                success = ABRecordSetValue(record, kABPersonPhoneProperty, multiValueRef, NULL);
                success = ABAddressBookSave(addressBook, NULL);
            }
        }
    }
    
    CFRelease(addressBook);
    
    return success;
}

+ (BOOL)deletePhoneNum:(NSString *)num deleteAccount:(BOOL)deleteAccount {
    return [[G100ABHelper shareControl] deletePhoneNum:num deleteAccount:deleteAccount];
}

- (BOOL)deletePhoneNum:(NSString *)num deleteAccount:(BOOL)deleteAccount {
    if ([[G100ABHelper shareControl] existPhone:num] != ABHelperExistSpecificContact) {
        return NO;
    }
    
    BOOL success = NO;
    ABAddressBookRef addressBook = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    CFArrayRef records;
    if (addressBook) {
        // 获取通讯录中全部联系人
        records = ABAddressBookCopyArrayOfAllPeople(addressBook);
    }else{
#ifdef DEBUG
        NSLog(@"can not connect to address book");
#endif
        return NO;
    }
    
    // 遍历全部联系人，检查是否存在指定号码
    for (int i=0; i<CFArrayGetCount(records); i++) {
        ABRecordRef record = CFArrayGetValueAtIndex(records, i);
        CFTypeRef items = ABRecordCopyValue(record, kABPersonPhoneProperty);
        CFArrayRef phoneNums = ABMultiValueCopyArrayOfAllValues(items);
        if (phoneNums) {
            BOOL isExist = NO;
            ABMutableMultiValueRef multiValueRef =ABMultiValueCreateMutable(kABStringPropertyType);
            for (int j=0; j<CFArrayGetCount(phoneNums); j++) {
                NSString *phone = (NSString*)CFArrayGetValueAtIndex(phoneNums, j);
                CFStringRef oldLabel = ABMultiValueCopyLabelAtIndex(items, j);
                ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFTypeRef)phone, oldLabel, NULL);
                if ([phone isEqualToString:num]) {
                    isExist = YES;
                    
                    if (deleteAccount) {
                        success = ABAddressBookRemoveRecord(addressBook, record, nil);
                    } else {
                        success = ABMultiValueRemoveValueAndLabelAtIndex(multiValueRef, (__bridge CFIndex)j);
                    }
                }
            }
            
            if (isExist) {
                success = ABRecordSetValue(record, kABPersonPhoneProperty, multiValueRef, NULL);
                success = ABAddressBookSave(addressBook, NULL);
            }
        }
    }
    
    CFRelease(addressBook);
    
    return success;
}

+ (BOOL)deletePhoneName:(NSString *)name {
    return [[G100ABHelper shareControl] deletePhoneName:name];
}

- (BOOL)deletePhoneName:(NSString *)name {
    if ([[G100ABHelper shareControl] existRecordName:name] != ABHelperExistSpecificContact) {
        return NO;
    }
    
    BOOL success = NO;
    ABAddressBookRef addressBook = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        addressBook = ABAddressBookCreate();
    }
    CFArrayRef records;
    if (addressBook) {
        // 获取通讯录中全部联系人
        records = ABAddressBookCopyArrayOfAllPeople(addressBook);
    }else{
#ifdef DEBUG
        NSLog(@"can not connect to address book");
#endif
        return NO;
    }
    
    // 遍历全部联系人，检查是否存在指定号码
    for (int i=0; i<CFArrayGetCount(records); i++) {
        ABRecordRef record = CFArrayGetValueAtIndex(records, i);
        CFTypeRef item = ABRecordCopyValue(record, kABPersonFirstNameProperty);
        
        BOOL isExist = NO;
        NSString *personName = (NSString*)item;
        if ([personName isEqualToString:name]) {
            isExist = YES;
            success = ABAddressBookRemoveRecord(addressBook, record, NULL);
        }
    
        if (isExist) {
            success = ABAddressBookSave(addressBook, NULL);
        }
    }
    
    CFRelease(addressBook);
    
    return success;
}

@end

@implementation ABPerson

@end

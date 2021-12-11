//
//  G100ABManager.m
//  G100
//
//  Created by yuhanle on 2017/2/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100ABManager.h"
#import "G100ABHelper.h"

static NSString *absession = @"absession";

@interface G100ABManager () <UIAlertViewDelegate>

@property (nonatomic, copy) ABCheckUpdateComplete checkUpdateComplete;
@property (nonatomic, copy) ABWriteComplete writeComplete;

@property (nonatomic, strong) ABListDomain *newestList;
@property (nonatomic, strong) ABListDomain *oldList;

@property (nonatomic, assign) BOOL isProcessing;

/**
 是否已经提醒用户通讯录权限
 */
@property (nonatomic, assign) BOOL hasRemainderABSet;

@end

@implementation G100ABManager

+ (instancetype)sharedInstance {
    static G100ABManager * sharedInstance = nil;
    static dispatch_once_t onceTonken;
    dispatch_once(&onceTonken, ^{
        sharedInstance = [[G100ABManager alloc] init];
        sharedInstance.isProcessing = NO;
        sharedInstance.hasRemainderABSet = NO;
    });
    
    return sharedInstance;
}

- (void)checkAddressBookAuthorization:(void (^)(bool isAuthorized))block {
    [G100ABHelper checkAddressBookAuthorization:^(bool isAuthorized) {
        if (block) {
            block(isAuthorized);
        }
    }];
}

- (void)ab_checkUpdate:(ABCheckUpdateComplete)checkComplete {
    [self ab_checkUpdateWithType:0 checkComplete:checkComplete];
}

- (void)ab_checkUpdateWithType:(AB_CheckUpdateType)type checkComplete:(ABCheckUpdateComplete)checkComplete {
    self.checkUpdateComplete = checkComplete;
    
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        // 处理结果
        if (requestSuccess) {
            ABListDomain *list = [ABListDomain mj_objectWithKeyValues:response.data];
            [self ab_handleResult:list type:type];
        } else {
            if (self.checkUpdateComplete) {
                NSError *error = [NSError errorWithDomain:@"G100ABManager" code:100 userInfo:@{@"reason" : @"通讯录更新请求错误"}];
                self.checkUpdateComplete(NO, nil, error);
            }
        }
    };
    
    ApiRequest *request = [ApiRequest requestWithBizData:@{ @"type" : [NSNumber numberWithInteger:type] }];
    [G100ApiHelper postApi:@"app/telephonebook" andRequest:request callback:callback];
}

/**
 更新通讯录逻辑

 获取到报警电话更新 -> 检查通讯录权限 -> 匹配通讯录MD5 判断是否有更新 -> 写入更新
 以上步骤 任一环节失败 都会弹窗提醒用户关闭电话报警（若用户开通了电话报警 具体业务处理）
 */
- (void)ab_handleResult:(ABListDomain *)list type:(AB_CheckUpdateType)type {
    if (!list) {
        if (self.checkUpdateComplete) {
            self.checkUpdateComplete(NO, list, nil);
        }
        return;
    }
    self.newestList = list;
    
    // 先检查通讯录 权限
    __weak __typeof__(self) wself = self;
    [G100ABHelper checkAddressBookAuthorization:^(bool isAuthorized) {
        if (isAuthorized) {
            // 继续读写通讯录操作
            [wself ab_accessBook:list type:type];
        } else {
            // 没有通讯录权限 -> 提醒用户 自动关闭电话报警功能
            NSError *error = [NSError errorWithDomain:@"G100ABManager" code:110 userInfo:@{@"reason" : @"没有通讯录权限"}];
            self.checkUpdateComplete ? self.checkUpdateComplete(NO, nil, error) : nil;
        }
    }];
}

- (void)ab_accessBook:(ABListDomain *)list type:(AB_CheckUpdateType)type {
    if (type == AB_CheckUpdateTypeAlarm) {
        [self ab_startWriteWithType:AB_CheckUpdateTypeAlarm writeComplete:nil];
        return;
    }
    if ([G100ABHelper existRecordName:@"360骑卫士安全提醒"]) {
        [G100ABHelper deletePhoneName:@"360骑卫士安全提醒"];
    }
    if ([G100ABHelper existRecordName:@"360骑卫士客服电话"]) {
        [G100ABHelper deletePhoneName:@"360骑卫士客服电话"];
    }
    for (ABPhoneDomain *phone in self.newestList.list) {
        ABPerson *person = [G100ABHelper searchRecordName:phone.name];
        
        if (person) {
            if ([person.note isEqualToString:phone.md5]) {
                // 不处理
            }else {
                // 有更新 -> 存放
                [self ab_syncBook:list type:type];
            }
        }else {
            // 未存放至通讯录 -> 存放
            [self ab_syncBook:list type:type];
        }
    }
}

- (void)ab_syncBook:(ABListDomain *)list type:(AB_CheckUpdateType)type {
    if (self.checkUpdateComplete) {
        self.checkUpdateComplete(YES, list, nil);
    }
    
    // 判断该用户是否开通了微信报警
    G100UserDomain *userDomain = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:[[G100InfoHelper shareInstance] buserid]];
    if (![userDomain isOpenPhoneAlarm]) {
        [self ab_startWriteWithType:AB_CheckUpdateTypeKefu writeComplete:nil];
    } else {
        [self ab_startWriteWithType:AB_CheckUpdateTypeAll writeComplete:nil];
    }
}

//TODO: 废弃更新通讯录逻辑
- (void)desperate_ab_handleResult:(ABListDomain *)list type:(AB_CheckUpdateType)type {
    
    if (!list) {
        if (self.checkUpdateComplete) {
            self.checkUpdateComplete(NO, list, nil);
        }
        return;
    }
    self.newestList = list;
    
    // 如果是更新报警电话 则直接更新
    if (type == AB_CheckUpdateTypeAlarm) {
        [self ab_checkSystemAuthorutyReminder];
        [self ab_startWriteWithType:AB_CheckUpdateTypeAlarm writeComplete:nil];
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *oldRes = [defaults objectForKey:absession];
    
    if (oldRes) {
        // 存在旧数据 则比较是否存在更新
        ABListDomain *oldList = [[ABListDomain alloc] initWithLocalRes:oldRes];
        self.oldList = oldList;
        
        BOOL isChanged = NO;
        BOOL isNewData = NO;
        
        NSInteger changeType = 0;
        NSInteger changeCount = 0;
        for (ABPhoneDomain *phone in self.newestList.list) {
            NSDictionary *dict = [[oldRes objectForKey:@"list"] objectForKey:[NSString stringWithFormat:@"%@", @(phone.type)]];
            
            if (!dict) {
                isNewData = YES;
                changeCount++;
            } else {
                ABPhoneDomain *oldPhone = [ABPhoneDomain mj_objectWithKeyValues:dict];
                if (![oldPhone.md5 isEqualToString:phone.md5]) {
                    isChanged = YES;
                    changeType = phone.type;
                    changeCount++;
                }
            }
        }
        
        if (changeCount >= self.oldList.list.count) {
            changeType = AB_CheckUpdateTypeAll;
        }
        
        if (isNewData) {
            if (self.checkUpdateComplete) {
                self.checkUpdateComplete(YES, list, nil);
            }

            if (type == AB_CheckUpdateTypeAlarm && changeType == AB_CheckUpdateTypeAlarm) {
                
            } else {
                // 判断该用户是否开通了微信报警
                G100UserDomain *userDomain = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:[[G100InfoHelper shareInstance] buserid]];
                if (![userDomain isOpenPhoneAlarm]) {
                    [self ab_startWriteWithType:AB_CheckUpdateTypeKefu writeComplete:nil];
                } else {
                    [self ab_startWriteWithType:AB_CheckUpdateTypeAll writeComplete:nil];
                }
            }
        }
        
        if (isChanged) {
            // 有更新
            if (self.checkUpdateComplete) {
                self.checkUpdateComplete(YES, list, nil);
            }
            
            [self ab_updateReminderWithType:type changeType:changeType];
        } else {
            if (self.checkUpdateComplete) {
                self.checkUpdateComplete(NO, list, nil);
            }
        }
        
    } else {
        // 有更新
        self.oldList = nil;
        
        if (self.checkUpdateComplete) {
            self.checkUpdateComplete(YES, list, nil);
        }
        
        if (!self.hasRemainderABSet) {
            [self ab_checkSystemAuthorutyReminder];
        }
        
        // 判断该用户是否开通了微信报警
        G100UserDomain *userDomain = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:[[G100InfoHelper shareInstance] buserid]];
        if (![userDomain isOpenPhoneAlarm]) {
            [self ab_startWriteWithType:AB_CheckUpdateTypeKefu writeComplete:nil];
        } else {
            [self ab_startWriteWithType:AB_CheckUpdateTypeAll writeComplete:nil];
        }
    }
}

- (void)ab_checkSystemAuthorutyReminder {
    if (self.isProcessing) {
        return;
    }
    
    self.isProcessing = YES;
    
    [G100ABHelper checkAddressBookAuthorization:^(bool isAuthorized) {
        if (isAuthorized) {
            
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法使用通讯录"
                                                                message:@"请到“设置-隐私-通讯录”中开启权限"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"立即开启", nil];
            alertView.tag = 2000;
            alertView.delegate = self;
            [alertView show];
            
            self.hasRemainderABSet = YES;
        }
    }];
}

- (void)ab_updateReminderWithType:(AB_CheckUpdateType)type changeType:(AB_CheckUpdateType)changeType {
    [self saveInfoWithList:self.newestList type:type];
    if (changeType == AB_CheckUpdateTypeAlarm && type == AB_CheckUpdateTypeAlarm) {
        
    } else {
        // 判断该用户是否开通了电话报警
        G100UserDomain *userDomain = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:[[G100InfoHelper shareInstance] buserid]];
        if (![userDomain isOpenPhoneAlarm] && changeType == AB_CheckUpdateTypeAlarm) {
            return;
        }
    }
    
    NSString *title = @"服务号码";
    NSString *content = @"请点击更新，将报警电话和客服电话更新到通讯录中。";
    
    if (changeType == 0) {
        content = @"请点击更新，将报警电话和客服电话更新到通讯录中。";
    } else if (changeType == 1) {
        content = @"客服电话已更新，请点击更新，更新到通讯录中。";
    } else if (changeType == 2) {
        content = @"报警电话已更新，请点击更新，更新到通讯录中。";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:content
                                                       delegate:self
                                              cancelButtonTitle:@"下次提醒"
                                              otherButtonTitles:@"更新", nil];
    alertView.tag = 1000+changeType;
    alertView.delegate = self;
    [alertView show];
    
    self.isProcessing = YES;
}

- (void)ab_startWrite:(ABWriteComplete)writeComplete {
    [self ab_startWriteWithType:0 writeComplete:writeComplete];
}

- (void)ab_startWriteWithType:(AB_CheckUpdateType)type writeComplete:(ABWriteComplete)writeComplete {
    self.writeComplete = writeComplete;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *oldRes = [defaults objectForKey:absession];
    
    if (oldRes) {
        // 存在旧数据 则比较是否存在更新
        ABListDomain *oldList = [[ABListDomain alloc] initWithLocalRes:oldRes];
        self.oldList = oldList;
    } else {
        self.oldList = nil;
    }
    
    // 删除旧版本的通讯录
    if (type == AB_CheckUpdateTypeAll || type == AB_CheckUpdateTypeAlarm) {
        [G100ABHelper deletePhoneNum:@"02133193890" deleteAccount:YES];
    }
    
    if (type == AB_CheckUpdateTypeAll || type == AB_CheckUpdateTypeKefu) {
        [G100ABHelper deletePhoneNum:@"4009202890" deleteAccount:YES];
    }
    
    if (self.newestList) {
        //
        if (self.oldList) {
            // 删除通讯录中旧的 联系方式
            for (ABPhoneDomain *phone in self.oldList.list) {
                if (type == phone.type || type == AB_CheckUpdateTypeAll) {
                    [G100ABHelper deletePhoneName:phone.name];
                }
            }
            
            BOOL success = NO;
            for (ABPhoneDomain *phone in self.newestList.list) {
                if (type == 0 || type == phone.type) {
                    if (phone.type == AB_CheckUpdateTypeAlarm) {
                        if (type == AB_CheckUpdateTypeAlarm) {
                            
                        } else {
                            // 判断该用户是否开通了电话报警
                            G100UserDomain *userDomain = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:[[G100InfoHelper shareInstance] buserid]];
                            
                            if (![userDomain isOpenPhoneAlarm]) {
                                continue;
                            }
                        }
                    }
                    
                    if (type == phone.type || type == AB_CheckUpdateTypeAll) {
                        success = [G100ABHelper deletePhoneName:phone.name];
                    }
                    
                    success = [G100ABHelper addContactName:phone.name phoneNums:phone.phones withNote:phone.md5];
                }
            }
            
            if (self.writeComplete) {
                NSError *error = [NSError errorWithDomain:@"G100ABManager" code:120 userInfo:@{@"reason" : @"通讯录写入错误"}];
                self.writeComplete(success ? nil : error);
            }
            
            [self saveInfoWithList:self.newestList type:type];
        } else {
            for (ABPhoneDomain *phone in self.oldList.list) {
                if (type == phone.type || type == AB_CheckUpdateTypeAll) {
                    [G100ABHelper deletePhoneName:phone.name];
                }
            }
            
            BOOL success = NO;
            for (ABPhoneDomain *phone in self.newestList.list) {
                if (type == 0 || type == phone.type) {
                    if (phone.type == AB_CheckUpdateTypeAlarm) {
                        if (type == AB_CheckUpdateTypeAlarm) {
                            
                        } else {
                            // 判断该用户是否开通了电话报警
                            G100UserDomain *userDomain = [[G100InfoHelper shareInstance] findMyUserInfoWithUserid:[[G100InfoHelper shareInstance] buserid]];
                            
                            if (![userDomain isOpenPhoneAlarm]) {
                                continue;
                            }
                        }
                    }
                    
                    if (type == phone.type || type == AB_CheckUpdateTypeAll) {
                        success = [G100ABHelper deletePhoneName:phone.name];
                    }
                    
                    success = [G100ABHelper addContactName:phone.name phoneNums:phone.phones withNote:phone.md5];
                }
            }
            
            if (self.writeComplete) {
                NSError *error = [NSError errorWithDomain:@"G100ABManager" code:101 userInfo:@{@"reason" : @"通讯录未更新"}];
                self.writeComplete(success ? nil : error);
            }
            
            [self saveInfoWithList:self.newestList type:type];
        }
    } else {
        if (self.writeComplete) {
            NSError *error = [NSError errorWithDomain:@"G100ABManager" code:101 userInfo:@{@"reason" : @"通讯录未更新"}];
            self.writeComplete(error);
        }
    }
}

/**
 持久化存储云端电话数据

 @param list 电话数据
 @param type 存储类型
 */
- (void)saveInfoWithList:(ABListDomain *)list type:(AB_CheckUpdateType)type {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *oldRes = [[defaults objectForKey:absession] objectForKey:@"list"];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithDictionary:oldRes];
    for (ABPhoneDomain *phone in list.list) {
        if (type == 0 || phone.type == type) {
            [dict setObject:[phone mj_keyValues] forKey:[NSString stringWithFormat:@"%@", @(phone.type)]];
        }
    }
    
    [defaults setObject:@{ @"list" : dict } forKey:absession];
    [defaults synchronize];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2000) {
        // 提示跳转至应用设置通讯录权限
        if (buttonIndex == 0) {
            NSError *error = [NSError errorWithDomain:@"G100ABManager" code:111 userInfo:@{@"reason" : @"用户取消设置"}];
            self.checkUpdateComplete ? self.checkUpdateComplete(NO, nil, error) : nil;
        } else {
            [G100ABHelper openSystemAppSettingPage];
        }
        
        self.isProcessing = NO;
    }else if (alertView.tag >= 1000) {
        self.isProcessing = NO;
        
        if (buttonIndex == 1) {
            // 确定升级
            [G100ABHelper checkAddressBookAuthorization:^(bool isAuthorized) {
                if (isAuthorized) {
                    [self ab_startWriteWithType:alertView.tag-1000 writeComplete:nil];
                } else {
                    [self ab_checkSystemAuthorutyReminder];
                }
            }];
        }else {
            NSError *error = [NSError errorWithDomain:@"G100ABManager" code:112 userInfo:@{@"reason" : @"用户取消更新"}];
            self.checkUpdateComplete ? self.checkUpdateComplete(NO, nil, error) : nil;
        }
    }
}

@end

@implementation ABListDomain

- (void)setList:(NSArray<ABPhoneDomain *> *)list {
    _list = [list mapWithBlock:^id(id item, NSInteger idx) {
        if ([item isKindOfClass:[ABPhoneDomain class]]) {
            return item;
        } else {
            ABPhoneDomain *phone = [ABPhoneDomain mj_objectWithKeyValues:item];
            return phone;
        }
    }];
}

- (instancetype)initWithLocalRes:(NSDictionary *)res {
    if (self = [super init]) {
        NSMutableDictionary *list = [[NSMutableDictionary alloc] init];
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (NSString *key in [res[@"list"] allKeys]) {
            NSDictionary *dict = [res[@"list"] objectForKey:key];
            [result addObject:dict];
        }
        
        [list setObject:result forKey:@"list"];
        [self mj_setKeyValues:list];
    }
    return self;
}

@end

@implementation ABPhoneDomain

@end

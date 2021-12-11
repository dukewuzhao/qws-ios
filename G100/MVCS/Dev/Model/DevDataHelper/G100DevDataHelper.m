//
//  G100DevDataHelper.m
//  G100
//
//  Created by William on 16/8/17.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevDataHelper.h"
#import "G100BikeApi.h"
#import "G100PushMsgDomain.h"

#define WIFI_REFRESH_INTERVAL 30.0f
#define CUSTOM_REFRESH_INTERVAL 5.0f

NSString * const kDevDataReceivedNotification = @"dev_data_received_notification";

@interface G100DevDataHelper ()

/** 用户id*/
@property (copy, nonatomic) NSString *userid;
/** 用户的车辆设备列表*/
@property (strong, nonatomic) NSMutableArray *bikelist;
/** 定时器刷新*/
@property (strong, nonatomic) NSTimer *refreshTimer;
/** 标志请求状态*/
@property (strong, nonatomic) NSMutableDictionary *reqStatusDict;
/** 存储请求回调*/
@property (strong, nonatomic) NSMutableDictionary *reqCallbackDict;

@end

@implementation G100DevDataHelper

+ (instancetype)shareInstance {
    static dispatch_once_t onceTonken;
    static G100DevDataHelper * instance = nil;
    dispatch_once(&onceTonken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

#pragma mark - setup
- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ddh_networkChanged:)
                                                 name:AFNetworkingReachabilityDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ddh_appDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ddh_appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ddh_remoteLoginHandle:)
                                                 name:kGNRemoteLoginMsg
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ddh_logoutHandle:)
                                                 name:kGNAppLoginOrLogoutNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ddh_deleteBikeHandle:)
                                                 name:kGNDeleteBikeSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ddh_bikeAccStatusDidChangedHandle:)
                                                 name:kGNDevAccStatusOnorOff
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ddh_bikeListDidChange:)
                                                 name:CDDDataHelperBikeListDidChangeNotification
                                               object:nil];
}

#pragma mark - Lazy load
- (NSMutableArray *)bikelist {
    if (!_bikelist) {
        _bikelist = [[NSMutableArray alloc] init];
    }
    return _bikelist;
}
- (NSMutableDictionary *)reqStatusDict {
    if (!_reqStatusDict) {
        _reqStatusDict = [[NSMutableDictionary alloc] init];
    }
    return _reqStatusDict;
}
- (NSMutableDictionary *)reqCallbackDict {
    if (!_reqCallbackDict) {
        _reqCallbackDict = [[NSMutableDictionary alloc] init];
    }
    return _reqCallbackDict;
}

#pragma mark - Setters
- (void)setUserid:(NSString *)userid {
    _userid = userid;
    
    //更新用户的车辆列表 -> 定时刷新设备状态
    [self.bikelist removeAllObjects];
    [self.bikelist addObjectsFromArray:[[G100InfoHelper shareInstance] findMyBikeListWithUserid:_userid]];
}

- (void)setIsCustomInterval:(BOOL)isCustomInterval {
    _isCustomInterval = isCustomInterval;
    [self updateRefreshTimer];
}

#pragma mark - Notification Actions
- (void)ddh_networkChanged:(NSNotification *)noti {
    [self updateRefreshTimer];
}
- (void)ddh_appDidEnterBackground:(NSNotification *)noti {
    [self updateRefreshTimer];
}
- (void)ddh_appDidBecomeActive:(NSNotification *)noti {
    [self updateRefreshTimer];
}
- (void)ddh_remoteLoginHandle:(NSNotification *)noti {
    [self stopRefreshTimer];
}
- (void)ddh_logoutHandle:(NSNotification *)noti {
    [self stopRefreshTimer];
}
- (void)ddh_deleteBikeHandle:(NSNotification *)noti {
    [self updateRefreshTimer];
}
- (void)ddh_bikeAccStatusDidChangedHandle:(NSNotification *)noti {
    G100PushMsgDomain *pushDomain = [[G100PushMsgDomain alloc] initWithDictionary:noti.userInfo];
    NSString *userid = [NSString stringWithFormat:@"%@", @(pushDomain.userid)];
    NSString *bikeid = pushDomain.bikeid;
    [self concernNowWithUserid:userid bikeid:bikeid callback:nil];
}
- (void)ddh_bikeListDidChange:(NSNotification *)noti {
    [self.bikelist removeAllObjects];
    [self.bikelist addObjectsFromArray: [[G100InfoHelper shareInstance] findMyBikeListWithUserid:[G100InfoHelper shareInstance].buserid]];
}

#pragma mark - 刷新定时器
- (void)updateRefreshTimer {
    if ([self.refreshTimer isValid]) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        IDLog(IDLogTypeWarning, @"用户不在前台 -> 已停止刷新");
        return;
    }
    if (!IsLogin()) {
        IDLog(IDLogTypeWarning, @"用户未登录 -> 已停止刷新");
        return;
    }
    
    NSTimeInterval refreshTimeInterval = 0;
    if (self.isCustomInterval) {
        refreshTimeInterval = CUSTOM_REFRESH_INTERVAL;
    }else {
        NSInteger refreshState = [[G100InfoHelper shareInstance] findMapRefreshStateWithUserid:[[G100InfoHelper shareInstance] buserid]];
        if (kNetworkReachableViaWiFi) {
            refreshTimeInterval = WIFI_REFRESH_INTERVAL;
        }else if (kNetworkReachableViaWWAN) {
            switch (refreshState) {
                case 0:
                    refreshTimeInterval = 10*60.0f;
                    break;
                case 2:
                    refreshTimeInterval = 30.0f;
                    break;
                case 3:
                    refreshTimeInterval = 60.0f;
                    break;
                case 4:
                    refreshTimeInterval = 120.0f;
                    break;
                default:
                    break;
            }
        }
    }
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:refreshTimeInterval
                                                         target:self
                                                       selector:@selector(updateAllBikeRuntimeData)
                                                       userInfo:nil
                                                        repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.refreshTimer forMode:NSRunLoopCommonModes];
}

- (void)stopRefreshTimer {
    [self.bikelist removeAllObjects];
    [self.reqStatusDict removeAllObjects];
    
    if ([self.refreshTimer isValid]) {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
}

#pragma mark - Public Method
- (void)updateAllBikeRuntimeData {
    for (G100BikeDomain *bike in self.bikelist) {
        if (bike.devices.count == 0) {
            IDLog(IDLogTypeWarning, @"该车辆没有安装设备");
            continue;
        }
        
        NSString *bikeid = [NSString stringWithFormat:@"%@", @(bike.bike_id)];
        [self updateBikeRuntimeDataWithUserid:self.userid bikeid:bikeid];
    }
}

- (void)addConcernWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    self.userid = userid;
    [self updateRefreshTimer];
}

- (void)removeConcernWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    //弃用 -> 不可以移除关注 默认定时刷新
}

- (void)concernNowWithUserid:(NSString *)userid bikeid:(NSString *)bikeid callback:(API_CALLBACK)callback {
    [self addConcernWithUserid:userid bikeid:bikeid];
    [self updateBikeRuntimeDataWithUserid:userid bikeid:bikeid callback:callback];
}

#pragma mark - Private Method
- (void)updateBikeRuntimeDataWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    [self updateBikeRuntimeDataWithUserid:userid bikeid:bikeid callback:nil];
}
- (void)updateBikeRuntimeDataWithUserid:(NSString *)userid bikeid:(NSString *)bikeid callback:(API_CALLBACK)callback {
    if (!userid || !bikeid) {
        IDLog(IDLogTypeWarning, @"缺少请求参数");
        if (callback) {
            callback(0, nil, NO);
        }
        return;
    }
    
    if (!IsLogin()) {
        IDLog(IDLogTypeWarning, @"用户未登录");
        if (callback) {
            callback(0, nil, NO);
        }
        return;
    }
    
    // 首先判断 是否是当前登陆的帐号
    userid = [NSString stringWithFormat:@"%@", @([userid integerValue])];
    if (![userid isEqualToString:[[G100InfoHelper shareInstance] buserid]]) {
        IDLog(IDLogTypeWarning, @"请求 userid 与当前登陆用户不匹配");
        if (callback) {
            callback(0, nil, NO);
        }
        return;
    }
    
    // 然后判断 当前用户有没有绑定这辆车
    NSArray *bikeList = [[G100InfoHelper shareInstance] findMyBikeListWithUserid:userid];
    
    BOOL result = NO;
    for (G100BikeDomain *bike in bikeList) {
        if (bike.bike_id == [bikeid integerValue]) {
            result = YES;
        }
    }
    
    if (!result) {
        IDLog(IDLogTypeWarning, @"用户没有该车");
        if (callback) {
            callback(0, nil, NO);
        }
        return;
    }
    
    NSInteger traceMode = self.isCustomInterval ? 1 : 0;
    NSString *concernedKey = [NSString stringWithFormat:@"%@+%@", userid, bikeid];
    
    // 先将 callback 存放在内存中
    if (callback) {
        NSMutableArray *items = [self.reqCallbackDict objectForKey:concernedKey];
        if (items == nil) {
            items = [[NSMutableArray alloc] init];
        }
        
        [items addObject:callback];
        [self.reqCallbackDict setObject:items forKey:concernedKey];
    }
    
    NSInteger reqUnFinished = [[self.reqStatusDict objectForKey:concernedKey] integerValue];
    if (reqUnFinished > 3) {
        reqUnFinished = 0;
        [self.reqStatusDict setObject:[NSNumber numberWithInteger:0] forKey:concernedKey];
    }else if (reqUnFinished > 0) {
        IDLog(IDLogTypeWarning, @"存在未完成的请求-%@，请稍后", concernedKey);
        return;
    }
    
    // 发送数据更新请求
    [self.reqStatusDict setObject:[NSNumber numberWithInteger:reqUnFinished++] forKey:concernedKey];
    [[G100BikeApi sharedInstance] getBikeRuntimeWithBike_ids:@[ bikeid ] traceMode:traceMode callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateBikeRuntimeWithUser_id:[userid integerValue] bike_id:[bikeid integerValue] bikeRuntime:[response mj_keyValues]];
        }else {
            NSDictionary *bikeRuntime = [[CDDDataHelper cdd_sharedInstace] cdd_findBikeRuntimeWithUser_id:[userid integerValue] bike_id:[bikeid integerValue]];
            if (bikeRuntime) {
                response = [ApiResponse mj_objectWithKeyValues:bikeRuntime];
            }
        }
        
        // 回调处理
        NSMutableArray *callbacksArray = [self.reqCallbackDict objectForKey:concernedKey];
        for (API_CALLBACK callback in callbacksArray) {
            if (callback) {
                callback(statusCode, response, requestSuccess);
            }
        }
        
        [self.reqCallbackDict removeObjectForKey:concernedKey];
        [self.reqStatusDict setObject:[NSNumber numberWithInteger:0] forKey:concernedKey];
        
        // 通知消息
        [[NSNotificationCenter defaultCenter] postNotificationName:kDevDataReceivedNotification
                                                            object:response
                                                          userInfo:@{@"userid" : EMPTY_IF_NIL(userid),
                                                                     @"bikeid" : EMPTY_IF_NIL(bikeid)}];
    }];
}

@end

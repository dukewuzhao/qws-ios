//
//  UserManager.m
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "UserManager.h"
#import "CHKeychain.h"
#import "SoundManager.h"

#import "G100UserApi.h"
#import "G100DevApi.h"
#import "NotificationHelper.h"
#import "G100SampleMarking.h"
#import "DatabaseOperation.h"
#import "G100Mediator+Login.h"
#import "G100BikeApi.h"
#import <SDWebImage/SDWebImageManager.h>
#import <WebKit/WebKit.h>
static NSString * const kTokenExpires_in = @"token_expires_in";
static NSString * const kTokenSaveTime   = @"token_save_time";

@interface UserManager ()

@property (nonatomic, strong) NSTimer * postTimer;
@property (nonatomic, strong) NSTimer * updateInfoTimer;

@property (nonatomic, copy) NSString *defaultWebUa;
@property (nonatomic, copy) NSString *defaultReqUa;
@property (nonatomic, copy) NSString *defaultDownloaderUa;

@end

@implementation UserManager

-(BOOL)checkTokenNeedRefresh {
    if (!self.isLogin) {
        return NO;
    }
    
    NSInteger expires_in = [[self getAsynchronousWithKey:kTokenExpires_in] integerValue];
    NSInteger save_time = [[self getAsynchronousWithKey:kTokenSaveTime] integerValue];
    NSInteger current_time = [[NSDate date] timeIntervalSince1970];
    
    if (expires_in - (current_time - save_time) <= 300) {
        DLog(@"UserManager: 提醒您！Token 即将过期，正在帮您刷新token，请不要害怕😨");
        [self autoLoginWithComplete:nil];
        return YES;
    }
    
    DLog(@"UserManager: 提醒您！Token 剩余时间为：%@秒", @(expires_in - (current_time - save_time)));
    
    return NO;
}

-(void)updateTokenStatus:(NSDictionary *)loginInfo {
    self.token = loginInfo[@"token"];
    
    if (loginInfo[@"expires_in"]) {
        NSInteger expires_in = [loginInfo[@"expires_in"] integerValue];
        [self setAsynchronous:@(expires_in) withKey:kTokenExpires_in];
        [self setAsynchronous:@([[NSDate date] timeIntervalSince1970]) withKey:kTokenSaveTime];
    }
}

-(void)loginWithUsername:(NSString *)username password:(NSString *)password userInfo:(NSDictionary *)loginInfo {
    [G100InfoHelper shareInstance].isFirstLogin = YES;
    [[G100InfoHelper shareInstance] loginWithUsername:username password:password userInfo:loginInfo];
    
    NSString *buserid = loginInfo[@"user_info"][@"user_id"];
    
    self.remoteLogin = NO;
    
    [self startPostPush];
    [self startUpdateInfo];
    [self updateTokenStatus:loginInfo];
    
    [[DatabaseOperation operation] countUnreadNumberWithUserid:[buserid integerValue] success:^(NSInteger personalUnreadNum, NSInteger systemUnreadNum) {
        // 设置消息未读条数
        [[NotificationHelper shareInstance] nh_newBadge:personalUnreadNum+systemUnreadNum];
    }];
}

-(void)logoff {
    [self stopPostPush];
    [self stopUpdateInfo];
    
    self.remoteLogin = NO;
    [[SoundManager sharedManager] stopAlertSound];
    // 退出成功 移除水印
    [[G100SampleMarking shareInstance] removeSampleMarkingView];
    [[G100InfoHelper shareInstance] clearAllData];
    [[NotificationHelper shareInstance] nh_newBadge:0];
}

-(NSString *)appVersion {
    return [[G100InfoHelper shareInstance] appVersion];
}

-(BOOL)isLogin {
    return [[G100InfoHelper shareInstance] isLogin];
}

-(BOOL)isBind {
    return [[G100InfoHelper shareInstance] isBind];
}

+(UserManager *)shareManager {
    static dispatch_once_t onceTonken;
    static UserManager * sharedInstance = nil;
    dispatch_once(&onceTonken, ^{
        sharedInstance = [[UserManager alloc] init];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        sharedInstance.defaultWebUa = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        sharedInstance.defaultReqUa = @"360qws CFNetwork/897.15 Darwin/17.5.0";
        sharedInstance.defaultDownloaderUa = @"360qws CFNetwork/897.15 Darwin/17.5.0";
    });
    
    return sharedInstance;
}

-(void)setupUa {
    NSString *uaVersion = [NSString stringWithFormat:@"%@/%@", @"QWS", self.appVersion];
    _env = @"";
    _webUa = [NSString stringWithFormat:@"%@; %@", self.defaultWebUa, uaVersion];
    _reqUa = [NSString stringWithFormat:@"%@; %@", self.defaultReqUa, uaVersion];
    _downloaderUa = [NSString stringWithFormat:@"%@; %@", self.defaultDownloaderUa, uaVersion];
    
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:self.webUa, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[SDWebImageManager sharedManager].imageDownloader setValue:[NSString stringWithFormat:@"%@; %@", self.defaultDownloaderUa, uaVersion]
                                             forHTTPHeaderField:@"User-Agent"];
}

-(void)runTestUa {
    NSString *uaVersion = [NSString stringWithFormat:@"%@/%@", @"QWS", self.appVersion];
    if ([self.webUa hasContainString:@"QWSDEV"]) {
        _env = @"";
        uaVersion = [NSString stringWithFormat:@"%@/%@", @"QWS", self.appVersion];
        [CURRENTVIEWCONTROLLER showHint:@"已关闭开发模式"];
    }
    else {
        _env = @"betateam";
        uaVersion = [NSString stringWithFormat:@"%@/%@", @"QWSDEV", self.appVersion];
        [CURRENTVIEWCONTROLLER showHint:@"已进入开发模式"];
    }
    
    _webUa = [NSString stringWithFormat:@"%@; %@", self.defaultWebUa, uaVersion];
    _reqUa = [NSString stringWithFormat:@"%@; %@", self.defaultReqUa, uaVersion];
    _downloaderUa = [NSString stringWithFormat:@"%@; %@", self.defaultDownloaderUa, uaVersion];
    
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:self.webUa, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[SDWebImageManager sharedManager].imageDownloader setValue:[NSString stringWithFormat:@"%@; %@", self.defaultDownloaderUa, uaVersion]
                                             forHTTPHeaderField:@"User-Agent"];
}

-(NSString *)name {
    return [[G100InfoHelper shareInstance] username];
}
-(void)setName:(NSString *)name {
    [G100InfoHelper shareInstance].username = name;
}

-(NSString *)password {
    return [[G100InfoHelper shareInstance] password];
}

-(void)setPassword:(NSString *)password {
    [G100InfoHelper shareInstance].password = password;
}

-(void)setLoginType:(UserLoginType)loginType {
    [G100InfoHelper shareInstance].loginType = loginType;
}

-(UserLoginType)loginType {
    return [[G100InfoHelper shareInstance] loginType];
}

-(void)setThirdUserid:(NSString *)thirdUserid {
    [G100InfoHelper shareInstance].thirdUserid = thirdUserid;
}

-(NSString *)thirdUserid {
    return [[G100InfoHelper shareInstance] thirdUserid];
}

-(void)setPartneruseruid:(NSString *)partneruseruid {
    [G100InfoHelper shareInstance].thirdPartnerUseruid = partneruseruid;
}

-(NSString *)partneruseruid {
    return [[G100InfoHelper shareInstance] thirdPartnerUseruid];
}

-(void)setToken:(NSString *)token {
    [G100InfoHelper shareInstance].token = token;
}
-(NSString *)token {
    return [[G100InfoHelper shareInstance] token];
}

#pragma mark - 用户本地数据处理
-(void)setAsynchronous:(id)object withKey:(NSString *)key {
    if ([object isKindOfClass:[NSNull class]]) {
        return;
    }
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary * tmpdict = (NSDictionary *)object;
        NSMutableDictionary * dict = tmpdict.mutableCopy;
        NSMutableArray * tmp = [[NSMutableArray alloc]init];
        for (NSString * key in [dict allKeys]) {
            NSString * str = [dict objectForKey:key];
            if ([str isKindOfClass:[NSNull class]]) {
                [tmp addObject:key];
            }
        }
        [dict removeObjectsForKeys:tmp];
        object = dict.copy;
    }
    
    NSUserDefaults * info = [NSUserDefaults standardUserDefaults];
    [info setObject:object forKey:key];
    [info synchronize];
}
-(void)clearAsynchronousWithKey:(NSString *)key {
    NSUserDefaults * info = [NSUserDefaults standardUserDefaults];
    [info removeObjectForKey:key];
    [info synchronize];
}
-(id)getAsynchronousWithKey:(NSString *)key {
    NSUserDefaults * info = [NSUserDefaults standardUserDefaults];
    return [info valueForKey:key];
}

#pragma mark - 用户的网络数据同步
-(void)autoLoginWithComplete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock {
    UserLoginType loginType = [[G100InfoHelper shareInstance] loginType];
    NSString * name = [[G100InfoHelper shareInstance] username];
    NSString * password = [[G100InfoHelper shareInstance] password];
    
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            NSDictionary *loginInfo = [response data]; //仅仅保存token
            NSString *buserid = loginInfo[@"user_info"][@"user_id"];
            [G100InfoHelper shareInstance].token = loginInfo[@"token"];
            [[G100InfoHelper shareInstance] updateMyAccountInfoWithUserid:buserid accountInfo:loginInfo];
            [self updateUserInfoWithUserid:buserid complete:nil];
            [self updateBikeListWithUserid:buserid complete:nil];
            [self startPostPush];
            [self startUpdateInfo];
            [self updateTokenStatus:loginInfo];
        }else {
            // 1.3.8 新增 自动登录过程中 遭遇需要输入图形验证码 则退出登录
            if ([response needPicvcVerified]) {
                [[G100Api sharedInstance] cancelAllRequest];
                
                /**
                 *  判断当前是否在登陆界面
                 *  是 不作操作
                 *  不是 则清空信息跳转到登录界面
                 */
                if ([CURRENTVIEWCONTROLLER isKindOfClass:[NSClassFromString(@"G100UserLoginViewController") class]] ||
                    [UserManager shareManager].remoteLogin) {
                    
                }else {
                    [UserManager shareManager].remoteLogin = NO;
                    [[UserManager shareManager] logoff];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGNAppLoginOrLogoutNotification object:@(NO) userInfo:nil];
                    [[G100Mediator sharedInstance] G100Mediator_presentViewControllerForLogin:nil completion:^{
                        [APPDELEGATE.mainNavc popToRootViewControllerAnimated:NO];
                    }];
                    [APPDELEGATE.mainNavc showHint:@"您的密码已过期，请重新登录"];
                }
            }
        }
        
        if (completeBlock) {
            completeBlock(statusCode, response, requestSuccess);
        }
    };
    
    // 两种情况 一种是帐号登录 存在帐号名和密码    二种是第三方登录    存在用户ID在生成临时密码+登录方式
    if (loginType == UserLoginTypePhoneNum) {
        [[G100UserApi sharedInstance] sv_loginUserWithLoginName:name
                                                    andPassword:password
                                                        partner:nil
                                                 partneraccount:nil
                                            partneraccounttoken:nil
                                                 partneruseruid:nil
                                                   logintrigger:1
                                                         picurl:nil
                                                          picid:nil
                                                       inputbar:nil
                                                      sessionid:nil
                                                          usage:0
                                                       callback:callback];
    }else if (loginType == UserLoginTypeWeixin ||
              loginType == UserLoginTypeSina ||
              loginType == UserLoginTypeQQ)
    {
        NSString * partner = nil;
        if (loginType == UserLoginTypeWeixin) {
            partner = @"wx";
        }else if (loginType == UserLoginTypeSina) {
            partner = @"sina";
        }else if (loginType == UserLoginTypeQQ) {
            partner = @"qq";
        }
        
        NSString * partneraccount = [[G100InfoHelper shareInstance] thirdUserid];
        NSString * partneruseruid = [[G100InfoHelper shareInstance] thirdPartnerUseruid];
        // 制作用户的临时密码 临时密码格式：360[渠道][用户id]QWS[YYYYMMDD] + md5
        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyyMMdd"];
        NSString * pw = [formatter stringFromDate:[NSDate date]];
        NSString * partneraccounttoken = [[NSString stringWithFormat:@"360%@%@QWS%@", partner, partneraccount, pw] stringFromMD5];

         [[G100UserApi sharedInstance] sv_loginUserWithLoginName:name
                                                     andPassword:password
                                                         partner:partner
                                                  partneraccount:partneraccount
                                             partneraccounttoken:partneraccounttoken
                                                  partneruseruid:partneruseruid
                                                    logintrigger:1
                                                          picurl:nil
                                                           picid:nil
                                                        inputbar:nil
                                                       sessionid:nil
                                                           usage:0
                                                        callback:callback];
    }else {
        // 自动登录方式有误 即已经是在退出登陆模式
        if (completeBlock) {
            completeBlock(0, nil, NO);
        }
    }
}

-(void)updateUserInfoWithUserid:(NSString *)userid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock {
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            if (NOT_NULL(response.data)) {
                NSDictionary * result = [[response.data objectForKey:@"users"] firstObject];
                [[G100InfoHelper shareInstance] updateMyUserInfoWithUserid:[[G100InfoHelper shareInstance] buserid] userInfo:result];
            }
        }else {
            DLog(@"更新用户信息失败-%@", response.errDesc);
        }
        
        if (completeBlock) {
            completeBlock(statusCode, response, requestSuccess);
        }
    };
    
    [[G100UserApi sharedInstance] queryUserinfoWithUserid:@[[NSNumber numberWithInteger:[userid integerValue]]] callback:callback];
}
-(void)updateDevInfoWithUserid:(NSString *)userid devid:(NSArray *)devid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock {
    if (!devid.count || !devid) {
        // 如果devid 不为空 则更新车辆列表
        [self updateDevlistWithComplete:completeBlock];
        return;
    }
    
    // 仅更新部分车辆信息    并不是所有车辆
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            // 保存用户车    id
            NSArray * devArr = [response.data objectForKey:@"devList"];
            NSArray * secset = [response.data objectForKey:@"secset"];
            [[G100InfoHelper shareInstance] updateMyDevInfoWithUserid:userid devlist:devArr secset:secset];
            // 通知电动车列表有刷新
            [[NSNotificationCenter defaultCenter] postNotificationName:kGNRefreshCarList object:nil];
            
            for (NSInteger i = 0; i < [devArr count]; i++) {
                NSDictionary *dict = [devArr safe_objectAtIndex:i];
                [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateBikeDataWithUser_id:[userid integerValue]
                                                                              bike_id:[[devid safe_objectAtIndex:i] integerValue]
                                                                                 bike:dict];
            }
        }else {
            DLog(@"更新车辆信息失败-%@", response.errDesc);
        }
        
        if (completeBlock) {
            completeBlock(statusCode, response, requestSuccess);
        }
    };
    
    [[G100BikeApi sharedInstance] getBikelistWithUserid:userid bikeids:devid callback:callback];
}
-(void)updateDevlistWithComplete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock {
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            // 保存用户车    id
            NSArray * devArr = [response.data objectForKey:@"bikes"];
            [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateBikesDataWithUser_id:[[G100InfoHelper shareInstance].buserid integerValue] bikes:devArr];
        }else {
            DLog(@"更新车辆列表失败-%@", response.errDesc);
        }
        
        if (completeBlock) {
            completeBlock(statusCode, response, requestSuccess);
        }
    };
    
    [[G100BikeApi sharedInstance] getBikelistWithUserid:[G100InfoHelper shareInstance].buserid bikeids:nil callback:callback];

}
-(void)postPush:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock {
    NSString * buserid = [[G100InfoHelper shareInstance] buserid];
    NSString * bchannelid = [[G100InfoHelper shareInstance] bchannelid];
    
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (completeBlock) {
            completeBlock(statusCode, response, requestSuccess);
        }
    };
    
    [[G100UserApi sharedInstance] pushRemoteNotificationInstallWithPuserid:buserid andPchannelid:bchannelid pushchannel:(ISJPush ? @"J" : @"B") callback:callback];
}

#pragma mark - 推送注册相关
-(void)startPostPush {
    if (!_appHasActived) {
        return;
    }
    
    if (!_postTimer) {
        self.postTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                          target:self
                                                        selector:@selector(beginToPostPush)
                                                        userInfo:nil
                                                         repeats:YES];
    }
    
    [self.postTimer setFireDate:[NSDate distantPast]];
    DLog(@"注册推送定时器已开启");
}
-(void)beginToPostPush {
    NSString * registrationID = [[G100InfoHelper shareInstance] bchannelid];
    if (registrationID && registrationID.length) {
        NSString * buserid = [[G100InfoHelper shareInstance] buserid];
        
        if (!buserid || !buserid.length) {
            DLog(@"没有获取到BuersID");
            return;
        }
        
        if (NOT_NULL(buserid) && NOT_NULL(registrationID)) {
            __weak UserManager *wself = self;
            [self postPush:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    DLog(@"注册推送成功");
                    [wself stopPostPush];
                }else {
                    DLog(@"注册推送失败：%@", response.errDesc);
                    [wself performSelector:@selector(startPostPush) withObject:nil afterDelay:5.0];
                }
            }];
            
            [self stopPostPush];
        }
    }else {
        DLog(@"没有获取到极光ID");
    }
}
-(void)stopPostPush {
    if ([_postTimer isValid]) {
        [self.postTimer invalidate];
        self.postTimer = nil;
    }
    
    DLog(@"注册推送定时器已关闭");
}

#pragma mark - 更新相关信息
-(void)startUpdateInfo {
    if (!_appHasActived) {
        return;
    }
    if (!_updateInfoTimer) {
        self.updateInfoTimer = [NSTimer scheduledTimerWithTimeInterval:10 * 60.0f
                                                                target:self
                                                              selector:@selector(beginToUpdateInfo)
                                                              userInfo:nil
                                                               repeats:YES];
    }
    [self.postTimer setFireDate:[NSDate distantPast]];
    DLog(@"更新数据服务已开启");
}
-(void)beginToUpdateInfo {
    NSArray *bikeArray = [[G100InfoHelper shareInstance] findMyBikeListWithUserid:[[G100InfoHelper shareInstance] buserid]];
    if (self.isLogin && bikeArray.count >0 && [UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNUpdatePower object:nil];
    }
    
    // 检查token 是否即将过期
    [self checkTokenNeedRefresh];
}
-(void)stopUpdateInfo {
    if ([_updateInfoTimer isValid]) {
        [self.updateInfoTimer invalidate];
        self.updateInfoTimer = nil;
    }
    
    DLog(@"更新数据服务已关闭");
}

#pragma mark - 2.0 Method 用户的网络数据同步
-(void)updateBikeListWithUserid:(NSString *)userid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock {
    [self updateBikeListWithUserid:userid updateType:BikeListNormalType complete:completeBlock];
}
-(void)updateBikeListWithUserid:(NSString *)userid updateType:(BikeListUpdateType)updateType complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock{
    
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            // 保存用户车    id
            NSArray * devArr = [response.data objectForKey:@"bikes"];
            [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateBikesDataWithUser_id:[userid integerValue] bikes:devArr updateType:updateType];
        }else {
            IDLog(IDLogTypeWarning, @"更新车辆列表失败-%@", response.errDesc);
        }
        
        if (completeBlock) {
            completeBlock(statusCode, response, requestSuccess);
        }
    };
    
    [[G100BikeApi sharedInstance] getAllBikelistWithUserid:userid callback:callback];
}
-(void)updateBikeInfoWithUserid:(NSString *)userid bikeid:(NSString *)bikeid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock {
    [self updateBikeInfoWithUserid:userid bikeid:bikeid updateType:BikeInfoNormalType complete:completeBlock];
}
-(void)updateBikeInfoWithUserid:(NSString *)userid bikeid:(NSString *)bikeid updateType:(BikeInfoUpdateType)updateType complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock {
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            // 保存用户车    id
            NSArray * devArr = [response.data objectForKey:@"bikes"];
            [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateBikeDataWithUser_id:[userid integerValue]
                                                                          bike_id:[bikeid integerValue]
                                                                             bike:[devArr firstObject]
                                                                       updateType:updateType];
        }else {
            IDLog(IDLogTypeWarning, @"更新车辆信息失败-%@", response.errDesc);
        }
        
        if (completeBlock) {
            completeBlock(statusCode, response, requestSuccess);
        }
    };
    
    [[G100BikeApi sharedInstance] getBikeInfoWithUserid:userid bikeid:bikeid callback:callback];
}

-(void)updateDevListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock {
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            // 保存用户车    id
            NSArray * devicesArr = [[[response.data objectForKey:@"bikes"] firstObject] objectForKey:@"devices"];
            [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateDevicesDataWithUser_id:[userid integerValue]
                                                                             bike_id:[bikeid integerValue]
                                                                             devices:devicesArr];
        }else {
            IDLog(IDLogTypeWarning, @"更新设备列表失败-%@", response.errDesc);
        }
        
        if (completeBlock) {
            completeBlock(statusCode, response, requestSuccess);
        }
    };
    if (bikeid) {
        [[G100BikeApi sharedInstance] getBikeInfoWithUserid:userid bikeid:bikeid callback:callback];
    }else{
        [[G100BikeApi sharedInstance] getBikelistWithUserid:userid bikeids:nil callback:callback];
    }

}
-(void)updateDevInfoWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid complete:(void (^)(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess))completeBlock {
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            // 保存用户车    id
            NSArray * devicesArr = [[[response.data objectForKey:@"bikes"] firstObject] objectForKey:@"devices"];
            
            for (NSDictionary *dict in devicesArr) {
                if ([[dict objectForKey:@"device_id"] integerValue] == [devid integerValue]) {
                    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateDeviceDataWithUser_id:[userid integerValue]
                                                                                    bike_id:[bikeid integerValue]
                                                                                  device_id:[devid integerValue]
                                                                                     device:dict];
                }
            }
        }else {
            IDLog(IDLogTypeWarning, @"更新设备信息失败-%@", response.errDesc);
        }
        
        if (completeBlock) {
            completeBlock(statusCode, response, requestSuccess);
        }
    };
    
    [[G100BikeApi sharedInstance] getBikeInfoWithUserid:userid bikeid:bikeid callback:callback];
}

@end

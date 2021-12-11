//
//  G100LinfoHelper.m
//  G100
//
//  Created by Tilink on 15/10/14.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100InfoHelper.h"
#import "CDDDataHelper.h"

NSString * const kGXFirstInstall        = @"firstinstall";
NSString * const kGXFirstLogin          = @"firstlogin";
NSString * const kGXUsername            = @"user_id";
NSString * const kGXPassword            = @"password";
NSString * const kGXToken               = @"token";
NSString * const kGXOldAppVersion       = @"oldappversion";

NSString * const kGXUserLoginType       = @"userlogintype";
NSString * const kGXThirdLoginUserid    = @"thirdloginuserid";
NSString * const kGXThirdPartnerUseruid = @"thirdpartneruseruid";

NSString * const kGXBUserid             = @"mybuserid";
NSString * const kGXBChannelid          = @"mybchannelid";
NSString * const kGXAccountInfo         = @"account_info";
NSString * const kGXUserInfo            = @"user_info";
NSString * const kGXCurrentDevInfo      = @"current_dev";
NSString * const kGXDevlist             = @"devlist";
NSString * const kGXDevFeature          = @"devfeature";

NSString * const kGXScoreChanged        = @"scorechanged";
NSString * const kGXDevSecset           = @"mydevsecset";
NSString * const kGXDevTestResult       = @"mytestresult";
NSString * const kGXDevPromptTime       = @"promptTime";
NSString * const kGXWeatherReportResult = @"weatherreportresult";
NSString * const kGXCurrentEvent        = @"currentEvent";
NSString * const kGXCurrentBikeEvent    = @"currentbikeevent";
NSString * const kGXCurrentDevEvent     = @"currentdevevent";
NSString * const kGXNewOfflineMsg       = @"newOfflineMsg";
NSString * const kGXMapRefreshState     = @"maprefreshstate";

NSString * const kGXUpgradeID           = @"upgradeID";

@interface G100InfoHelper ()

@property (nonatomic, copy) NSString * qwstoken;

@property (nonatomic, copy) NSString * qwsUsername;

@property (nonatomic, copy) NSString * qwsPassword;

@property (nonatomic, copy) NSString * qwsUserId;

@property (nonatomic, strong) NSDictionary * qwsAccountInfo;

@property (nonatomic, strong) NSDictionary * qwsUserInfo;

@property (nonatomic, copy) NSString * qwsBChannelid;

@end

@implementation G100InfoHelper

+(instancetype)shareInstance {
    static dispatch_once_t onceTonken;
    static G100InfoHelper * shareInstance = nil;
    dispatch_once(&onceTonken, ^{
        shareInstance = [[G100InfoHelper alloc]init];
    });
    
    return shareInstance;
}

- (NSMutableDictionary *)statusMap {
    if (!_statusMap) {
        _statusMap = [[NSMutableDictionary alloc] init];
    }
    return _statusMap;
}

-(void)setUsername:(NSString *)username {
    
    _qwsUsername = username;
    
    // 清除旧版存储的用户名信息
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * oldUsername = [userDefaults objectForKey:kGXUsername];
    if (oldUsername) {
        [userDefaults removeObjectForKey:kGXUsername];
    }
    
    [CHKeychain save:kGXUsername data:username];
}
-(NSString *)username {
    
    if (_qwsUsername) {
        return _qwsUsername;
    }
    
    NSString * username = [CHKeychain load:kGXUsername];
    
    if (username) {
        _qwsUsername = username;
        return username;
    }else {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        username = [userDefaults objectForKey:kGXUsername];
        
        if (username) {
            _qwsUsername = username;
            return username;
        }
    }
    
    return nil;
}

-(void)setPassword:(NSString *)password {
    
    // 明文传入 保存的时候加密 防止多次加密
    NSString * md5Pw = [[NSString stringWithFormat:@"G%@100", password] stringFromMD5];
    
    _qwsPassword = md5Pw;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * oldPassword = [userDefaults objectForKey:kGXPassword];
    
    if (oldPassword) { // 清除旧版用户存储的密码
        [userDefaults removeObjectForKey:kGXPassword];
    }
    
    [CHKeychain save:kGXPassword data:md5Pw];
}
-(NSString *)password {
    
    if (_qwsPassword) {
        return _qwsPassword;
    }
    
    // 取出的就是加密过的
    NSString * password = [CHKeychain load:kGXPassword];
    
    if (password) {
        _qwsPassword = password;
        return password;
    }else {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        password = [userDefaults objectForKey:kGXPassword];
        
        if (password) {
            _qwsPassword = password;
            return password;
        }
    }
    
    return password;
}

-(void)setToken:(NSString *)token {
    // 清除旧版用户存储的token
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * oldToken = [userDefaults objectForKey:kGXToken];
    if (oldToken) {
        [userDefaults removeObjectForKey:kGXToken];
    }
    
    self.isFirstInstall = NO; // 登陆成功
    [CHKeychain save:kGXToken data:token];
    
    _qwstoken = token;
}
-(NSString *)token {
    // 首次安装 返回nil
    if (self.isFirstInstall) {
        return nil;
    }
    
    if (_qwstoken) {
        return self.qwstoken;
    }
    
    NSString * token = [CHKeychain load:kGXToken];
    
    if (token) {
        _qwstoken = token;
        return token;
    }else {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        token = [userDefaults objectForKey:kGXToken];
        
        if (token) {
            _qwstoken = token;
            return token;
        }
    }
    
    return token;
}

-(NSString *)appVersion {
    if (_appVersion) {
        return _appVersion;
    }
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    _appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return _appVersion;
}

-(void)setOldAppVersion:(NSString *)oldAppVersion {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:oldAppVersion forKey:kGXOldAppVersion];
    [userDefaults synchronize];
}

-(NSString *)oldAppVersion {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * oldAppVersion = [userDefaults objectForKey:kGXOldAppVersion];
    return oldAppVersion;
}

-(void)setBuserid:(NSString *)buserid {
    
    _qwsUserId = buserid;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * oldBuserid = [userDefaults objectForKey:kGXBUserid];
    if (oldBuserid) {
        [userDefaults removeObjectForKey:kGXBUserid];
    }
    
    [CHKeychain save:kGXBUserid data:buserid];
}
-(NSString *)buserid {
    
    if (_qwsUserId) {
        return _qwsUserId;
    }
    
    NSString * buserid = nil;
    id bbbuserid = [CHKeychain load:kGXBUserid];
    if ([bbbuserid isKindOfClass:[NSString class]]) {
        buserid = (NSString *)bbbuserid;
    }else {
        buserid = [bbbuserid stringValue];
    }
    
    if (buserid) {
        _qwsUserId = buserid;
        return buserid;
    }else {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        buserid = [userDefaults objectForKey:kGXBUserid];
        if ([bbbuserid isKindOfClass:[NSString class]]) {
            buserid = (NSString *)bbbuserid;
        }else {
            buserid = [bbbuserid stringValue];
        }
        
        if (buserid) {
            _qwsUserId = buserid;
            return buserid;
        }
    }
    
    return buserid;
}

-(void)setBchannelid:(NSString *)bchannelid {

    _qwsBChannelid = bchannelid;
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:bchannelid forKey:kGXBChannelid];
    [userDefaults synchronize];
}
-(NSString *)bchannelid {
    
    if (_qwsBChannelid) {
        return _qwsBChannelid;
    }
    
    NSString * bchannelid = nil;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    bchannelid = [userDefaults objectForKey:kGXBChannelid];
    
    _qwsBChannelid = bchannelid;
    
    return bchannelid;
}

-(void)setIsFirstLogin:(BOOL)isFirstLogin {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isFirstLogin forKey:kGXFirstLogin];
    [userDefaults synchronize];
}
-(BOOL)isFirstLogin {
    BOOL isFirstLogin = NO;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    isFirstLogin = [userDefaults boolForKey:kGXFirstLogin];
    return isFirstLogin;
}

-(void)setIsFirstInstall:(BOOL)isFirstInstall {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isFirstInstall forKey:kGXFirstInstall];
    [userDefaults synchronize];
}
-(BOOL)isFirstInstall {
    BOOL isFirstInstall = NO;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userDefaults objectForKey:kGXFirstInstall]) {
        isFirstInstall = [userDefaults boolForKey:kGXFirstInstall];
    } else {
        NSString * token = nil;
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        token = [userDefaults objectForKey:kGXToken];
        
        if (token) {
            return NO;
        }
        
        return YES;
    }
    
    return isFirstInstall;
}

-(BOOL)isLogin {
    if (self.token.length) {
        return YES;
    }
    
    return NO;
}

-(BOOL)isBind {
    // 如果设备列表中存在正常设备 则是已绑定
    NSArray *devList = [self findMyBikeListWithUserid:self.buserid];
    for (NSDictionary *dict in devList) {
        G100DeviceDomain *devDomain = [[G100DeviceDomain alloc] initWithDictionary:dict];
        if ([devDomain isNormalDevice]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)setThirdUserid:(NSString *)thirdUserid {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:thirdUserid forKey:kGXThirdLoginUserid];
    [userDefaults synchronize];
}
-(NSString *)thirdUserid {
    NSString * thirdUserid = nil;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    thirdUserid = [userDefaults objectForKey:kGXThirdLoginUserid];
    return thirdUserid;
}

-(void)setThirdPartnerUseruid:(NSString *)thirdPartnerUseruid {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:thirdPartnerUseruid forKey:kGXThirdPartnerUseruid];
    [userDefaults synchronize];
}
-(NSString *)thirdPartnerUseruid {
    NSString * thirdPartnerUseruid = nil;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    thirdPartnerUseruid = [userDefaults objectForKey:kGXThirdPartnerUseruid];
    return thirdPartnerUseruid;
}

-(void)setLoginType:(UserLoginType)loginType {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:loginType forKey:kGXUserLoginType];
    [userDefaults synchronize];
}
-(UserLoginType)loginType {
    UserLoginType loginType = UserLoginTypePhoneNum;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    loginType = [userDefaults integerForKey:kGXUserLoginType];
    return loginType;
}

-(BOOL)isFirstOpenFromNewAppVersion {
    NSString * old = [self oldAppVersion];
    if (!old) {
        return YES;
    }
    
    // 版本号的比较 首次打开app的时候 旧版本号没有更新
    if ([NSString isVersion:[self appVersion] biggerThanVersion:old]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - 用户信息存取
-(NSDictionary *)currentAccountInfo {
    
    if (_qwsAccountInfo) {
        return _qwsAccountInfo;
    }
    
    NSDictionary * dict = [CHKeychain load:kGXAccountInfo];
    if (dict) {
        
    }else {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        dict = [userDefaults objectForKey:kGXAccountInfo];
    }
    
    _qwsAccountInfo = dict;
    
    return dict;
}
-(NSDictionary *)currentUserInfo {
    
    if (_qwsUserInfo) {
        return _qwsUserInfo;
    }
    
    NSDictionary * dict = [CHKeychain load:kGXUserInfo];
    if (dict) {
        
    }else {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        dict = [userDefaults objectForKey:kGXUserInfo];
    }
    
    _qwsUserInfo = dict;
    
    return dict;
}

-(BOOL)updateMyAccountInfoWithUserid:(NSString *)userid accountInfo:(NSDictionary *)dict {
    // 2.0 版本支持多用户
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * oldAccuntInfo = [userDefaults objectForKey:kGXAccountInfo];
    
    if (oldAccuntInfo) {
        [userDefaults removeObjectForKey:kGXAccountInfo];
    }
    
    _qwsAccountInfo = dict.copy;
    [CHKeychain save:kGXAccountInfo data:dict];
    
    // 使用CoreData 存储
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateAccountDataWithUser_id:[userid integerValue] account:dict];
    
    return YES;
}
-(G100AccountDomain *)findMyAccountInfoWithUserid:(NSString *)userid {
    NSDictionary * dict = [CHKeychain load:kGXAccountInfo];
    if (dict) {
        
    }else {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        dict = [userDefaults objectForKey:kGXAccountInfo];
    };
    
    if (!dict) {
        return nil;
    }
    
    G100AccountDomain * accountInfo = [[CDDDataHelper cdd_sharedInstace] cdd_findAccountDataWithUser_id:[userid integerValue]];
    return accountInfo;
}

-(BOOL)updateMyUserInfoWithUserid:(NSString *)userid userInfo:(NSDictionary *)dict {
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * oldUserinfo = [userDefaults objectForKey:kGXUserInfo];
    
    if (oldUserinfo) {
        [userDefaults removeObjectForKey:kGXUserInfo];
    }
    
    _qwsUserInfo = dict.copy;
    [CHKeychain save:kGXUserInfo data:dict];
    
    // 使用CoreData 存储
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateUserInfoDataWithUser_id:[userid integerValue] userinfo:dict];
    
    return YES;
}
-(G100UserDomain *)findMyUserInfoWithUserid:(NSString *)userid {
    // 2.0版本 支持多用户
    NSDictionary * dict = [CHKeychain load:kGXUserInfo];
    if (dict) {
        
    }else {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        dict = [userDefaults objectForKey:kGXUserInfo];
    }
    
    if (!dict) {
        return nil;
    }
    
    G100UserDomain * userInfo = [[CDDDataHelper cdd_sharedInstace] cdd_findUserinfoDataWithUser_id:[userid integerValue]];
    return userInfo;
}

-(BOOL)updateMapRefreshStateWithUserid:(NSString *)userid state:(NSInteger)state {
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary * tmpDic = [userdefault objectForKey:kGXMapRefreshState];
    NSMutableDictionary * dict = tmpDic.mutableCopy;
    if (!dict) {
        dict = [[NSMutableDictionary alloc]init];
    }
    [dict setObject:[NSNumber numberWithInteger:state] forKey:userid];
    [userdefault setObject:dict.copy forKey:kGXMapRefreshState];
    return YES;
}
-(NSInteger)findMapRefreshStateWithUserid:(NSString *)userid {
    NSUserDefaults * userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [userdefault objectForKey:kGXMapRefreshState];
    NSInteger state;
    if (!dict) {
        state = 0;
    }else{
        state = [[dict objectForKey:userid] integerValue];
    }
    return state;
}

#pragma mark - 2.0 车辆相关
-(BOOL)updateMyBikeListWithUserid:(NSString *)userid bikelist:(NSArray *)bikeList {
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateBikesDataWithUser_id:[userid integerValue]
                                                                     bikes:bikeList];
    return YES;
}
-(BOOL)updateMyBikeInfoWithUserid:(NSString *)userid bikeid:(NSString *)bikeid bikeInfo:(NSDictionary *)bikeInfo {
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateBikeDataWithUser_id:[userid integerValue]
                                                                  bike_id:[bikeid integerValue]
                                                                     bike:bikeInfo];
    return YES;
}
-(BOOL)updateMyDevListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devlist:(NSArray *)devList {
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateDevicesDataWithUser_id:[userid integerValue]
                                                                     bike_id:[bikeid integerValue]
                                                                     devices:devList];
    return YES;
}
-(BOOL)updateMyDevListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid devInfo:(NSDictionary *)devInfo {
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateDeviceDataWithUser_id:[userid integerValue]
                                                                    bike_id:[bikeid integerValue]
                                                                  device_id:[devid integerValue]
                                                                     device:devInfo];
    return YES;
}
-(NSArray *)findMyBikeListWithUserid:(NSString *)userid {
    return [[CDDDataHelper cdd_sharedInstace] cdd_findAllNormalBikesDataWithUser_id:[userid integerValue]];
}
-(NSArray *)findMyAllBikeListWithUserid:(NSString *)userid {
    return [[CDDDataHelper cdd_sharedInstace] cdd_findAllBikesDataWithUser_id:[userid integerValue]];
}
-(G100BikeDomain *)findMyBikeWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    G100BikeDomain *bikeDomain = [[CDDDataHelper cdd_sharedInstace] cdd_findBikeDataWithUser_id:[userid integerValue]
                                                                                        bike_id:[bikeid integerValue]];
    /** 允许查询非正常车辆的信息
    if (![bikeDomain isNormalBike]) {
        return nil;
    }
     */
    
    NSMutableArray *devices = [NSMutableArray arrayWithArray:bikeDomain.devices];
    for (NSInteger i = 0; i < [devices count]; i++) {
        G100DeviceDomain *deviceDomain = [devices safe_objectAtIndex:i];
        if (![deviceDomain isNormalDevice]) {
            [devices removeObject:deviceDomain];
        }
    }
    bikeDomain.devices = [devices copy];
    
    return bikeDomain;
}
-(BOOL)updateMyBikeTestResultWithuserid:(NSString *)userid bikeid:(NSString *)bikeid result:(NSDictionary *)result {
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateBikeTestResultWithUser_id:[userid integerValue]
                                                                        bike_id:[bikeid integerValue]
                                                                    test_result:@{@"test_result" : result}];
    return YES;
}
-(G100TestResultDomain *)findMyBikeTestResultWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    return [[CDDDataHelper cdd_sharedInstace] cdd_findBikeTestResultWithUser_id:[userid integerValue]
                                                                        bike_id:[bikeid integerValue]];
}

-(BOOL)updateMyBikeLastFindRecordWithUserid:(NSString *)userid bikeid:(NSString *)bikeid lastFindRecord:(NSDictionary *)lastFindRecord{
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateBikeLastFindRecordWithUser_id:[userid integerValue] bike_id:[bikeid integerValue]
                                                                    lastFindRecord:@{@"lastFindRecord" : lastFindRecord}];
    return YES;
}

-(NSDictionary *)findMyBikeLastFindRecordWithUserid:(NSString *)userid bikeid:(NSString *)bikeid{
    return [[CDDDataHelper cdd_sharedInstace] cdd_findBikeLastFindRecordWithUser_id:[userid integerValue] bike_id:[bikeid integerValue]];
}

- (BOOL)updateMyDevLocationDisplayWithuserid:(NSString *)userid bikeid:(NSString *)bikeid deviceid:(NSString *)deviceid locationDisplay:(BOOL)locationDisplay {
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateDeviceDataWithUser_id:[userid integerValue]
                                                                    bike_id:[bikeid integerValue]
                                                                  device_id:[deviceid integerValue]
                                                                     device:@{ @"location_display" : [NSNumber numberWithBool:locationDisplay] }];
    return YES;
}

-(NSArray *)findMyDevListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    NSArray *devicesArray = [[CDDDataHelper cdd_sharedInstace] cdd_findAllDevicesDataWithUser_id:[userid integerValue]
                                                                                        bike_id:[bikeid integerValue]];
    NSMutableArray *normalDevices = [NSMutableArray array];
    for (G100DeviceDomain *deviceDomin in devicesArray) {
        if ([deviceDomin isNormalDevice] && [deviceDomin isGPSDevice]) {
            [normalDevices addObject:deviceDomin];
        }
    }
    return normalDevices;
}
- (NSArray *)findMyBatteryListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    NSArray *devicesArray = [[CDDDataHelper cdd_sharedInstace] cdd_findAllDevicesDataWithUser_id:[userid integerValue]
                                                                                         bike_id:[bikeid integerValue]];
    NSMutableArray *devices = [NSMutableArray array];
    for (G100DeviceDomain *deviceDomin in devicesArray) {
        if ([deviceDomin isNormalDevice] && [deviceDomin isSmartBatteryDevice]) {
            [devices addObject:deviceDomin];
        }
    }
    return devices;
}
-(NSArray *)findMyAllDevListWithUserid:(NSString *)userid bikeid:(NSString *)bikeid{
    return [[CDDDataHelper cdd_sharedInstace] cdd_findAllDevicesDataWithUser_id:[userid integerValue]
                                                                        bike_id:[bikeid integerValue]];
}
-(G100DeviceDomain *)findMyDevWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid {
    return [[CDDDataHelper cdd_sharedInstace] cdd_findDeviceDataWithUser_id:[userid integerValue]
                                                                    bike_id:[bikeid integerValue]
                                                                  device_id:[devid integerValue]];
}
-(BOOL)updateMyDevPromptTimeWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid propmtTime:(NSInteger)time {
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateDeviceDataWithUser_id:[userid integerValue]
                                                                    bike_id:[bikeid integerValue]
                                                                  device_id:[devid integerValue]
                                                                     device:@{@"alarm_bell_time" : @(time)}];
    return YES;
}
-(NSInteger)findMyDevPromptTimeWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid {
    return [[CDDDataHelper cdd_sharedInstace] cdd_findDeviceDataWithUser_id:[userid integerValue]
                                                                    bike_id:[bikeid integerValue]
                                                                  device_id:[devid integerValue]].alarm_bell_time;
}
-(BOOL)updateMyBikeFeatureWithUserid:(NSString *)userid bikeid:(NSString *)bikeid feature:(NSDictionary *)feature {
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateBikeDataWithUser_id:[userid integerValue]
                                                                  bike_id:[bikeid integerValue]
                                                                     bike:@{@"feature" : feature ? : @{}}];
    return YES;
}
-(G100BikeFeatureDomain *)findMyBikeFeatureWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    return [[CDDDataHelper cdd_sharedInstace] cdd_findBikeDataWithUser_id:[userid integerValue]
                                                                  bike_id:[bikeid integerValue]].feature;
}

#pragma mark - 车辆相关
-(BOOL)updateMyCurrentDevInfoWithUserid:(NSString *)userid devInfo:(NSDictionary *)devInfo {
    if (devInfo == nil) {
        [self clearAsynchronousWithKey:kGXCurrentDevInfo];
        [self clearRelevantDataWithUserid:userid bikeid:devInfo[@"id"]];
    }else {
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:devInfo forKey:kGXCurrentDevInfo];
        [userDefaults synchronize];
    }
    return YES;
}
-(BOOL)updateMyDevInfoWithUserid:(NSString *)userid devlist:(NSArray *)devlist secset:(NSArray *)secset {
    if (!devlist.count) {
        return YES;
    }
    
    // 只保存当前用户的设备列表
    NSArray *localDevlist = [self getAsynchronousWithKey:kGXDevlist];
    if (!localDevlist.count) {
        // 如果本地没有存储设备信息 直接将得到的信息覆盖
        [self setAsynchronous:devlist withKey:kGXDevlist];
        return YES;
    }
    
    NSMutableArray *localMutableDevList = localDevlist.mutableCopy;
    NSMutableArray *toAddArray = [[NSMutableArray alloc] init];
    // 仅保留有效设备在本地   审核中等非正常状态过滤
    if (devlist.count && devlist) {
        for (NSDictionary * dict in devlist) {
            NSString *tmp = [dict objectForKey:@"status"];
            if ([tmp isEqualToString:@"1"] || [tmp isEqualToString:@"4"]) {
                // 正常设备 存储至本地
                NSString *devid = [dict objectForKey:@"id"];
                NSInteger index = [self indexForObjectWithDevid:devid devlist:localMutableDevList];
                if (index == -1) // 不存在 则add
                    [toAddArray addObject:dict];
                else
                    [localMutableDevList replaceObjectAtIndex:index withObject:dict];
            }
        }
    }
    
    [localMutableDevList addObjectsFromArray:toAddArray];
    [self setAsynchronous:localMutableDevList.copy withKey:kGXDevlist];
    
    if (!secset.count) {
        return YES;
    }
    
    // 只保存当前用户的设备列表
    NSArray *localSecset = [self getAsynchronousWithKey:kGXDevSecset];
    if (!localSecset.count) {
        // 如果本地没有存储设备信息 直接将得到的信息覆盖
        [self setAsynchronous:secset withKey:kGXDevSecset];
        return YES;
    }
    
    NSMutableArray *localMutableSecset = localSecset.mutableCopy;
    NSMutableArray *toAddArray2 = [[NSMutableArray alloc] init];
    // 仅保留有效设备在本地
    if (secset.count && secset) {
        for (NSDictionary * dict in secset) {
            // 正常设备 存储至本地
            NSString *devid = [dict objectForKey:@"devid"];
            NSInteger index = [self indexForObjectWithDevid:devid devlist:localMutableSecset];
            if (index == -1) // 不存在 则add
                [toAddArray2 addObject:dict];
            else
                [localMutableSecset replaceObjectAtIndex:index withObject:dict];
        }
    }
    
    [localMutableSecset addObjectsFromArray:toAddArray2];
    [self setAsynchronous:localMutableSecset.copy withKey:kGXDevSecset];
    
    return YES;
}
-(NSInteger)indexForObjectWithDevid:(NSString *)devid devlist:(NSArray *)devlist {
    for (NSInteger i = 0; i < [devlist count]; i++) {
        NSDictionary * obj = devlist[i];
        if ([[obj objectForKey:@"id"] isEqualToString:devid] ||
            [[obj objectForKey:@"devid"] isEqualToString:devid]) {
            return i;
        }
    }
    
    return -1;
}
-(BOOL)updateMyDevListWithUserid:(NSString *)userid devlist:(NSArray *)devlist {
    
    return YES;
}
-(NSArray *)findMyDevlistWithUserid:(NSString *)userid {
    // 现阶段只保存一个用户车辆列表
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray * devlist = [userDefaults objectForKey:kGXDevlist];
    
    if (!devlist) {
        return nil;
    }
    
    return devlist;
}
-(G100TestResultDomain *)findMyDevTestResultWithUserid:(NSString *)userid devid:(NSString *)devid {
    G100TestResultDomain * result = nil;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [userDefaults objectForKey:kGXDevTestResult];
    
    NSArray * users = [dict allKeys];
    if ([users containsObject:userid]) {
        NSDictionary * udict = [dict objectForKey:userid];
        result = [[G100TestResultDomain alloc]initWithDictionary:[udict objectForKey:devid]];
    }
    
    return result;
}

-(BOOL)updateMyDevPromptTimeWithUserid:(NSString *)userid devid:(NSString *)devid propmtTime:(NSInteger)time {
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary * tmpDict = [userDefault objectForKey:kGXDevPromptTime];
    NSMutableDictionary * allTimeDict = tmpDict.mutableCopy;
    NSMutableDictionary * devTimeDict = ((NSDictionary *)[allTimeDict objectForKey:userid]).mutableCopy;
    if (!devTimeDict) {
        devTimeDict = [[NSMutableDictionary alloc] init];
    }
    
    [devTimeDict setObject:[NSNumber numberWithInteger:time] forKey:devid];
    
    if (!allTimeDict) {
        allTimeDict = [[NSMutableDictionary alloc] init];
    }
    
    [allTimeDict setObject:devTimeDict forKey:userid];
    
    [userDefault setObject:allTimeDict.copy forKey:kGXDevPromptTime];
    [userDefault synchronize];
    
    return YES;
}
-(NSInteger)findMyDevPromptTimeWithUserid:(NSString *)userid devid:(NSString *)devid {
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary * allTimeDict = [userDefault objectForKey:kGXDevPromptTime];
    
    NSInteger a = 0;
    
    if (!allTimeDict) {
        
    }else {
        if (!userid) {
            return 0;
        }
        NSMutableDictionary * devTimeDict = ((NSDictionary *)[allTimeDict objectForKey:userid]).mutableCopy;
        
        if (devTimeDict) {
            if (!devid) {
                return 0;
            }
            id result = [devTimeDict objectForKey:devid];
            if ([result isKindOfClass:[NSNumber class]]) {
                a = [result integerValue];
            }
        }
        
    }
    return a;
}

#pragma mark - 活动相关
-(BOOL)updateCurrentEventWithUserid:(NSString *)userid detailEventDomain:(G100EventDetailDomain *)domain {
    
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    if (!domain) {
        NSDictionary * tmpDict = [userDefault objectForKey:kGXCurrentEvent];
        NSMutableDictionary * allUserDict = tmpDict.mutableCopy;
        NSMutableDictionary * eventDict = ((NSDictionary *)[allUserDict objectForKey:userid]).mutableCopy;
        if (eventDict) {
            [allUserDict removeObjectForKey:userid];
            [userDefault setObject:allUserDict.copy forKey:kGXCurrentEvent];
            [userDefault synchronize];
        }
        
        return YES;
    }
    
    NSDictionary * tmpDict = [userDefault objectForKey:kGXCurrentEvent];
    NSMutableDictionary * allUserDict = tmpDict.mutableCopy;
    NSMutableDictionary * eventDict = ((NSDictionary *)[allUserDict objectForKey:userid]).mutableCopy;
    if (!eventDict) {
        eventDict = [[NSMutableDictionary alloc]init];
    }
    [eventDict setObject:[domain mj_keyValues] forKey:[NSString stringWithFormat:@"%@", @(domain.eventid)]];
    if (!allUserDict) {
        allUserDict = [[NSMutableDictionary alloc]init];
    }
    [allUserDict setObject:eventDict forKey:userid];
    
    [userDefault setObject:allUserDict.copy forKey:kGXCurrentEvent];
    [userDefault synchronize];
    
    return YES;
}

-(G100EventDetailDomain*)getCurrentEventWithUserId:(NSString *)userid eventId:(NSInteger)eventId {
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary * allUserDict = [userDefault objectForKey:kGXCurrentEvent];
    NSDictionary * eventDict = [allUserDict objectForKey:userid];
    G100EventDetailDomain * detailDomain = nil;
    if (!eventDict) {
        return nil;
    }else{
        id tmp = [eventDict objectForKey:[NSString stringWithFormat:@"%@", @(eventId)]];
        
        if ([tmp isKindOfClass:[NSDictionary class]]) {
            G100EventDetailDomain * tmpDomain = [[G100EventDetailDomain alloc] initWithDictionary:tmp];
            if (tmpDomain) {
                detailDomain = tmpDomain;
            }else{
                return nil;
            }
        }
    }
    return detailDomain;
}

-(BOOL)updateCurrentEventWithUserid:(NSString *)userid bikeid:(NSString *)bikeid detailEventDomain:(G100EventDetailDomain *)domain {
    if (!bikeid) {
        return NO;
    }
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    if (!domain) {
        NSDictionary * tmpDict = [userDefault objectForKey:kGXCurrentBikeEvent];
        NSMutableDictionary * rootDict = tmpDict.mutableCopy;
        NSMutableDictionary * secondDict = ((NSDictionary *)[rootDict objectForKey:userid]).mutableCopy;
        NSMutableDictionary * thirdDict = ((NSDictionary *)[secondDict objectForKey:bikeid]).mutableCopy;
        if (thirdDict) {
            [secondDict removeObjectForKey:bikeid];
            [rootDict setObject:secondDict forKey:userid];
            [userDefault setObject:rootDict.copy forKey:kGXCurrentBikeEvent];
            [userDefault synchronize];
        }
        
        return YES;
    }
    
    NSDictionary * tmpDict = [userDefault objectForKey:kGXCurrentBikeEvent];
    NSMutableDictionary * rootDict = tmpDict.mutableCopy;
    NSMutableDictionary * secondDict = ((NSDictionary *)[rootDict objectForKey:userid]).mutableCopy;
    if (!secondDict) {
        secondDict = [[NSMutableDictionary alloc]init];
    }
    NSMutableDictionary * thirdDict = ((NSDictionary *)[secondDict objectForKey:bikeid]).mutableCopy;
    if (!thirdDict) {
        thirdDict = [[NSMutableDictionary alloc]init];
    }
    [thirdDict setObject:[domain mj_keyValues] forKey:[NSString stringWithFormat:@"%@", @(domain.eventid)]];
    [secondDict setObject:thirdDict forKey:bikeid];
    if (!rootDict) {
        rootDict = [[NSMutableDictionary alloc]init];
    }
    [rootDict setObject:secondDict forKey:userid];
    
    [userDefault setObject:rootDict.copy forKey:kGXCurrentBikeEvent];
    [userDefault synchronize];
    
    return YES;
}

-(G100EventDetailDomain*)getCurrentEventWithUserId:(NSString *)userid bikeid:(NSString *)bikeid eventId:(NSInteger)eventId {
    if (!bikeid) {
        return nil;
    }
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary * rootDict = [userDefault objectForKey:kGXCurrentBikeEvent];
    NSDictionary * secondDict = [rootDict objectForKey:userid];
    G100EventDetailDomain * detailDomain = nil;
    if (!secondDict) {
        return nil;
    }else{
        NSDictionary *thirdDict = [secondDict objectForKey:bikeid];
        if (!thirdDict) {
            return nil;
        }else {
            id tmp = [thirdDict objectForKey:[NSString stringWithFormat:@"%@", @(eventId)]];
            if ([tmp isKindOfClass:[NSDictionary class]]) {
                G100EventDetailDomain * tmpDomain = [[G100EventDetailDomain alloc] initWithDictionary:tmp];
                if (tmpDomain) {
                    detailDomain = tmpDomain;
                }else{
                    return nil;
                }
            }
        }
    }
    return detailDomain;
}

#pragma mark - 消息中心提醒
- (BOOL)updateCurrentUserNewMsgCountWithUserId:(NSString *)userId hasRead:(NSInteger)hasRead needNotification:(BOOL)need {
    if (!userId) {
        return NO;
    }
    
    if ([userId integerValue] == 0) {
        userId = self.buserid;
    }
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * tmpDict = [userDefaults objectForKey:kGXNewOfflineMsg];
    NSMutableDictionary * dict = tmpDict.mutableCopy;
    if (!dict) {
        dict = [[NSMutableDictionary alloc]init];
    }
    
    NSInteger msgCount = [self getCurrentUserNewMsgCountWithUserId:userId];
    
    if (hasRead == OfflineMsgReadStatusAll) {
        // 全读 清零
        msgCount = 0;
    }else{
        msgCount += hasRead;
    }
    
    [dict setObject:[NSNumber numberWithInteger:msgCount] forKey:userId];
    
    [userDefaults setObject:dict.copy forKey:kGXNewOfflineMsg];
    [userDefaults synchronize];
    
    if (need) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGNShowNewMsgSignal object:nil];
    }
    return YES;
}

- (BOOL)updateCurrentUserNewMsgCountWithUserId:(NSString *)userId hasRead:(NSInteger)hasRead {
    return [self updateCurrentUserNewMsgCountWithUserId:userId hasRead:hasRead needNotification:YES];
}

- (NSInteger)getCurrentUserNewMsgCountWithUserId:(NSString *)userId {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [userDefaults objectForKey:kGXNewOfflineMsg];
    NSInteger msgCount = 0;
    if (!dict) {
        
    }else{
        msgCount = [[dict objectForKey:userId] integerValue];
    }
    return msgCount;
}

#pragma mark - 登陆后保存数据
-(BOOL)loginWithUsername:(NSString *)username password:(NSString *)password userInfo:(NSDictionary *)loginInfo {
    if (username) {
        self.username = username;
    }
    if (password) {
        self.password = password;
    }
    
    G100AccountDomain * accountInfo = [[G100AccountDomain alloc]initWithDictionary:loginInfo];
    self.token = accountInfo.token;
    self.buserid = [NSString stringWithFormat:@"%ld", (long)accountInfo.userid];
    
    [self updateMyAccountInfoWithUserid:self.buserid accountInfo:loginInfo];
    [self updateMyUserInfoWithUserid:self.buserid userInfo:loginInfo[@"user_info"]];
    
    [[CDDDataHelper cdd_sharedInstace] cdd_addOrUpdateAccountDataWithUser_id:[loginInfo[@"user_info"][@"user_id"] integerValue]
                                                                     account:loginInfo];
    
    return YES;
}

-(BOOL)clearRelevantDataWithUserid:(NSString *)userid {
    [self clearRelevantDataWithUserid:userid bikeid:nil];
    return YES;
}

#pragma mark - 删除某个车辆数据
-(BOOL)clearRelevantDataWithUserid:(NSString *)userid bikeid:(NSString *)bikeid {
    // 清空设备的检测结果
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary * allTestResult = ((NSDictionary *)[userDefaults objectForKey:kGXDevTestResult]).mutableCopy;
    
    if (allTestResult) {
        NSMutableDictionary * devTestResult = ((NSDictionary *)[allTestResult objectForKey:userid]).mutableCopy;
        if (devTestResult) {
            if (bikeid) {
                [devTestResult removeObjectForKey:bikeid];
            }else {
                [devTestResult removeAllObjects];
            }
            [allTestResult setObject:devTestResult.copy forKey:userid];
            [userDefaults setObject:allTestResult.copy forKey:kGXDevTestResult];
        }
    }
    
    // 清空时间设置结果
    NSMutableDictionary * allTimeResult = ((NSDictionary *)[userDefaults objectForKey:kGXDevPromptTime]).mutableCopy;
    
    if (allTimeResult) {
        NSMutableDictionary * devTimeResult = ((NSDictionary *)[allTestResult objectForKey:userid]).mutableCopy;
        
        if (devTimeResult) {
            if (bikeid) {
                [devTimeResult removeObjectForKey:bikeid];
            }else {
                [devTimeResult removeAllObjects];
            }
            [allTimeResult setObject:devTimeResult.copy forKey:userid];
            [userDefaults setObject:allTimeResult.copy forKey:kGXDevPromptTime];
        }
    }
    
    // 清空车辆的特征信息
    NSMutableDictionary * allFeatureResult = ((NSDictionary *)[userDefaults objectForKey:kGXDevFeature]).mutableCopy;
    
    if (allFeatureResult) {
        NSMutableDictionary * devFeatureResult = ((NSDictionary *)[allFeatureResult objectForKey:userid]).mutableCopy;
        
        if (devFeatureResult) {
            if (bikeid) {
                [devFeatureResult removeObjectForKey:bikeid];
            }else {
                [devFeatureResult removeAllObjects];
            }
            [allFeatureResult setObject:devFeatureResult.copy forKey:userid];
            [userDefaults setObject:allFeatureResult.copy forKey:kGXDevFeature];
        }
    }
    
    [userDefaults synchronize];
    
    // 清空本地提醒计数
    [self clearRemainderTimesWithKey:@"kBatteryInfoNoticeNum" leftTimes:0 userid:userid devid:bikeid];
    // 清空绑定设备成功的消息
    [self clearRelevantDataWithUserid:userid bikeid:bikeid devid:nil];
    
    return YES;
}

- (BOOL)clearRelevantDataWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid {
    // 清空绑定设备成功的消息
    [self updateNewDevBindSuccessWithUserid:userid bikeid:bikeid devid:devid params:nil];
    return YES;
}

-(BOOL)clearAllData {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray * keysArr = @[
                          kGXFirstLogin,
                          kGXPassword,
                          kGXToken,
                          kGXUserLoginType,
                          kGXThirdLoginUserid,
                          kGXThirdPartnerUseruid,
                          kGXBUserid,
                          kGXAccountInfo,
                          kGXUserInfo,
                          kGXDevlist,
                          kGXScoreChanged,
                          kGXDevSecset
                          ];
    
    for (NSString * obj in keysArr) {
        if ([userDefaults objectForKey:obj]) {
            [userDefaults removeObjectForKey:obj];
        }
        
        [CHKeychain deleteData:obj];
    }
    
    // 清空内存中存储的值
    self.qwsAccountInfo = nil;
    self.qwsPassword = nil;
    self.qwstoken = nil;
    self.qwsUserId = nil;
    self.qwsUserInfo = nil;
    self.qwsUsername = nil;
    self.qwsBChannelid = nil;
    
    return YES;
}

#pragma mark - 数据简单存取
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

#pragma mark - 各种提醒的计数
- (BOOL)updateRemainderTimesWithKey:(NSString *)remainderKey leftTimes:(NSInteger)times {
    NSMutableDictionary *leftEventDict = ((NSDictionary *)[self getAsynchronousWithKey:@"leftremaindertimes"]).mutableCopy;
    
    if (!leftEventDict) {
        return NO;
    }
    
    [leftEventDict setObject:@(times) forKey:remainderKey];
    [self setAsynchronous:leftEventDict.copy withKey:@"leftremaindertimes"];
    
    return YES;
}
- (BOOL)clearRemainderTimesWithKey:(NSString *)remainderKey leftTimes:(NSInteger)times {
    NSMutableDictionary *leftEventDict = ((NSDictionary *)[self getAsynchronousWithKey:@"leftremaindertimes"]).mutableCopy;
    
    if (!leftEventDict) {
        return NO;
    }
    
    [leftEventDict removeObjectForKey:remainderKey];
    [self setAsynchronous:leftEventDict.copy withKey:@"leftremaindertimes"];
    
    return YES;
}
- (NSInteger)leftRemainderTimesWithKey:(NSString *)remainderKey {
    NSMutableDictionary *leftEventDict = ((NSDictionary *)[self getAsynchronousWithKey:@"leftremaindertimes"]).mutableCopy;
    
    if (!leftEventDict) { // 如果没有设置 则默认为1次
        leftEventDict = [[NSMutableDictionary alloc] init];
        [leftEventDict setObject:[NSNumber numberWithInteger:1] forKey:remainderKey];
        [self setAsynchronous:leftEventDict.copy withKey:@"leftremaindertimes"];
        return 1;
    }
    
    if (![[leftEventDict allKeys] containsObject:remainderKey]) {
        [leftEventDict setObject:[NSNumber numberWithInteger:1] forKey:remainderKey];
        [self setAsynchronous:leftEventDict.copy withKey:@"leftremaindertimes"];
        return 1;
    }
    
    NSInteger time = [leftEventDict[remainderKey] integerValue];
    return time;
}
- (BOOL)setLeftRemainderTimesWithKey:(NSString *)remainderKey times:(NSInteger)times dependOnVersion:(BOOL)dependOnVersion {
    NSMutableDictionary *leftEventDict = ((NSDictionary *)[self getAsynchronousWithKey:@"leftremaindertimes"]).mutableCopy;
    if (!leftEventDict) leftEventDict = [[NSMutableDictionary alloc] init];
    
    if ([[leftEventDict allKeys] containsObject:remainderKey]) {
        // 已经设置过次数 则不能再设置
        return NO;
    }
    
    [leftEventDict setObject:@(times) forKey:remainderKey];
    [self setAsynchronous:leftEventDict.copy withKey:@"leftremaindertimes"];
    
    return YES;
}
- (BOOL)clearRemainderTimesWithKey:(NSString *)remainderKey leftTimes:(NSInteger)times userid:(NSString *)userid devid:(NSString *)devid {
    NSMutableString *tmpString = remainderKey.mutableCopy;
    if (userid) [tmpString appendString:userid];
    if (devid) [tmpString appendString:devid];
    return [self clearRemainderTimesWithKey:tmpString leftTimes:times];
}
- (BOOL)updateRemainderTimesWithKey:(NSString *)remainderKey leftTimes:(NSInteger)times userid:(NSString *)userid devid:(NSString *)devid {
    NSMutableString *tmpString = remainderKey.mutableCopy;
    if (userid) [tmpString appendString:userid];
    if (devid) [tmpString appendString:devid];
    return [self updateRemainderTimesWithKey:tmpString leftTimes:times];
}
- (NSInteger)leftRemainderTimesWithKey:(NSString *)remainderKey userid:(NSString *)userid devid:(NSString *)devid {
    NSMutableString *tmpString = remainderKey.mutableCopy;
    if (userid) [tmpString appendString:userid];
    if (devid) [tmpString appendString:devid];
    return [self leftRemainderTimesWithKey:tmpString];
}
- (BOOL)setLeftRemainderTimesWithKey:(NSString *)remainderKey times:(NSInteger)times userid:(NSString *)userid devid:(NSString *)devid dependOnVersion:(BOOL)dependOnVersion {
    NSMutableString *tmpString = remainderKey.mutableCopy;
    if (userid) [tmpString appendString:userid];
    if (devid) [tmpString appendString:devid];
    return [self setLeftRemainderTimesWithKey:tmpString times:times dependOnVersion:dependOnVersion];
}

#pragma mark - 车辆绑定成功消息
- (BOOL)updateNewDevBindSuccessWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid params:(NSDictionary *)params {
    if (!userid || !userid.length) {
        return NO;
    }
    if (!bikeid || !bikeid.length) {
        return NO;
    }
    
    NSMutableDictionary *mFirst  = [NSMutableDictionary new];
    NSMutableDictionary *mSecond = [NSMutableDictionary new];
    NSMutableDictionary *mThird  = [NSMutableDictionary new];
    
    NSDictionary *first = [self getAsynchronousWithKey:@"new_dev_bind_success_info2"];
    if (first) {
        mFirst = first.mutableCopy;
        if ([[first allKeys] containsObject:userid]) {
            NSDictionary *second = first[userid];
            if (second) {
                mSecond = second.mutableCopy;
                if ([[second allKeys] containsObject:bikeid]) {
                    NSDictionary *third = second[bikeid];
                    if (third) {
                        mThird = third.mutableCopy;
                    }
                }
            }
        }
    }
    
    if (!devid || devid.length) {
        [mSecond removeObjectForKey:bikeid];
        [mFirst setObject:mSecond.copy forKey:userid];
    }else {
        if (!params) {
            [mThird removeObjectForKey:devid];
        }else {
            [mThird setObject:params forKey:devid];
        }
        
        [mSecond setObject:mThird.copy forKey:bikeid];
        [mFirst setObject:mSecond.copy forKey:userid];
    }
    
    [self setAsynchronous:mFirst.copy withKey:@"new_dev_bind_success_info2"];
    
    return YES;
}
- (NSArray *)findThereisNewDevBindSuccessWithUserid:(NSString *)userid {
    if (!userid || !userid.length) {
        return nil;
    }
    
    if ([userid isKindOfClass:[NSNumber class]]) {
        userid = [NSString stringWithFormat:@"%@", (NSNumber *)userid];
    }
    
    NSDictionary *first = [self getAsynchronousWithKey:@"new_dev_bind_success_info2"];
    if ([[first allKeys] containsObject:userid]) {
        NSDictionary *second = first[userid];
        for (NSString *bikeid in second) {
            NSDictionary *devid_dict = [second objectForKey:bikeid];
            if ([devid_dict isKindOfClass:[NSDictionary class]]) {
                if ([[devid_dict allKeys] count]) {
                    NSString *devid = [[devid_dict allKeys] safe_objectAtIndex:0];
                    id result = [devid_dict objectForKey:devid];
                    
                    if (result) {
                        // 清空车辆绑定成功信息
                        [self updateNewDevBindSuccessWithUserid:userid bikeid:bikeid devid:devid params:nil];
                        return @[userid, bikeid, devid];
                    }
                }
            }
        }
    }
    
    return nil;
}

#pragma mark - 用户测试三方报警时的本地参数存储
- (BOOL)updatePushTestResultWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid params:(NSDictionary *)params {
    if (!userid || !userid.length) {
        return NO;
    }
    if (!bikeid || !bikeid.length) {
        return NO;
    }
    if (!devid || !devid.length) {
        return NO;
    }
    
    NSMutableDictionary *mFirst  = [NSMutableDictionary new];
    NSMutableDictionary *mSecond = [NSMutableDictionary new];
    NSMutableDictionary *mThird  = [NSMutableDictionary new];
    
    NSDictionary *first = [self getAsynchronousWithKey:@"push-test-result-info"];
    if (first) {
        mFirst = first.mutableCopy;
        if ([[first allKeys] containsObject:userid]) {
            NSDictionary *second = first[userid];
            if (second) {
                mSecond = second.mutableCopy;
                if ([[second allKeys] containsObject:bikeid]) {
                    NSDictionary *third = second[bikeid];
                    if (third) {
                        mThird = third.mutableCopy;
                    }
                }
            }
        }
    }
    
    if (!params) {
        [mThird removeObjectForKey:devid];
    }else {
        [mThird setObject:params forKey:devid];
    }
    
    [mSecond setObject:mThird.copy forKey:bikeid];
    [mFirst setObject:mSecond.copy forKey:userid];
    
    [self setAsynchronous:mFirst.copy withKey:@"push-test-result-info"];
    
    return YES;
}
- (NSDictionary *)findThereisPushTestResultWithUserid:(NSString *)userid {
    if (!userid) {
        return nil;
    }
    
    if ([userid isKindOfClass:[NSNumber class]]) {
        userid = [NSString stringWithFormat:@"%@", (NSNumber *)userid];
    }
    
    NSDictionary *first = [self getAsynchronousWithKey:@"push-test-result-info"];
    if ([[first allKeys] containsObject:userid]) {
        NSDictionary *second = first[userid];
        for (NSString *bikeid in second) {
            NSDictionary *devid_dict = [second objectForKey:bikeid];
            if ([devid_dict isKindOfClass:[NSDictionary class]]) {
                if ([[devid_dict allKeys] count]) {
                    id result = [devid_dict objectForKey:[[devid_dict allKeys] safe_objectAtIndex:0]];
                    if ([result isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *pushTestParams = (NSDictionary *)result;
                        return pushTestParams;
                    }else {
                        [self clearAsynchronousWithKey:@"push-test-result-info"];
                    }
                }
            }
        }
    }
    
    return nil;
}

#pragma mark - 记录用户手机收取最后一条推送的时间
- (BOOL)updateLastestNotificationTime:(NSDate *)lastest_time {
    [self setAsynchronous:lastest_time withKey:@"noti_overtime_warning"];
    return YES;
}

- (NSDate *)findLastestNotificationTime {
    NSDate *lastest_date = [self getAsynchronousWithKey:@"noti_overtime_warning"];
    if (lastest_date) {
        return lastest_date;
    }
    return nil;
}

- (void)setUpgradeID:(NSNumber *)upgradeID devid:(NSString *)devid;{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:upgradeID forKey:[NSString stringWithFormat:@"%@%@",kGXUpgradeID,devid]];
    [userDefaults synchronize];
}
- (NSNumber *)getUpgradeIDWithDevid:(NSString *)devid{
    NSNumber *upgradeID = 0;
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    upgradeID = [userDefaults objectForKey:[NSString stringWithFormat:@"%@%@",kGXUpgradeID,devid]];
    return upgradeID;
}

- (void)updatePrivacyWithUserid:(NSString *)userid version:(NSString *)version{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:version forKey:userid];
    [userDefaults synchronize];
}

- (NSString *)getPrivacyVersionWithUserid:(NSString *)userid{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [userDefaults objectForKey:userid];
    return version;
}

@end

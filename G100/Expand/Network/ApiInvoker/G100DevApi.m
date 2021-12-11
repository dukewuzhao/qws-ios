//
//  G100DevApi.m
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100DevApi.h"

@implementation G100DevApi

+(instancetype)sharedInstance {
    static G100DevApi * instance;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(ApiRequest *)loadCurrentUserDevlistWithCallback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:nil];
    return [G100ApiHelper postApi:@"app/getdevlist" andRequest:request callback:callback];
}

-(ApiRequest *)loadCurrentUserDevlistWithDevid:(NSArray *)devid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid)}];
    return [G100ApiHelper postApi:@"app/getdevlist" andRequest:request callback:callback];
}

-(ApiRequest *)getDevCurrentPositionWithDevid:(NSString *)devid tracemode:(NSInteger)tracemode callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid),
                                                            @"tracemode" : [NSNumber numberWithInteger:tracemode]}];
    return [G100ApiHelper postApi:@"app/currentlocation" andRequest:request callback:callback];
}

-(ApiRequest *)getDevDriveSummaryWithDevid:(NSString *)devid
                               day:(NSString *)day
                          callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"day" : EMPTY_IF_NIL(day)
                                                            }];
    return [G100ApiHelper postApi:@"app/histracksummary" andRequest:request callback:callback];
}

-(ApiRequest *)loadDevDayDriveSummaryWithDevid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid)}];
    return [G100ApiHelper postApi:@"app/bikeusagesummarydaily" andRequest:request callback:callback];
}

-(ApiRequest *)loadDevHistoryTrackWithDevid:(NSString *)devid
                         begintime:(NSString *)begintime
                           endtime:(NSString *)endtime
                          callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"begintime" : EMPTY_IF_NIL(begintime),
                                                            @"endtime" : EMPTY_IF_NIL(endtime)
                                                            }];
    return [G100ApiHelper postApi:@"app/historytrack" andRequest:request callback:callback];
}

-(ApiRequest *)getDevCurrentPowerWithDevid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid)}];
    return [G100ApiHelper postApi:@"app/currentbattery" andRequest:request callback:callback];
}

-(ApiRequest *)bindNewDevWithQRCode:(NSString *)qr callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"qr" : EMPTY_IF_NIL(qr)}];
    return [G100ApiHelper postApi:@"app/bindeb" andRequest:request callback:callback];
}

-(ApiRequest *)bindNewDevWithQRCode:(NSString *)qr alertor:(NSInteger)alertor callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{ @"qr" : EMPTY_IF_NIL(qr), @"alertor" : [NSNumber numberWithInteger:alertor] }];
    return [G100ApiHelper postApi:@"app/bindeb" andRequest:request callback:callback];
}

-(ApiRequest *)rebindDevWithDevid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid)}];
    return [G100ApiHelper postApi:@"app/rebindeb" andRequest:request callback:callback];
}

-(ApiRequest *)checkBindWithBikeid:(NSString *)bikeid Devid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:bikeid.integerValue],
                                                            @"device_id" : [NSNumber numberWithInteger:devid.integerValue]
                                                            }];
    return [G100ApiHelper postApi:@"bike/checkbind" andRequest:request callback:callback];
}

-(ApiRequest *)loadRelativeUserinfoWithDevid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid)}];
    return [G100ApiHelper postApi:@"app/getdevusers" andRequest:request callback:callback];
}

-(ApiRequest *)modifyDevNameWithDevid:(NSString *)devid
                         name:(NSString *)name
                     callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"name" : EMPTY_IF_NIL(name)
                                                            }];
    return [G100ApiHelper postApi:@"app/updatebikename" andRequest:request callback:callback];
}

-(ApiRequest *)removeDevUserWithDevid:(NSString *)devid
                       userid:(NSString *)userid
                     callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"userid" : EMPTY_IF_NIL(userid)
                                                            }];
    return [G100ApiHelper postApi:@"bike/deletebikeuser" andRequest:request callback:callback];
}

-(ApiRequest *)removeDevUserSelfWithDevid:(NSString *)devid
                            vcode:(NSString *)vcode
                         callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"vc" : EMPTY_IF_NIL(vcode)
                                                            }];
    return [G100ApiHelper postApi:@"app/unbindeb" andRequest:request callback:callback];
}

-(ApiRequest *)deleteDevWithBikeid:(NSString *)bikeid
                  deviceid:(NSString *)deviceid
                  callback:(API_CALLBACK)callback
{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:bikeid.integerValue],
                                                            @"device_id" : [NSNumber numberWithInteger:deviceid.integerValue]
                                                            }];
    return [G100ApiHelper postApi:@"bike/deletedevice" andRequest:request callback:callback];

}

-(ApiRequest *)setSecuritySetingWithData:(NSDictionary *)data callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"data" : EMPTY_IF_NIL(data)}];
    return [G100ApiHelper postApi:@"app/securitysetting" andRequest:request callback:callback];
}

-(ApiRequest *)loadListDevMsgWithDevid:(NSString *)devid
                     begintime:(NSString *)begintime
                       endtime:(NSString *)endtime
                      callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"begintime" : EMPTY_IF_NIL(begintime),
                                                            @"endtime" : EMPTY_IF_NIL(endtime)
                                                            }];
    // 请求缓慢 设置超时时间为60s
    return [G100ApiHelper postApi:@"app/listdevmsg" andRequest:request token:YES https:YES timeoutInSeconds:60 callback:callback];
}

-(ApiRequest *)grantDevPrivsWithBikeid:(NSString *)bikeid
                         Devid:(NSString *)devid
                        userid:(NSString *)userid
                         grant:(NSString *)grant
                         privs:(NSString *)privs
                         msgid:(NSInteger)msgid
                      callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                            @"device_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(devid).integerValue],
                                                            @"user_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(userid).integerValue],
                                                            @"grant" : EMPTY_IF_NIL(grant),
                                                            @"privs" : EMPTY_IF_NIL(privs),
                                                            @"msgid" : [NSNumber numberWithInteger:msgid]
                                                            }];
    return [G100ApiHelper postApi:@"bike/grantdevprivs" andRequest:request callback:callback];
}

-(ApiRequest *)controllerLockWithDevid:(NSString *)devid
                          lock:(NSInteger)lock
                      callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"lock" : EMPTY_IF_NIL([NSNumber numberWithInteger:lock])
                                                            }];
    return [G100ApiHelper postApi:@"app/controllerlock" andRequest:request callback:callback];
}

-(ApiRequest *)getDevStatusWithDevid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid)}];
    return [G100ApiHelper postApi:@"app/getbikestatus" andRequest:request callback:callback];
}

-(ApiRequest *)evaluatingDevSafetyScoreWithDevid:(NSString *)devid
                         securitysetting:(NSInteger)securitysetting
                                callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"securitysetting" : EMPTY_IF_NIL([NSNumber numberWithInteger:securitysetting])
                                                            }];
    return [G100ApiHelper postApi:@"app/getsecurityscore" andRequest:request callback:callback];
}

-(ApiRequest *)setDevSecuritySettingsWithDevid:(NSString *)devid
                                  mode:(NSInteger)mode
                                detail:(NSDictionary *)detail
                             bluetooth:(NSInteger)bluetooth
                              callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"mode" : EMPTY_IF_NIL([NSNumber numberWithInteger:mode]),
                                                            @"detail" : EMPTY_IF_NIL(detail),
                                                            @"bluetooth" : EMPTY_IF_NIL([NSNumber numberWithInteger:bluetooth])
                                                            }];
    return [G100ApiHelper postApi:@"app/securitysetting" andRequest:request callback:callback];
}

-(ApiRequest *)ignoreOrFindDevWhenWarnComeWithBikeid:(NSString *)bikeid devid:(NSString *)devid
                                       type:(NSString *)type
                                   callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                            @"device_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(devid).integerValue],
                                                            @"type"  : EMPTY_IF_NIL(type)
                                                            }];
    return [G100ApiHelper postApi:@"bike/ignoreorfind" andRequest:request callback:callback];
}

-(ApiRequest *)checkDevtypeWithQr:(NSString *)qr callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"qr" : EMPTY_IF_NIL(qr)}];
    return [G100ApiHelper postApi:@"app/checkdevtype" andRequest:request callback:callback];
}

-(ApiRequest *)setAlertSwitchWithDevid:(NSString *)devid alertor:(NSInteger)alertor callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"devid" : EMPTY_IF_NIL(devid),
                                                           @"alertor" : [NSNumber numberWithInteger:alertor]
                                                           }];
    return [G100ApiHelper postApi:@"app/alertorswitch" andRequest:request callback:callback];
}

- (ApiRequest *)sendOperateAlertorWithBikeid:(NSString *)bikeid devid:(NSString *)devid
                            command:(NSInteger)command
                      commandParams:(NSDictionary *)commandParams
                           callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"device_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(devid).integerValue],
                                                           @"command" : [NSNumber numberWithInteger:command],
                                                           @"commandparams" : EMPTY_IF_NIL(commandParams)
                                                           }];
    return [G100ApiHelper postApi:@"bike/operatealertor" andRequest:request callback:callback];
}

- (ApiRequest *)setSamePushIgnoreWithDevid:(NSString *)devid ignoretime:(NSInteger)ignoretime callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"devid" : EMPTY_IF_NIL(devid),
                                                           @"ignoretime" : [NSNumber numberWithInteger:ignoretime]
                                                           }];
    return [G100ApiHelper postApi:@"app/setsamepushignore" andRequest:request callback:callback];
}

- (ApiRequest *)ignoreSamePushWithDevid:(NSString *)devid pushtype:(NSString *)pushtype callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"devid" : EMPTY_IF_NIL(devid),
                                                           @"pushtype" : EMPTY_IF_NIL(pushtype)
                                                           }];
    return [G100ApiHelper postApi:@"app/ignoresamepush" andRequest:request callback:callback];
}

- (ApiRequest *)setAccNotify:(NSString *)devid notify:(NSInteger)notify callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"devid" : EMPTY_IF_NIL(devid),
                                                           @"notify" : [NSNumber numberWithInteger:notify]
                                                           }];
    return [G100ApiHelper postApi:@"app/setaccnotify" andRequest:request callback:callback];
}

- (ApiRequest *)rebootLocatorWithDevid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid)}];
    return [G100ApiHelper postApi:@"app/rebootlocator" andRequest:request callback:callback];
}

- (ApiRequest *)rebootLocatorWithBikeid:(NSString *)bikeid devid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:[EMPTY_IF_NIL(bikeid) integerValue]],
                                                           @"device_id" : [NSNumber numberWithInteger:[EMPTY_IF_NIL(devid) integerValue]]}];
    return [G100ApiHelper postApi:@"bike/rebootlocator" andRequest:request callback:callback];
}

- (ApiRequest *)checkLocatorRebootWithDevid:(NSString *)devid minute:(NSInteger)minute callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"devid" : EMPTY_IF_NIL(devid),
                                                           @"minute" : [NSNumber numberWithInteger:minute]
                                                           }];
    return [G100ApiHelper postApi:@"app/checklocatorreboot" andRequest:request callback:callback];
}

- (ApiRequest *)checkLocatorRebootWithBikeid:(NSString *)bikeid devid:(NSString *)devid minute:(NSInteger)minute callback:(API_CALLBACK)callback
{
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"device_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(devid).integerValue],
                                                           @"minute" : [NSNumber numberWithInteger:minute]
                                                           }];
    return [G100ApiHelper postApi:@"bike/checklocatorreboot" andRequest:request callback:callback];
}
- (ApiRequest *)getBikeFeatureWithDevid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid)}];
    return [G100ApiHelper postApi:@"app/getbikefeature" andRequest:request callback:callback];
}

- (ApiRequest *)getBikeFeatureWithBikeid:(NSString *)bikeid callback:(API_CALLBACK)callback
{
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue]}];
    return [G100ApiHelper postApi:@"bike/getbikefeature" andRequest:request callback:callback];
}
- (ApiRequest *)updateBikeProfileWithDev:(NSString *)devid
                      updateType:(G100DevProfileUpdateType)updateType
                         profile:(NSDictionary *)devInfo
                  imageDataArray:(NSArray*)imageDataArray
                  imageNameArray:(NSArray*)imageNameArray
                         /* name:(NSString *)name
                       custbrand:(NSString *)custbrand
                  custservicenum:(NSString *)custservicenum
                      picturedel:(NSArray *)picturedel
                      pictureadd:(NSArray *)pictureadd
                           color:(NSString *)color
                            type:(NSInteger)type∂
                     platenumber:(NSString *)platenumber
                    otherfeature:(NSString *)otherfeature
                             vin:(NSString *)vin
                     motornumber:(NSString *)motornumber */
                        progress:(Progress_Callback)progressCallback
                        callback:(API_CALLBACK)callback {
    NSMutableDictionary * infoDic = devInfo.mutableCopy;
    [infoDic setObject:devid forKey:@"devid"];
    [infoDic setObject:[NSNumber numberWithInteger:updateType] forKey:@"updatetype"];
    
    ApiImageRequest *request = [ApiImageRequest requestWithBizData:infoDic.copy];
    if (imageDataArray) {
        request.imageDataArray = [NSArray arrayWithArray:imageDataArray];
    }
    if (imageNameArray) {
        request.imageNameArray = [NSArray arrayWithArray:imageNameArray];
    }
    
    return [G100ApiHelper postImageApi:@"app/updatebikeprofile" andRequest:request imageArray:imageDataArray nameArray:imageDataArray progress:progressCallback callback:callback];
}

- (ApiRequest *)getBikeLostRecordWithDev:(NSString *)devid lostid:(NSArray *)lostid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid),
                                                            @"lostid" : EMPTY_IF_NIL(lostid)}];
    return [G100ApiHelper postApi:@"app/getbikelostrecord" andRequest:request callback:callback];
}

- (ApiRequest *)reportBikeLostWithDev:(NSString *)devid
                       lostid:(NSInteger)lostid
                    lostlongi:(CGFloat)lostlongi
                     lostlati:(CGFloat)lostlati
                     losttime:(NSString *)losttime
                  lostlocdesc:(NSString *)lostlocdesc
                      contact:(NSString *)contact
                     phonenum:(NSString *)phonenum
                     callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid),
                                                           @"lostid" : [NSNumber numberWithInteger:lostid],
                                                           @"lostlongi" : [NSNumber numberWithFloat:lostlongi],
                                                           @"lostlati" : [NSNumber numberWithFloat:lostlati],
                                                           @"losttime" : EMPTY_IF_NIL(losttime),
                                                           @"lostlocdesc" : EMPTY_IF_NIL(lostlocdesc),
                                                           @"contact" : EMPTY_IF_NIL(contact),
                                                           @"phonenum" : EMPTY_IF_NIL(phonenum)}];
    return [G100ApiHelper postApi:@"app/reportbikelost" andRequest:request callback:callback];
}

- (ApiRequest *)addFindLostRecordWithDev:(NSString *)devid
                          lostid:(NSInteger)lostid
                            desc:(NSString *)desc
                         picture:(NSArray *)picture
                        callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid),
                                                           @"desc" : EMPTY_IF_NIL(desc),
                                                           @"lostid" : [NSNumber numberWithInteger:lostid],
                                                           @"picture" : EMPTY_IF_NIL(picture)}];
    return [G100ApiHelper postApi:@"app/addfindlostrecord" andRequest:request callback:callback];
}

- (ApiRequest *)getFindLostRecordWithDev:(NSString *)devid
                          lostid:(NSInteger)lostid
                            page:(NSInteger)page
                            size:(NSInteger)size
                        callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid),
                                                           @"lostid" : [NSNumber numberWithInteger:lostid],
                                                           @"page" : [NSNumber numberWithInteger:page],
                                                           @"size" : [NSNumber numberWithInteger:size]}];
    return [G100ApiHelper postApi:@"app/getfindlostrecord" andRequest:request callback:callback];
}

- (ApiRequest *)deleteFindLostRecordWithDev:(NSString *)devid
                             lostid:(NSInteger)lostid
                         findlostid:(NSInteger)findlostid
                           callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid),
                                                            @"lostid" : [NSNumber numberWithInteger:lostid],
                                                            @"findlostid" : [NSNumber numberWithInteger:findlostid]}];
    return [G100ApiHelper postApi:@"app/delfindlostrecord" andRequest:request callback:callback];
}

- (ApiRequest *)endFindLostWithDev:(NSString *)devid
                    lostid:(NSInteger)lostid
                foundlongi:(CGFloat)foundlongi
                 foundlati:(CGFloat)foundlati
              foundlocdesc:(NSString *)foundlocdesc
                  callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"devid" : EMPTY_IF_NIL(devid),
                                                            @"lostid" : [NSNumber numberWithInteger:lostid],
                                                            @"foundlongi" : [NSNumber numberWithFloat:foundlongi],
                                                            @"foundlati" : [NSNumber numberWithFloat:foundlati],
                                                            @"foundlocdesc" : EMPTY_IF_NIL(foundlocdesc)}];
    return [G100ApiHelper postApi:@"app/endfindlost" andRequest:request callback:callback];
}

- (ApiRequest *)shareBikeLostWithLostid:(NSInteger)lostid
                          devid:(NSString *)devid
                       shareurl:(NSString *)shareurl
                       callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"lostid" : [NSNumber numberWithInteger:lostid],
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"shareurl" : EMPTY_IF_NIL(shareurl)}];
    return [G100ApiHelper postApi:@"app/sharebikelost" andRequest:request callback:callback];
}

- (ApiRequest *)setWXNotifyWithDevid:(NSString *)devid notify:(BOOL)notify callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"notify" : EMPTY_IF_NIL([NSNumber numberWithInteger:notify])}];
    return [G100ApiHelper postApi:@"app/setwxnotify" andRequest:request callback:callback];
}
- (ApiRequest *)setPhoneNotifyWithDevid:(NSString *)devid phoneNum:(NSString *)phoneNum notify:(BOOL)notify callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"phone_num" : EMPTY_IF_NIL(phoneNum),
                                                            @"notify" : EMPTY_IF_NIL([NSNumber numberWithInteger:notify])}];
    return [G100ApiHelper postApi:@"app/setphonenotify" andRequest:request callback:callback];
}
- (ApiRequest *)setPhoneNotifyWithDevid:(NSString *)devid notify:(BOOL)notify callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"notify" : EMPTY_IF_NIL([NSNumber numberWithInteger:notify])}];
    return [G100ApiHelper postApi:@"app/setphonenotify" andRequest:request callback:callback];
}
- (ApiRequest *)testAlarmNotifyWithDevid:(NSString *)devid type:(NSInteger)type callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"type" : EMPTY_IF_NIL([NSNumber numberWithInteger:type])}];
    return [G100ApiHelper postApi:@"app/testnotify" andRequest:request callback:callback];
}
- (ApiRequest *)testAlarmNotifyWithBikeid:(NSString *)bikeid devid:(NSString *)devid type:(NSInteger)type callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            @"device_id" : [NSNumber numberWithInteger:[devid integerValue]],
                                                            @"type" : [NSNumber numberWithInteger:type]}];
    return [G100ApiHelper postApi:@"warn/testnotify" andRequest:request callback:callback];
}
- (ApiRequest *)changeLocatorWithBikeid:(NSString *)bikeid devid:(NSString *)devid qr:(NSString *)qr callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            @"device_id" : [NSNumber numberWithInteger:[devid integerValue]],
                                                            @"qr" : EMPTY_IF_NIL(qr)}];
    return [G100ApiHelper postApi:@"bike/changelocator" andRequest:request callback:callback];
}

- (ApiRequest *)updateDeviceNameWithBikeid:(NSString *)bikeid devid:(NSString *)devid deviceName:(NSString *)deviceName callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            @"device_id" : [NSNumber numberWithInteger:[devid integerValue]],
                                                            @"device_name" : EMPTY_IF_NIL(deviceName)}];
    return [G100ApiHelper postApi:@"bike/updatedevicename" andRequest:request callback:callback];
}

- (ApiRequest *)controllerLockWithBikeid:(NSString *)bikeid
                           devid:(NSString *)devid
                            lock:(NSInteger)lock
                        callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            @"device_id" : [NSNumber numberWithInteger:[devid integerValue]],
                                                            @"lock" : [NSNumber numberWithInteger:lock]
                                                            }];
    return [G100ApiHelper postApi:@"bike/controllerlock" andRequest:request callback:callback];
}

- (ApiRequest *)setAlertorSoundWithDevid:(NSString *)devid func:(NSInteger)func sound:(NSInteger)sound callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"devid" : EMPTY_IF_NIL(devid),
                                                            @"func" : [NSNumber numberWithInteger:func],
                                                            @"sound" : [NSNumber numberWithInteger:sound]}];
    return [G100ApiHelper postApi:@"app/setalertorsound" andRequest:request callback:callback];
}

- (ApiRequest *)setAlertorSoundWithBikeid:(NSString *)bikeid devid:(NSString *)devid func:(NSInteger)func sound:(NSInteger)sound callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            @"device_id" : [NSNumber numberWithInteger:[devid integerValue]],
                                                            @"func" : [NSNumber numberWithInteger:func],
                                                            @"sound" : [NSNumber numberWithInteger:sound]}];
    return [G100ApiHelper postApi:@"bike/setalertorsound" andRequest:request callback:callback];
}

@end

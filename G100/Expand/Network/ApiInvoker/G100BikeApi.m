//
//  G100BikeApi.m
//  G100
//
//  Created by yuhanle on 16/7/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeApi.h"

@implementation G100BikeApi

+(instancetype)sharedInstance {
    static G100BikeApi * instance;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (ApiRequest *)addBikeWithUserid:(NSString *)userid bikeInfo:(NSDictionary *)bikeInfo callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_info" : EMPTY_IF_NIL(bikeInfo)}];
    return [G100ApiHelper postApi:@"bike/addbike" andRequest:request callback:callback];
}

- (ApiRequest *)getAllBikelistWithUserid:(NSString *)userid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"user_id" : EMPTY_IF_NIL(userid),
                                                            
                                                            @"bike_ids" : @[]
                                                            }];
    return [G100ApiHelper postApi:@"bike/getbikelist" andRequest:request callback:callback];
}

- (ApiRequest *)getBikelistWithUserid:(NSString *)userid bikeids:(NSArray *)bikeids callback:(API_CALLBACK)callback
{
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"user_id" : EMPTY_IF_NIL(userid),
                                                            
                                                            @"bike_ids" : EMPTY_IF_NIL(bikeids)
                                                            }];
    return [G100ApiHelper postApi:@"bike/getbikelist" andRequest:request callback:callback];
}

- (ApiRequest *)getBikeInfoWithUserid:(NSString *)userid bikeid:(NSString *)bikeid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_ids" : @[[NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue]]
                                                            }];
    return [G100ApiHelper postApi:@"bike/getbikelist" andRequest:request callback:callback];
}

- (ApiRequest *)getBikeRuntimeWithBike_ids:(NSArray *)bikeids traceMode:(NSInteger)traceMode callback:(API_CALLBACK)callback {
    NSMutableArray * tempBikeids = [NSMutableArray array];
    for (NSString * bikeid in bikeids) {
        [tempBikeids addObject:[NSNumber numberWithInteger:[bikeid integerValue]]];
    }
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_ids" : EMPTY_IF_NIL(tempBikeids),
                                                            @"trace_mode" : [NSNumber numberWithInteger:traceMode]}];
    return [G100ApiHelper postApi:@"bike/getbikeruntime" andRequest:request callback:callback];
}

- (ApiRequest *)getDeviceRuntimeWithbikeid:(NSInteger)bikeid device_ids:(NSArray *)device_ids callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:bikeid],
                                                            @"device_ids" : EMPTY_IF_NIL(device_ids)}];
    return [G100ApiHelper postApi:@"bike/getdeviceruntime" andRequest:request callback:callback];
}

- (ApiRequest *)setBikeSecuritySettingsWithUserid:(NSString *)userid bikeid:(NSString *)bikeid devid:(NSString *)devid mode:(NSInteger)mode callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : EMPTY_IF_NIL([NSNumber numberWithInteger:[bikeid integerValue]]),
                                                            @"device_id" : EMPTY_IF_NIL([NSNumber numberWithInteger:[devid integerValue]]),
                                                            @"mode" : EMPTY_IF_NIL([NSNumber numberWithInteger:mode]),
                                                            }];
    return [G100ApiHelper postApi:@"bike/securitysetting" andRequest:request callback:callback];
}

-(ApiRequest *)evaluatingBikeSafetyScoreWithBikeid:(NSString *)bikeid callback:(API_CALLBACK)callback
{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            }];
    return [G100ApiHelper postApi:@"bike/getsecurityscore" andRequest:request callback:callback];
}

- (ApiRequest *)bindBikeDeviceWithUserid:(NSString *)userid bikeid:(NSString *)bikeid bikeName:(NSString *)bikeName new_flag:(NSInteger)new_flag qr:(NSString *)qr callback:(API_CALLBACK)callback {
    NSMutableDictionary *bike_info = [[NSMutableDictionary alloc] init];
    [bike_info setObject:[NSNumber numberWithInteger:[userid integerValue]] forKey:@"user_id"];
    [bike_info setObject:[NSNumber numberWithInteger:[bikeid integerValue]] forKey:@"bike_id"];
    [bike_info setObject:EMPTY_IF_NIL(bikeName) forKey:@"name"];
    
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_info" : bike_info.copy,
                                                            @"new_flag" : [NSNumber numberWithInteger:new_flag],
                                                            @"qr" : EMPTY_IF_NIL(qr)
                                                            }];
    return [G100ApiHelper postApi:@"bike/binddevice" andRequest:request callback:callback];
}

- (ApiRequest *)rebindBikeDeviceWithbikeid:(NSString *)bikeid devid:(NSString *)devid callback:(API_CALLBACK)callback
{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:bikeid.integerValue],
                                                            @"device_id" : [NSNumber numberWithInteger:devid.integerValue]
                                                            }];
    return [G100ApiHelper postApi:@"bike/readddevice" andRequest:request callback:callback];
}

- (ApiRequest *)addBikeDeviceWithUserid:(NSString *)userid bikeid:(NSString *)bikeid bikeName:(NSString *)bikeName new_flag:(NSInteger)new_flag qr:(NSString *)qr callback:(API_CALLBACK)callback;
{
    NSMutableDictionary *bike_info = [[NSMutableDictionary alloc] init];
    [bike_info setObject:[NSNumber numberWithInteger:[userid integerValue]] forKey:@"user_id"];
    [bike_info setObject:[NSNumber numberWithInteger:[bikeid integerValue]] forKey:@"bike_id"];
    [bike_info setObject:EMPTY_IF_NIL(bikeName) forKey:@"name"];
    
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:bikeid.integerValue],
                                                            @"new_flag" : [NSNumber numberWithInteger:new_flag],
                                                            @"qr" : EMPTY_IF_NIL(qr)
                                                            }];
    return [G100ApiHelper postApi:@"bike/adddevice" andRequest:request callback:callback];
}

- (ApiRequest *)addBikeDeviceWithUserid:(NSString *)userid bikeid:(NSString *)bikeid bikeName:(NSString *)bikeName new_flag:(NSInteger)new_flag devid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            @"device_id" : [NSNumber numberWithInteger:[devid integerValue]]
                                                            }];
    return [G100ApiHelper postApi:@"bike/scanningbind" andRequest:request callback:callback];
}

- (ApiRequest *)deleteBikeWithUserid:(NSString *)userid bikeid:(NSString *)bikeid callback:(API_CALLBACK)callback {
    NSMutableDictionary *bikeInfo = [[NSMutableDictionary alloc] init];
    if (bikeid) {
        [bikeInfo setObject:[NSNumber numberWithInteger:[bikeid integerValue]] forKey:@"bike_id"];
    }
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_info" : EMPTY_IF_NIL(bikeInfo)}];
    return [G100ApiHelper postApi:@"bike/deletebike" andRequest:request callback:callback];
}

- (ApiRequest *)loadDevDayDriveSummaryWithBikeid:(NSString *)bikeid devid:(NSString *)devid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            @"device_id" : [NSNumber numberWithInteger:[devid integerValue]]}];
    return [G100ApiHelper postApi:@"bike/bikeusagesummarydaily" andRequest:request callback:callback];
}

- (ApiRequest *)loadListDevMsgWithBikeid:(NSString *)bikeid
                           devid:(NSString *)devid
                       begintime:(NSString *)begintime
                         endtime:(NSString *)endtime
                        callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            @"device_id" : [NSNumber numberWithInteger:[devid integerValue]],
                                                            @"begin_time" : EMPTY_IF_NIL(begintime),
                                                            @"end_time" : EMPTY_IF_NIL(endtime)
                                                            }];
    // 请求缓慢 设置超时时间为60s
    return [G100ApiHelper postApi:@"bike/listdevmsg" andRequest:request token:YES https:YES timeoutInSeconds:60 callback:callback];
}

- (ApiRequest *)loadDevHistoryTrackWithBikeid:(NSString *)bikeid
                                devid:(NSString *)devid
                            begintime:(NSString *)begintime
                              endtime:(NSString *)endtime
                             callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            @"device_id" : [NSNumber numberWithInteger:[devid integerValue]],
                                                            @"begin_time" : EMPTY_IF_NIL(begintime),
                                                            @"end_time" : EMPTY_IF_NIL(endtime)
                                                            }];
    // 请求缓慢 设置超时时间为60s
    return [G100ApiHelper postApi:@"bike/getbiketrack" andRequest:request token:YES https:YES timeoutInSeconds:60 callback:callback];
}

- (ApiRequest *)loadRelativeUserinfoWithBikeid:(NSString *)bikeid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]]}];
    return [G100ApiHelper postApi:@"bike/getbikeusers" andRequest:request callback:callback];
}

- (ApiRequest *)updateBikeNameWithBikeid:(NSString *)bikeid bikedName:(NSString *)bikeName callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:[bikeid integerValue]],
                                                            @"name" : EMPTY_IF_NIL(bikeName)}];
    return [G100ApiHelper postApi:@"bike/updatebikename" andRequest:request callback:callback];
}

- (ApiRequest *)updateBikeProfileWithBikeid:(NSString *)bikeid
                                   bikeType:(NSInteger)bikeType
                                    profile:(NSDictionary *)bikeInfo
                                   progress:(Progress_Callback)progressCallback
                                   callback:(API_CALLBACK)callback{
    NSMutableDictionary * infoDic = bikeInfo.mutableCopy;
    [infoDic setObject:[NSNumber numberWithInteger:bikeType] forKey:@"bike_type"];
    ApiImageRequest *request = [ApiImageRequest requestWithBizData:@{@"bike_info" : infoDic.copy}];
    return [G100ApiHelper postApi:@"bike/updatebikeprofile" andRequest:request callback:callback];
}
-(ApiRequest *)removeBikeUserWithUserid:(NSString *)userid
                        bikeid:(NSString *)bikeid
                      callback:(API_CALLBACK)callback{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                            @"user_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(userid).integerValue]
                                                            }];
    return [G100ApiHelper postApi:@"bike/deletebikeuser" andRequest:request callback:callback];
}

- (ApiRequest *)getBikeBrandsWithBikeType:(NSInteger)bikeType :(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"bike_type" : [NSNumber numberWithInteger:bikeType]}];
    return [G100ApiHelper postApi:@"bike/getbikebrands" andRequest:request callback:callback];
}

- (ApiRequest *)setWXNotifyWithBikeid:(NSString *)bikeid notify:(BOOL)notify callback:(API_CALLBACK)callback{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                            @"notify" : EMPTY_IF_NIL([NSNumber numberWithInteger:notify])}];
    return [G100ApiHelper postApi:@"bike/setwxnotify" andRequest:request callback:callback];
}

- (ApiRequest *)setPhoneNotifyWithBikeid:(NSString *)bikeid notify:(BOOL)notify callback:(API_CALLBACK)callback{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                            @"notify" : EMPTY_IF_NIL([NSNumber numberWithInteger:notify])}];
    return [G100ApiHelper postApi:@"bike/setphonenotify" andRequest:request callback:callback];
}

- (ApiRequest *)setPhoneNotifyWithBikeid:(NSString *)bikeid phoneNum:(NSString *)phoneNum notify:(BOOL)notify callback:(API_CALLBACK)callback{
    ApiRequest * request = [ApiRequest requestWithBizData:@{
                                                            @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                            @"phone_num" : EMPTY_IF_NIL(phoneNum),
                                                            @"notify" : EMPTY_IF_NIL([NSNumber numberWithInteger:notify])}];
    return [G100ApiHelper postApi:@"bike/setphonenotify" andRequest:request callback:callback];

}

- (ApiRequest *)getBikeLostRecordWithBikeid:(NSString *)bikeid lostid:(NSArray *)lostid callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                            @"lostid" : EMPTY_IF_NIL(lostid)}];
    return [G100ApiHelper postApi:@"bike/getbikelostrecord" andRequest:request callback:callback];
}

- (ApiRequest *)reportBikeLostWithBikeid:(NSString *)bikeid
                       lostid:(NSInteger)lostid
                    lostlongi:(CGFloat)lostlongi
                     lostlati:(CGFloat)lostlati
                     losttime:(NSString *)losttime
                  lostlocdesc:(NSString *)lostlocdesc
                      contact:(NSString *)contact
                     phonenum:(NSString *)phonenum
                     callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"lostid" : [NSNumber numberWithInteger:lostid],
                                                           @"lostlongi" : [NSNumber numberWithFloat:lostlongi],
                                                           @"lostlati" : [NSNumber numberWithFloat:lostlati],
                                                           @"losttime" : EMPTY_IF_NIL(losttime),
                                                           @"lostlocdesc" : EMPTY_IF_NIL(lostlocdesc),
                                                           @"contact" : EMPTY_IF_NIL(contact),
                                                           @"phonenum" : EMPTY_IF_NIL(phonenum)}];
    return [G100ApiHelper postApi:@"bike/reportbikelost" andRequest:request callback:callback];
}

- (ApiRequest *)addFindLostRecordWithBikeid:(NSString *)bikeid
                          lostid:(NSInteger)lostid
                            desc:(NSString *)desc
                         picture:(NSArray *)picture
                        callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"desc" : EMPTY_IF_NIL(desc),
                                                           @"lostid" : [NSNumber numberWithInteger:lostid],
                                                           @"picture" : EMPTY_IF_NIL(picture)}];
    return [G100ApiHelper postApi:@"bike/addfindlostrecord" andRequest:request callback:callback];
}

- (ApiRequest *)getFindLostRecordWithBikeid:(NSString *)bikeid
                          lostid:(NSInteger)lostid
                            page:(NSInteger)page
                            size:(NSInteger)size
                        callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"lostid" : [NSNumber numberWithInteger:lostid],
                                                           @"page" : [NSNumber numberWithInteger:page],
                                                           @"size" : [NSNumber numberWithInteger:size]}];
    return [G100ApiHelper postApi:@"bike/getfindlostrecord" andRequest:request callback:callback];
}

- (ApiRequest *)deleteFindLostRecordWithBikeid:(NSString *)bikeid
                             lostid:(NSInteger)lostid
                         findlostid:(NSInteger)findlostid
                           callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                            @"lostid" : [NSNumber numberWithInteger:lostid],
                                                            @"findlostid" : [NSNumber numberWithInteger:findlostid]}];
    return [G100ApiHelper postApi:@"bike/delfindlostrecord" andRequest:request callback:callback];
}

- (ApiRequest *)endFindLostWithBikeid:(NSString *)bikeid
                    lostid:(NSInteger)lostid
                foundlongi:(CGFloat)foundlongi
                 foundlati:(CGFloat)foundlati
              foundlocdesc:(NSString *)foundlocdesc
                  callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                            @"lostid" : [NSNumber numberWithInteger:lostid],
                                                            @"foundlongi" : [NSNumber numberWithFloat:foundlongi],
                                                            @"foundlati" : [NSNumber numberWithFloat:foundlati],
                                                            @"foundlocdesc" : EMPTY_IF_NIL(foundlocdesc)}];
    return [G100ApiHelper postApi:@"bike/endfindlost" andRequest:request callback:callback];
}

- (ApiRequest *)shareBikeLostWithLostid:(NSInteger)lostid
                          bikeid:(NSString *)bikeid
                       shareurl:(NSString *)shareurl
                       callback:(API_CALLBACK)callback {
    ApiRequest * request = [ApiRequest requestWithBizData:@{@"lostid" : [NSNumber numberWithInteger:lostid],
                                                            @"bike_id" :[NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                            @"shareurl" : EMPTY_IF_NIL(shareurl)}];
    return [G100ApiHelper postApi:@"bike/sharebikelost" andRequest:request callback:callback];
}

- (ApiRequest *)setAccNotifyWithBikeid:(NSString *)bikeid notify:(NSInteger)notify callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"notify" : [NSNumber numberWithInteger:notify]
                                                           }];
    return [G100ApiHelper postApi:@"bike/setaccnotify" andRequest:request callback:callback];
}

- (ApiRequest *)setSamePushIgnoreWithBikeid:(NSString *)bikeid ignoretime:(NSInteger)ignoretime callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"ignore_notify_time" : [NSNumber numberWithInteger:ignoretime]
                                                           }];
    return [G100ApiHelper postApi:@"bike/setsamepushignore" andRequest:request callback:callback];
}

- (ApiRequest *)ignoreSamePushWithBikeid:(NSString *)bikeid pushtype:(NSString *)pushtype callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"pushtype" : EMPTY_IF_NIL(pushtype)
                                                           }];
    return [G100ApiHelper postApi:@"bike/ignoresamepush" andRequest:request callback:callback];
}
- (ApiRequest *)setOverSpeedWithBikeid:(NSString *)bikeid  maxSpeed:(CGFloat)maxSpeed callback:(API_CALLBACK)callback{
    ApiRequest *request = [ApiRequest requestWithBizData:@{@"bike_id":[NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"max_speed":[NSNumber numberWithFloat:maxSpeed]}];
    return [G100ApiHelper postApi:@"bike/setbikefeature" andRequest:request callback:callback];;
}
- (ApiRequest *)setBikeCoverWithBikeid:(NSString *)bikeid coverPicture:(NSString *)coverPicture callback:(API_CALLBACK)callback{
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"cover_picture" : coverPicture
                                                           }];
    return [G100ApiHelper postApi:@"bike/setbikecover" andRequest:request callback:callback];
}

- (ApiRequest *)updateBikeSeqWithUserid:(NSString *)userid bike_seq:(NSArray *)bike_seq callback:(API_CALLBACK)callback {
    ApiRequest *request = [ApiRequest requestWithBizData:@{ @"bike_seq" : bike_seq ? bike_seq : @[] }];
    return [G100ApiHelper postApi:@"bike/updatebikeseq" andRequest:request callback:callback];
}
- (void)checkDeviceFirmWithBikeid:(NSString *)bikeid deviceid:(NSString *)deviceid callback:(API_CALLBACK)callback{
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"device_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(deviceid).integerValue]
                                                           }];
    [G100ApiHelper postApi:@"bike/checkdevicefirm" andRequest:request callback:callback];
}
- (void)confirmDeiveFirmUpdateWithBikeid:(NSString *)bikeid deviceid:(NSString *)deviceid callback:(API_CALLBACK)callback{
    ApiRequest *request = [ApiRequest requestWithBizData:@{
                                                           @"bike_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(bikeid).integerValue],
                                                           @"device_id" : [NSNumber numberWithInteger:EMPTY_IF_NIL(deviceid).integerValue]
                                                           }];
    [G100ApiHelper postApi:@"bike/confirmdevicefirmupgrade" andRequest:request callback:callback];
}
@end

//
//  G100RemoteCtrlManager.m
//  G100
//
//  Created by yuhanle on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100RemoteCtrlManager.h"
#import "G100DevApi.h"

@implementation G100RemoteCtrlManager

+ (instancetype)sharedInstance {
    static G100RemoteCtrlManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)operateAlertorWithBikeid:(NSString *)bikeid
                           devid:(NSString *)devid
                         command:(DEV_ALERTOR_COMMAND)command
                   commandParams:(NSDictionary *)commandParams
                            type:(NSInteger)type
                        callback:(API_CALLBACK)callback {
    
    API_CALLBACK callback2 = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (callback) {
            callback(statusCode, response, requestSuccess);
        }
    };
    [[G100DevApi sharedInstance] sendOperateAlertorWithBikeid:bikeid devid:devid command:command commandParams:commandParams callback:callback2];
}

@end

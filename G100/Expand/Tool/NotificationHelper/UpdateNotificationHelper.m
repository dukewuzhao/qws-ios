//
//  UpdateNotificationHelper.m
//  G100
//
//  Created by 曹晓雨 on 2017/10/24.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "UpdateNotificationHelper.h"
#import "G100DevUpdateViewController.h"
#import "G100PushMsgAddvalDomain.h"
#import "G100PushMsgDomain.h"
#import "G100MsgDomain.h"

@implementation UpdateNotificationHelper

+ (instancetype)shareInstance {
    static UpdateNotificationHelper * instance;
    static dispatch_once_t onecToken;
    dispatch_once(&onecToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void)application:(UIApplication *)application didReceiveJPushRemoteNotification:(NSDictionary *)userInfo {
    // 处理接收到的数据
    G100PushMsgDomain * pushDomain = [[G100PushMsgDomain alloc] initWithDictionary:userInfo];
    //跳转消息中心页面
    G100MsgDomain * msg = [[G100MsgDomain alloc] initWithDictionary:userInfo];
    if (application.applicationState == UIApplicationStateActive) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1007);
        /**
         * {
         *  "showdialog": 0, // 显示弹窗 0不显示 1显示
         *  "oktext" : "立即查看", // 确定按钮文本
         *  "canceltext": "忽略", // 取消按钮文本
         * }
         *
         */
        G100PushMsgAddvalDomain *addval = [[G100PushMsgAddvalDomain alloc] initWithDictionary:[pushDomain.addval mj_JSONObject]];
        if ([[CURRENTVIEWCONTROLLER class] isSubclassOfClass:[G100DevUpdateViewController class]]) {
            return;
        }
        if (addval.showdialog) {
            if (addval.oktext.length && addval.canceltext.length) {
                [MyAlertView MyAlertWithTitle:pushDomain.custtitle message:pushDomain.custdesc delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        NSString *url = msg.page.length ? msg.page : msg.mcurl;
                        if ([G100Router canOpenURL:url]) {
                            [G100Router openURL:url];
                        }
                    }
                } cancelButtonTitle:addval.canceltext otherButtonTitles:addval.oktext];
                
                return;
            } else if (addval.canceltext.length && !addval.oktext.length) {
                [MyAlertView MyAlertWithTitle:pushDomain.custtitle message:pushDomain.custdesc delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
                } cancelButtonTitle:addval.canceltext otherButtonTitles:nil];
                
                return;
            }
        }
    } else { //后台情况
        NSString *url = msg.page.length ? msg.page : msg.mcurl;
        if ([G100Router canOpenURL:url]) {
            [G100Router openURL:url];
        }
    }

}
@end

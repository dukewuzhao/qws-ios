//
//  DefineHeader.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#ifndef G100_DefineHeader_h
#define G100_DefineHeader_h

#import "AppDelegate.h"
#import "NSString+MD5Addition.h"

#define APPDELEGATE             ((AppDelegate*)([UIApplication sharedApplication].delegate))
#define KEY_WINDOW              [UIApplication sharedApplication].delegate.window
#define CURRENTVIEWCONTROLLER   KEY_WINDOW.currentViewController.topParentViewController
#define TOP_VIEW                KEY_WINDOW.rootViewController.view

#define kNavigationBarHeight    (ISIPHONEX ? 88 : 64)
#define kBottomPadding          (ISIPHONEX ? 34 : 0)
#define kBottomHeight           0

#define RGBColor(r, g, b, a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define MyBlueColor             [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0]
#define MyGreenColor            [UIColor colorWithRed:35.0/255.0 green:150.0/255.0 blue:60.0/255.0 alpha:1.0]
#define MyOrangeColor           [UIColor colorWithRed:255.0/255.0 green:82.0/255.0 blue:33.0/255.0 alpha:1.0]
#define MyYellowColor           [UIColor colorWithRed:200.0/255.0 green:160.0/255.0 blue:20.0/255.0 alpha:1.0]
#define MyBackColor             [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1]
#define MyNavColor              [UIColor colorWithRed:79.0/255.0 green:169.0/255.0 blue:51.0/255.0 alpha:1.0]
#define MyHomeColor             [UIColor colorWithRed:73.0/255.0 green:178.0/255.0 blue:74.0/255.0 alpha:1.0]
#define MyTabColor              [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:221.0/255.0 alpha:0.8]
#define MyAlphaColor            [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:0.5]
#define MySelectedColor         [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:0.6]
#define MyFxBlueColor           [UIColor colorWithRed:252.0/255.0 green:250.0/255.0 blue:214.0/255.0 alpha:1.0]

#define Color_NavigationBGColor [UIColor blackColor]

#define FontInSmallest(fontSize)    (WIDTH/320.0)*(fontSize)
#define FontInBiggest(fontSize)     (WIDTH/414.0)*(fontSize)

#define WidthInSmallest(width)      (WIDTH/320.0)*(width)
#define HeightInSmallest(height)    (HEIGHT/480.0)*(height)

// 通知中心的宏
#define kGNPresentBigPopBoxView             @"com.tilink.360qws.presentbigboxview"              //!< 大弹框
#define kGNUpdatePower                      @"com.tilink.360qws.updatepower"                    //!< 电量更新
#define kGNDevAccStatusOnorOff              @"com.tilink.360qws.devaccstatusonoroff"            //!< 电门状态
#define kGNShakeComeFromServer              @"com.tilink.360qws.shakecomefromserver"            //!< 震动报警
#define kGNPingPPPayResult                  @"com.tilink.360qws.pingpppayreult"                 //!< 支付结果
#define kGNRefreshCarList                   @"com.tilink.360qws.refreshcarlist"                 //!< 车辆列表刷新
#define kGNRemoteLoginMsg                   @"com.tilink.360qws.remoteloginmsg"                 //!< 异地登陆消息
#define kGNRemoteAlarmHandleMsg             @"com.tilink.360qws.alarmhandlemsg"                 //!< 报警消息处理
#define kGNShowGuidePage                    @"com.tilink.360qws.showguidepage"                  //!< 通知展示引导页
#define kGNShowMainView                     @"com.tilink.360qws.showmainview"                   //!< 通知进入主页面
#define kGNDIDShowMainView                  @"com.tilink.360qws.didshowmainview"                //!< 通知已经进入主页面
#define kGNShowNewMsgSignal                 @"com.tilink.360qws.shownewmsgsignal"               //!< 通知显示新消息小圆点
#define kGNStartNotificationTest            @"com.tilink.360qws.startNotificationTest"          //!< 开始App推送测试
#define kGNAppTestTimeUpNotification        @"com.tilink.360qws.apptesttimeupnotification"      //!< app报警到时通知
#define kGNWechatTestTimeUpNotification     @"com.tilink.360qws.wechattesttimeupnotification"   //!< 微信报警到时通知
#define kGNPhoneTestTimeUpNotification      @"com.tilink.360qws.phonetesttimeupnotification"    //!< 电话报警到时通知
#define kGNAppTestRecievedNotification      @"com.tilink.360qws.apptestrecievednotification"    //!< 收到App推送测试的通知
#define kGNAppLoginOrLogoutNotification     @"com.tilink.360qws.apploginorlogoutnotification"   //!< 用户登录和注销的通知
#define kGNLostBikeAlarmComeFromServer      @"com.tilink.360qws.lostBikeAlarmFromServer"        //!< 丢车报警消息来临
#define kGNDevBindFailed                    @"com.tilink.360qws.devBindFailed"                  //!< 绑定设备失败
#define kGNDeleteBikeSuccess                @"com.tilink.360qws.deleteBikeSuccess"              //!< 删除设备消息通知

#define PWENCRYPT(STRING)                   [[NSString stringWithFormat:@"G%@100", STRING] stringFromMD5]

#endif

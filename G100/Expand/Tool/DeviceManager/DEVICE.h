//
//  DEVICE.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import"DeviceManager.h"

#ifndef ______DEVICE_h
#define ______DEVICE_h

#define ISIOS7ADD ISIOS7

#define HEIGHT [DeviceManager currentScreenHeight]

#define WIDTH [DeviceManager currentScreenWidth]

#define ISIOS7 [DeviceManager isIOS7Version]
// iOS7的话，就是我们的屏幕是从（0，0）开始的
#define ISIOS8 [DeviceManager isIOS8Version]

#define ISIOS8ADD [DeviceManager isIOS8ADDVersion]

#define ISIOS9 [DeviceManager isIOS9Version]

#define ISIOS10 [DeviceManager isIOS10Version]

#define MODEL [DeviceManager currentDeviceModel]

#define ISIPHONE_4 [DeviceManager isIphone4]

#define ISIPHONE_5 [DeviceManager isIphone5]

#define ISIPHONE_6 [DeviceManager isIphone6]

#define ISIPHONE_6p [DeviceManager isIphone6p]

#define ISIPHONEX [DeviceManager isIphoneX]

#define ISIPHONE [DeviceManager isIphone]

#define DeviceAndOSInfo [DeviceManager getDeviceAndOSInfo]

#endif

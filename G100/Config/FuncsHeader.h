//
//  FuncsHeader.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DEVICE.h"
#import "G100Macros.h"
#import "GTMBase64.h"
#import "DefineHeader.h"

#import "UIView+Wen_Additions.h"
#import "CALayer+Addtion.h"
#import "UIImage+G100Size.h"
#import "UIImage+Rotate.h"
#import "UIImage+Tint.h"
#import "UIViewController+PopCount.h"
#import "CABasicAnimation+Additions.h"
#import "UIViewController+HUD.h"
#import "UIViewController+UMeng.h"

#import "NSArray+G100Util.h"
#import "UIColor+G100Color.h"
#import "NSDate+G100Util.h"
#import "NSDate+TimeString.h"
#import "NSDateFormatter+G100Util.h"
#import "NSDictionary+G100Util.h"
#import "NSString+CheckInputTool.h"
#import "NSString+Tool.h"

#import "MyAlertView.h"
#import "MozTopAlertView.h"
#import "G100AlertView.h"
#import "G100PopingView.h"
#import "G100NewPromptBox.h"

#import "G100SchemeHelper.h"
#import "UserManager.h"
#import "UserAccount.h"
#import "CurrentUser.h"

typedef void(^ABlock)();
@interface FuncsHeader : NSObject

void MyAlert(NSString * title, NSString * message);
void MyAlertTitle(NSString * message);

void G100MAlert(NSString * title, NSString * message, bool center, ABlock aBlock);
void G100MAlertTitleWithBlock(NSString * message, ABlock sureBlock);
void G100MAlertIKnow(NSString * title, NSString * message, bool center, ABlock aBlock);

NSString * GetCurrentTimeStr();
NSString * GetStrFromDate(NSDate * date);
UIImage * CreateImageWithColor(UIColor * color);

bool IsLogin();
bool IsBind();

@end

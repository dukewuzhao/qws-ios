//
//  EBCheckVersion.h
//  G100
//
//  Created by yuhanle on 2017/2/6.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBCheckVersion : NSObject

/*!
 Set your Apple generated software id here.
 */
+ (void)setAppId:(NSString*)appId;

+ (void)appLaunched:(BOOL)canPromptForRating;

+ (void)appBecomeActived;

@end

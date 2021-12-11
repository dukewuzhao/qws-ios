//
//  MsgRemainderInfo.h
//  Msg_remainder
//
//  Created by yuhanle on 2017/4/5.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MsgRemainderInfo : NSObject <NSCopying>

@property (nonatomic, copy) NSString *msgid;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *devid;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger style;
@property (nonatomic, strong) NSDictionary *extra;
@property (nonatomic, assign) long lastupdatetime;
@property (nonatomic, assign) long actiontime;
@property (nonatomic, copy) NSString *concern;

@property (nonatomic, assign) BOOL isread;

@end

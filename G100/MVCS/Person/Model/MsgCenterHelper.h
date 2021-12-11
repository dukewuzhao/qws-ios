//
//  MsgCenterHelper.h
//  G100
//
//  Created by yuhanle on 2018/7/13.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseOperation.h"

@interface MsgCenterHelper : NSObject

@property (nonatomic, assign) NSInteger unReadMsgCount;

+ (instancetype)sharedInstace;

/**
 查询消息中心未读消息数量

 @param userid 用户id
 @param block 查询回调
 */
- (void)loadUnReadMsgStatusWithUserid:(NSString *)userid success:(void(^)(NSInteger personalUnreadNum, NSInteger systemUnreadNum))block;

@end

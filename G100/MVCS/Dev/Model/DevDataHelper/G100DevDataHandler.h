//
//  G100DevDataHandler.h
//  G100
//
//  Created by William on 16/8/17.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class G100DevDataHandler;
@protocol G100DevDataHandlerDelegate <NSObject>
@optional
- (void)G100DevDataHandler:(G100DevDataHandler *)dataHandler receivedData:(ApiResponse *)response withUserid:(NSString *)userid bikeid:(NSString *)bikeid;

@end

@interface G100DevDataHandler : NSObject

@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString *bikeid;
@property (weak, nonatomic) id <G100DevDataHandlerDelegate> delegate;

- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;

/** 添加关注 */
- (void)addConcern;
/** 添加自定义时间关注 */
- (void)addConcernByCustomInterval;
/** 移除关注 */
- (void)removeConcern;
/** 移除自定义时间关注 */
- (void)removeConcernByCustomInterval;
/** 立即关注 */
- (void)concernNow:(API_CALLBACK)callback;

@end

//
//  G100ShareModel.h
//  G100ActionSheet
//
//  Created by yuhanle on 15/10/19.
//  Copyright © 2015年 yuhanle. All rights reserved.
//

#import <Foundation/Foundation.h>
@class G100ShareModel;

typedef void(^G100ShareHandler)(G100ShareModel * shareModel);

@interface G100ShareModel : NSObject

@property (nonatomic, copy)   NSString  *platformName;
@property (nonatomic, copy)   NSString  *displayName;
@property (nonatomic, copy)   NSString  *imgName;
@property (nonatomic, assign) NSInteger  tagNumber;

@property (nonatomic, assign) BOOL enable; //!< 记录该渠道是否可以分享 默认YES

@property (nonatomic, copy) G100ShareHandler handler;

+ (instancetype)shareModelWithSnsPlatform:(NSString *)snsPlatformName handler:(G100ShareHandler)handler;

@end

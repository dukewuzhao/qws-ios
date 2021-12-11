//
//  G100ShareDomain.h
//  G100
//
//  Created by yuhanle on 16/4/18.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100ShareDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger shareto;
@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *shareText;
@property (nonatomic, copy) NSString *shareTopic;
@property (nonatomic, copy) NSString *shareAtUser;
@property (nonatomic, copy) NSString *sharePicUrl;
@property (nonatomic, copy) NSString *shareJumpUrl;
/**
 *  分享的图片 data 或者 image
 */
@property (nonatomic, strong) id shareImage;

@end

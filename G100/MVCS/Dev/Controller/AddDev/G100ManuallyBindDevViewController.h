//
//  G100ManuallyBindDevViewController.h
//  G100
//
//  Created by yuhanle on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

@interface G100ManuallyBindDevViewController : G100BaseVC

/**
 *  用户id
 */
@property (nonatomic, copy) NSString *userid;
/**
 *  页面传过来的二维码 进入后直接调起绑定
 */
@property (nonatomic, copy) NSString *qrcode;
/**
 *  设置确定二维码后的操作
 *
 *  @param completionBlock 块操作
 */
- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock;

@end

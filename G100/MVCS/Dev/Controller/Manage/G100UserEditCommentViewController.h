//
//  G100UserEditCommentViewController.h
//  G100
//
//  Created by sunjingjing on 17/1/12.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

typedef void(^ModifyCommentSuccessBlock)(NSString *userComment);

@interface G100UserEditCommentViewController : G100BaseVC

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *oldComment;

@property (copy, nonatomic) ModifyCommentSuccessBlock sureBlock;

- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid oldComment:(NSString *)oldComment;

@end

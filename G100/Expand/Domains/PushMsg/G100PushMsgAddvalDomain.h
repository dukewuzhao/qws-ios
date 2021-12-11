//
//  G100PushMsgAddvalDomain.h
//  G100
//
//  Created by yuhanle on 16/2/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100PushMsgAddvalDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger showdialog; //!< 显示弹窗   0 不显示   1 显示
@property (nonatomic, copy) NSString *oktext; //!< 确定按钮文本
@property (nonatomic, copy) NSString *canceltext; //!< 取消按钮文本

@end

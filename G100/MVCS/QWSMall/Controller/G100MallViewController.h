//
//  G100MallViewController.h
//  G100
//
//  Created by yuhanle on 2017/7/10.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BaseXibVC.h"

typedef enum : NSUInteger {
    QWSMallTypeOther = 0,
    QWSMallTypeCarts,
    QWSMallTypeOrder
} QWSMallType;

@interface G100MallViewController : G100BaseXibVC

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) QWSMallType mallType;

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;
@property (nonatomic, copy) NSString *pageUrl;

@property (nonatomic, copy) NSString *webTitle;

+ (instancetype)loadXibViewControllerWithType:(QWSMallType)mallType;

@end

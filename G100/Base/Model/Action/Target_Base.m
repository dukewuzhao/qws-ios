//
//  Target_Base.m
//  G100
//
//  Created by yuhanle on 2017/1/3.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "Target_Base.h"

@implementation Target_Base

- (UIViewController *)notFound:(BOOL)found {
    return [[G100NotFoundViewController alloc] init];
}

@end

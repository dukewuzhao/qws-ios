//
//  QSWeakObjectWrapper.m
//  G100
//
//  Created by yuhanle on 2017/12/18.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "QSWeakObjectWrapper.h"

@implementation QSWeakObjectWrapper

- (id)initWithWeakObject:(id)weakObject{
    
    if (self = [super init]) {
        _weakObject = weakObject;
    }
    
    return self;
}

@end

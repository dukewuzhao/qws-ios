//
//  G100StartPageDomain.m
//  G100
//
//  Created by 温世波 on 15/12/15.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100StartPageDomain.h"

@implementation G100StartPageDomain

- (NSInteger)displaytime {
    
    if (_displaytime >=1 && _displaytime <= 10) {
        return _displaytime;
    }
    
    // 默认3s
    return 3;
}

@end

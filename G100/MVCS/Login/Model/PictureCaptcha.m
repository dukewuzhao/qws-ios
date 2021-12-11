//
//  PictureCaptcha.m
//  G100
//
//  Created by sunjingjing on 16/8/19.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "PictureCaptcha.h"

@implementation PictureCaptcha

-(instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        // MJExtension方法
        self.usage = [[dict objectForKey:@"usage"] integerValue];
        self.input = [dict objectForKey:@"input"];
        self.ID = [dict objectForKey:@"id"];
        self.url = [dict objectForKey:@"url"];
        self.session_id = [dict objectForKey:@"session_id"];
    }
    
    return self;
}
@end

//
//  G100AccountDomain.m
//  G100
//
//  Created by Tilink on 15/5/11.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100AccountDomain.h"

@implementation FuncSample


@end

@implementation UserAppFunction


@end

@implementation UserAppWaterMarking


@end

@implementation G100AccountDomain


+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{ @"appfunc" : @"app_func",
              @"appwatermarking" : @"app_watermark"};
}

-(void)setAppfunc:(NSArray *)appfunc {
    if (!_appfunction) {
        self.appfunction = [[UserAppFunction alloc]init];
    }
    
    // 使用MJExtension遍历所有属性
    __weak G100AccountDomain *wself = self;
    [UserAppFunction mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
        NSString * objStr = property.name;
        NSDictionary * func = [wself findFuncKey_ValueWithKey:objStr inDictArray:appfunc];
        if (func) {
            FuncSample * funcSample = [[FuncSample alloc]initWithDictionary:func];
            [_appfunction setValue:funcSample forKey:objStr];
        }else {
            FuncSample * funcSample = [[FuncSample alloc]init];
            funcSample.enable = YES;
            [_appfunction setValue:funcSample forKey:objStr];
        }
    }];
}

-(UserAppFunction *)appfunction {
    if (!_appfunction) {
        self.appfunction = [[UserAppFunction alloc]init];
        
        // 使用MJExtension遍历所有属性
        [UserAppFunction mj_enumerateProperties:^(MJProperty *property, BOOL *stop) {
            NSString * objStr = property.name;
            
            FuncSample * funcSample = [[FuncSample alloc]init];
            funcSample.enable = YES;
            [_appfunction setValue:funcSample forKey:objStr];
        }];
    }
    
    return _appfunction;
}

-(NSDictionary *)findFuncKey_ValueWithKey:(NSString *)key inDictArray:(NSArray *)array {
    __block NSDictionary * result = nil;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * tmpkey = obj[@"func"];
        if ([tmpkey isEqualToString:key]) {
            result = (NSDictionary *)obj;
            *stop = YES;
        }
    }];
    
    return result;
}

-(void)setAppwm:(NSDictionary *)appwm {
    if (!_appwatermarking) {
        self.appwatermarking = [[UserAppWaterMarking alloc]init];
    }
    
    [_appwatermarking setValuesForKeysWith_MyDict:appwm];
}

-(UserAppWaterMarking *)appwatermarking {
    if (!_appwatermarking) {
        self.appwatermarking = [[UserAppWaterMarking alloc]init];
        self.appwatermarking.type = 0;
    }
    
    return _appwatermarking;
}

- (NSInteger)userid {
    return self.user_info.user_id;
}

@end

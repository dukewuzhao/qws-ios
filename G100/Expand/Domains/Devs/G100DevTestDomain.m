//
//  G100DevTestDomain.m
//  G100
//
//  Created by Tilink on 15/5/10.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100DevTestDomain.h"

@implementation G100DevTestDomain

@end

@implementation G100DevTestResultDomain

- (void)setSecurity_scores:(NSArray<G100DevTestDomain *> *)security_scores {
    if (NOT_NULL(security_scores)) {
        _security_scores = [security_scores mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100DevTestDomain alloc] initWithDictionary:item];
            }else if(INSTANCE_OF(item, G100DevTestDomain)){
                return item;
            }
            return nil;
        }];
    }
}

- (void)setScore_ranges:(NSArray<G100DevTestDisplayDomain *> *)score_ranges {
    if (NOT_NULL(score_ranges)) {
        _score_ranges = [score_ranges mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100DevTestDisplayDomain alloc] initWithDictionary:item];
            }else if(INSTANCE_OF(item, G100DevTestDisplayDomain)){
                return item;
            }
            return nil;
        }];
    }
}

- (NSString *)displayTextWithScore:(NSInteger)score {
    if (!self.score_ranges.count) {
        NSString * result = @"当前状态很危险，请尽快修复";
        if (score < 60) {
            result = @"成绩不是很理想，还需要继续努力优化哦";
        }else if (score < 80){
            result = @"成绩一般，打败了60%的用户";
        }else {
            result = @"成绩不错，打败了80%的用户";
        }
        
        return result;
    }
    
    // 存在服务器配置文案的话 则使用服务器分数区间对应的文案
    for (G100DevTestDisplayDomain *domain in self.score_ranges) {
        NSArray *ranges = [domain.range componentsSeparatedByString:@","];
        NSInteger pre = [[ranges safe_objectAtIndex:0] integerValue];
        NSInteger back = [[ranges safe_objectAtIndex:1] integerValue];
        
        if (score >= pre && score <= back) {
            return domain.content;
        }
    }
    
    return @"";
}


@end

@implementation G100DevTestDisplayDomain

@end

@implementation G100DevSecurityScoreSuggestion

- (void)setAction_buttons:(NSArray<G100SecurityActionButtons *> *)action_buttons{
    if (NOT_NULL(action_buttons)) {
        _action_buttons = [action_buttons mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[G100SecurityActionButtons alloc] initWithDictionary:item];
            }else if(INSTANCE_OF(item, G100SecurityActionButtons)){
                return item;
            }
            return nil;
        }];
    }
}

@end

@implementation G100SecurityActionButtons


@end

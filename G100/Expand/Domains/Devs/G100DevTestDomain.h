//
//  G100DevTestDomain.h
//  G100
//
//  Created by Tilink on 15/5/10.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@class G100DevSecurityScoreSuggestion;
@interface G100DevTestDomain : G100BaseDomain

/** 检测详情 */
@property (copy, nonatomic) NSString * checking_desc;
/** 检测操作分数 */
@property (assign, nonatomic) NSInteger deduct;
/** 检测描述 */
@property (copy, nonatomic) NSString * description_pro;
/** 检测项 */
@property (copy, nonatomic) NSString * item;
/** 检测项id */
@property (assign, nonatomic) NSInteger item_id;
/** 检测项类型 */
@property (assign, nonatomic) NSInteger type;
/** 检测项父类 */
@property (assign, nonatomic) NSInteger parent_id;
/** 检测项父类 评分类型，1-安全项 2-优化项*/
@property (assign, nonatomic) NSInteger security_class;
/** 检测建议 */
@property (nonatomic, strong) G100DevSecurityScoreSuggestion *suggestions;

@end

@interface G100SecurityActionButtons : G100BaseDomain

/** action = 1 加分   action = 1 跳转*/
@property (nonatomic, assign) NSInteger action;

/** 分数 */
@property (nonatomic, assign) NSInteger bonus;

/** button的描述 */
@property (nonatomic, strong) NSString *text;

/** 跳转的路径 */
@property (nonatomic, strong) NSString *path;

@end

@interface  G100DevSecurityScoreSuggestion: G100BaseDomain

@property (nonatomic, copy) NSString *description_pro;
@property (nonatomic, copy) NSString *action_button;
@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) NSArray <G100SecurityActionButtons *> *action_buttons;

@end

@class G100DevTestDisplayDomain;
@interface G100DevTestResultDomain : G100BaseDomain

@property (nonatomic, strong) NSArray <G100DevTestDomain *> *security_scores; //!< 评测结果
@property (nonatomic, strong) NSArray <G100DevTestDisplayDomain *> *score_ranges; //!< 评测结果文案

/**
 *  根据当前的分数返回对应区间的文案
 *
 *  @param score 评测结果
 *
 *  @return 对应文案
 */
- (NSString *)displayTextWithScore:(NSInteger)score;

@end

@interface G100DevTestDisplayDomain : G100BaseDomain

@property (nonatomic, copy) NSString *range; //!< 分数区间
@property (nonatomic, copy) NSString *content; //!< 描述文案

@end

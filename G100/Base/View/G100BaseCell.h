//
//  G100BaseCell.h
//  G100
//
//  Created by 温世波 on 15/12/3.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQTextView.h"

typedef void(^G100BaseCellTextFiledChangedBlock)();

@class G100BaseItem;
@interface G100BaseCell : UITableViewCell <UITextFieldDelegate> {
    @public G100BaseItem * _item;
}

/**
 *  箭头
 */
@property (nonatomic, strong) UIImageView *arrowView;
/**
 *  开关
 */
@property (nonatomic, strong) UISwitch *switchView;
/**
 *  标签
 */
@property (nonatomic, strong) UILabel *labelView;
/**
 * 必填项标识
 */
@property (nonatomic, strong) UILabel *requriedView;
/**
 *  右侧品牌图片
 */
@property (nonatomic, strong) UIImageView *rightImageView;
/**
 *  输入框
 */
@property (nonatomic, strong) UITextField *rightTextField;
/**
 *  最大输入字数
 */
@property (nonatomic, assign) NSInteger maxAllowCount;
/**
 *  超过最大输入限制后的提示
 */
@property (nonatomic, copy) NSString *maxHint;

@property (nonatomic, copy) G100BaseCellTextFiledChangedBlock textFieldChanged;

@property (nonatomic, strong) G100BaseItem *item;
@property (nonatomic, assign, getter = isLastRowInSection) BOOL lastRowInSection;

- (void)setItem:(G100BaseItem *)item rightTextfiledBound:(CGRect)rightConentBound;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

+ (instancetype)cellWithTableView:(UITableView *)tableView item:(G100BaseItem *)item;

+ (CGFloat)heightForItem:(G100BaseItem *)item;

+ (NSString *)idForItem:(G100BaseItem *)item;

+ (NSString *)cellID;

+ (void)registerToTabelView:(UITableView *)tableView;

@end

@interface G100BaseContextCell : G100BaseCell

@property (nonatomic, strong) UILabel * contextTitleLabel; //!< 上下文标题
@property (nonatomic, strong) UILabel * contextDetailLabel; //!< 上下文内容

@end

@interface G100BaseContextEditCell : G100BaseCell <UITextViewDelegate>

@property (nonatomic, strong) UILabel * contextTitleLabel; //!< 上下文标题
@property (nonatomic, strong) IQTextView * contextDetailTextView; //!< 上下文内容

@end

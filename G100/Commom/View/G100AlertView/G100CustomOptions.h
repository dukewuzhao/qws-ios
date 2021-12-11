//
//  G100CustomOptions.h
//  G100
//
//  Created by Tilink on 15/3/13.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KSELFHEIGHT 40
@interface G100CustomOptions : UIView

@property (assign, nonatomic) BOOL selected;    // 选中状态 默认未选中
@property (strong, nonatomic) id    object;
/**
 title  message     option
 */
-(void)configOptionWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

/**
        title
 image              option
        message
*/
-(void)configUIWithFrame:(CGRect)frame image:(UIImage *)image Title:(NSString *)title message:(NSString *)message;
@property (weak, nonatomic) IBOutlet UIImageView *leftImageView;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
- (IBAction)selectBtnClick:(UIButton *)sender;

/**
 首页安防等级
 */
@property (weak, nonatomic) IBOutlet UIImageView *rankImageView;
@property (weak, nonatomic) IBOutlet UILabel *rankNameLabel;

-(void)configRankWithFrame:(CGRect)frame image:(NSString *)image Title:(NSString *)title;

@end

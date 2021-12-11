//
//  G100VerificationCodeView.h
//  G100
//
//  Created by William on 16/5/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100UserApi.h"

typedef  enum : NSInteger {
    DisplayStyleDefault = 0,
    DisplayStyleWithBorder
}DisplayStyle;

typedef void (^RefreshVeriCodeBlock)(NSString * sessionid, NSString * picvcName);

@interface G100VerificationCodeView : UIView

@property (strong, nonatomic) IBOutlet UITextField *verCodeTF;

@property (strong, nonatomic) IBOutlet UIImageView *verCodeImageView;

@property (assign, nonatomic) DisplayStyle displayStyle;

- (IBAction)refreshVerCode:(UIButton *)sender;

@property (copy, nonatomic) RefreshVeriCodeBlock refreshVeriCodeBlock;

@property (assign, nonatomic) G100VerificationCodeUsage usageType;

@property (strong, nonatomic) NSString * picvcurl;

/**
 *  刷新验证码
 */
- (void)refreshVericode;
/**
 *  刷新验证码
 *
 *  @param usageType 用途
 */
- (void)refreshVeriCodeWithUsage:(G100VerificationCodeUsage)usageType;

/**
 *  设置用途和验证码url
 *
 *  @param usageType 用途
 *  @param picvcurl  验证码url
 */
- (void)setUsageType:(G100VerificationCodeUsage)usageType picvcurl:(NSString *)picvcurl;

@end

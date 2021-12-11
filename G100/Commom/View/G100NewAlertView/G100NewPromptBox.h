//
//  G100NewPromptBox.h
//  G100
//
//  Created by William on 16/6/3.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100AlertConfirmClickView;
@class G100AlertOtherClickView;
@class G100AlertCancelClickView;

typedef void (^ClickEventBlock)(NSInteger index);

@interface G100NewPromptBox : G100PopBoxBaseView


@property (strong, nonatomic) IBOutlet UIView *boxView;
@property (copy, nonatomic) ClickEventBlock clickEvent;




@end


@interface G100NewPromptDefaultBox : G100NewPromptBox

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@property (strong, nonatomic) IBOutlet G100AlertConfirmClickView *confirmClickView;
@property (strong, nonatomic) IBOutlet G100AlertCancelClickView *cancelClickView;


+ (instancetype)promptAlertViewWithDefaultStyle;

- (void)showPromptBoxWithTitle:(NSString *)title content:(NSString *)content confirmButtonTitle:(NSString *)confirmTitle cancelButtonTitle:(NSString *)cancelTitle event:(ClickEventBlock)clickEvent onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

@end


@interface G100NewPromptSimpleBox : G100NewPromptBox

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) IBOutlet G100AlertConfirmClickView *confirmClickView;

+ (instancetype)promptAlertViewWithSimpleStyle;

- (void)showPromptBoxWithTitle:(NSString *)title Content:(NSString *)content confirmButtonTitle:(NSString *)confirmTitle event:(ClickEventBlock)event onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

@end


@interface G100NewPromptDisplayBox : G100NewPromptBox

@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@property (strong, nonatomic) IBOutlet G100AlertConfirmClickView *confirmClickView;
@property (strong, nonatomic) IBOutlet G100AlertOtherClickView *otherClickView;
@property (strong, nonatomic) IBOutlet G100AlertCancelClickView *cancelClickView;

+ (instancetype)promptAlertViewDisplayStyle;

- (void)showPromptBoxWithConfirmButtonTitle:(NSString *)confirmTitle otherButtonTitle:(NSString *)otherTitle cancelButtonTitle:(NSString *)cancelTitle event:(ClickEventBlock)event onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

@end


@interface G100NewPromptPickBox : G100NewPromptBox

@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *pickButtons;

@property (strong, nonatomic) IBOutlet G100AlertConfirmClickView *confirmClickView;
@property (strong, nonatomic) IBOutlet G100AlertCancelClickView *cancelClickView;

+ (instancetype)promptAlertViewPickStyle;

- (void)showPromptBoxWithConfirmButtonTitle:(NSString *)confirmTitle cancelButtonTitle:(NSString *)cancelTitle event:(ClickEventBlock)event onViewController:(UIViewController *)viewController onBaseView:(UIView *)baseView;

- (IBAction)pickTestMode:(UIButton *)sender;

@end

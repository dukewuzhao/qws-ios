//
//  G100MenuHeaderView.h
//  G100
//
//  Created by William on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100MenuHeaderView : UIView

@property (copy, nonatomic) NSString *userid;

@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *userPhoneLabel;

@property (strong, nonatomic) IBOutlet UIImageView *headerImageView;

@property (strong, nonatomic) IBOutlet UIImageView *headerBackgroundImageView;

@property (weak, nonatomic) IBOutlet UIButton *user_registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *user_loginBtn;

@property (copy, nonatomic) void (^headerTapClick)();
@property (copy, nonatomic) void (^userActionTap)(NSInteger index);

+ (instancetype)loadMenuHeaderView;

- (CGFloat)heightForWidth:(CGFloat)width;

- (IBAction)menu_userRegister:(UIButton *)sender;
- (IBAction)menu_userLogin:(UIButton *)sender;

@end

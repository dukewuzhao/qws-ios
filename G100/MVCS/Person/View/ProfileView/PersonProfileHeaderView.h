//
//  PersonProfileHeaderView.h
//  G100
//
//  Created by yuhanle on 16/7/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PersonProfileHeaderViewDelegate <NSObject>

@optional
- (void)avatarImageViewDidTapped;

@end
@interface PersonProfileHeaderView : UIView

@property (nonatomic, strong) G100AccountDomain *account;

@property (nonatomic, strong) UIImage *avatarImageData;

@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;

@property (nonatomic, weak) id <PersonProfileHeaderViewDelegate> delegate;

/**
 *  加载xib视图
 *
 *  @return xib视图
 */
+ (instancetype)loadNibXibView;

@end

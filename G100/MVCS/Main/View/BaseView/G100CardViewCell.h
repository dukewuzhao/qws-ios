//
//  G100CardViewCell.h
//  G100
//
//  Created by yuhanle on 16/7/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100CardViewCell : UITableViewCell

@property (nonatomic, strong) UIViewController *cardVc;
@property (nonatomic, strong) UIView *containerView;

- (void)setupShadowView;
- (void)setupRightShadowView;
- (void)refreshShadowView;
- (void)refreshNomalView;

@end

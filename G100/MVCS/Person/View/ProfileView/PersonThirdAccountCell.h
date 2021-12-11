//
//  PersonThirdAccountCell.h
//  G100
//
//  Created by yuhanle on 16/7/26.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonThirdAccountCell : UITableViewCell

@property (nonatomic, strong) UILabel *leftTitleLabel;
/** 承载第三方帐号的logo*/
@property (nonatomic, strong) UIView *thirdImageBaseView;

@property (nonatomic, strong) NSArray *thirdAccountArray;

@end

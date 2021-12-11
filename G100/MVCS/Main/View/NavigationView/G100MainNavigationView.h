//
//  G100MainNavigationView.h
//  G100
//
//  Created by yuhanle on 2016/10/26.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G100RedDotButton.h"

@class G100BikeDomain;
@interface G100MainNavigationView : UIView

@property (weak, nonatomic) IBOutlet G100RedDotButton *menuBtn;
@property (weak, nonatomic) IBOutlet G100RedDotButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *flagImageView;
@property (weak, nonatomic) IBOutlet UIView *indexView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleLabelCenterX;

@property (nonatomic, copy) NSString *navigationTitle;
@property (nonatomic, assign) CGFloat navigationTitleAlpha;
@property (nonatomic, strong) G100BikeDomain *bikeDoamin;

+ (instancetype)loadXibView;

@end

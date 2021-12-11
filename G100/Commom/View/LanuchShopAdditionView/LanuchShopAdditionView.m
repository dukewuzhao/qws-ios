//
//  LanuchShopAdditionView.m
//  G100
//
//  Created by William on 15/12/11.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "LanuchShopAdditionView.h"
#import <UIImageView+WebCache.h>

#define Logo_Height (WIDTH / 414.0) * 88
#define Logo_Width  (WIDTH / 414.0) * 104
#define LSpadding   12
#define LBpadding   20
#define LBottomHeight - (44 / 736.0) * HEIGHT

@interface LanuchShopAdditionView ()

@property (nonatomic, strong) UIImageView *bottomLogoImageView;

@end

@implementation LanuchShopAdditionView

- (instancetype)initWithFrame:(CGRect)frame lanuchImageArray:(NSArray*)imageArray {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self showLogoViewWithImageArray:imageArray];
        [self addBottomLogo];
    }
    return self;
}

-(void)showLogoViewWithImageArray:(NSArray *)imageArray {
    __weak LanuchShopAdditionView *wself = self;
    switch (imageArray.count) {
        case 1:
        {
            UIImageView *imageView = [UIImageView new];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageArray[0]]];
            [self addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.centerY.equalTo(wself).with.offset(-10);
                make.centerX.equalTo(wself);
            }];
        }
            break;
        case 2:
        {
            UIImageView *imageView1 = [UIImageView new];
            UIImageView *imageView2 = [UIImageView new];
            [imageView1 sd_setImageWithURL:[NSURL URLWithString:imageArray[0]]];
            [imageView2 sd_setImageWithURL:[NSURL URLWithString:imageArray[1]]];
            [self addSubview:imageView1];
            [self addSubview:imageView2];
            [imageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.centerY.equalTo(wself.mas_centerY).with.offset(-10);
                make.left.equalTo(wself).with.offset((WIDTH - 2*Logo_Width - LSpadding)/2);
            }];
            [imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.centerY.equalTo(wself.mas_centerY).with.offset(-10);
                make.left.equalTo(imageView1.mas_right).with.offset(LSpadding);
            }];
        }
            break;
        case 3:
        {
            UIImageView *imageView1 = [UIImageView new];
            UIImageView *imageView2 = [UIImageView new];
            UIImageView *imageView3 = [UIImageView new];
            [imageView1 sd_setImageWithURL:[NSURL URLWithString:imageArray[0]]];
            [imageView2 sd_setImageWithURL:[NSURL URLWithString:imageArray[1]]];
            [imageView3 sd_setImageWithURL:[NSURL URLWithString:imageArray[2]]];
            [self addSubview:imageView1];
            [self addSubview:imageView2];
            [self addSubview:imageView3];
            [imageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.centerY.equalTo(wself.mas_centerY).with.offset(-10);
                make.left.equalTo(wself).with.offset((WIDTH - 3*Logo_Width - 2*LSpadding)/2);
            }];
            [imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.centerY.equalTo(wself.mas_centerY).with.offset(-10);
                make.left.equalTo(imageView1.mas_right).with.offset(LSpadding);
            }];
            [imageView3 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.centerY.equalTo(wself.mas_centerY).with.offset(-10);
                make.left.equalTo(imageView2.mas_right).with.offset(LSpadding);
            }];
            
        }
            break;
        case 4:
        {
            UIImageView *imageView1 = [UIImageView new];
            UIImageView *imageView2 = [UIImageView new];
            UIImageView *imageView3 = [UIImageView new];
            UIImageView *imageView4 = [UIImageView new];
            [imageView1 sd_setImageWithURL:[NSURL URLWithString:imageArray[0]]];
            [imageView2 sd_setImageWithURL:[NSURL URLWithString:imageArray[1]]];
            [imageView3 sd_setImageWithURL:[NSURL URLWithString:imageArray[2]]];
            [imageView4 sd_setImageWithURL:[NSURL URLWithString:imageArray[3]]];
            [self addSubview:imageView1];
            [self addSubview:imageView2];
            [self addSubview:imageView3];
            [self addSubview:imageView4];
            [imageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.bottom.equalTo(wself.mas_centerY).with.offset(-LBpadding);
                make.left.equalTo(wself).with.offset((WIDTH - 2*Logo_Width - LBpadding)/2);
            }];
            [imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.bottom.equalTo(wself.mas_centerY).with.offset(-LBpadding);
                make.left.equalTo(imageView1.mas_right).with.offset(LBpadding);
            }];
            [imageView3 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.top.equalTo(wself.mas_centerY);
                make.left.equalTo(wself).with.offset((WIDTH - 2*Logo_Width - LBpadding)/2);
            }];
            [imageView4 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.top.equalTo(wself.mas_centerY);
                make.left.equalTo(imageView3.mas_right).with.offset(LBpadding);
            }];
            
        }
            break;
        case 5:
        {
            UIImageView *imageView1 = [UIImageView new];
            UIImageView *imageView2 = [UIImageView new];
            UIImageView *imageView3 = [UIImageView new];
            UIImageView *imageView4 = [UIImageView new];
            UIImageView *imageView5 = [UIImageView new];
            [imageView1 sd_setImageWithURL:[NSURL URLWithString:imageArray[0]]];
            [imageView2 sd_setImageWithURL:[NSURL URLWithString:imageArray[1]]];
            [imageView3 sd_setImageWithURL:[NSURL URLWithString:imageArray[2]]];
            [imageView4 sd_setImageWithURL:[NSURL URLWithString:imageArray[3]]];
            [imageView5 sd_setImageWithURL:[NSURL URLWithString:imageArray[4]]];
            [self addSubview:imageView1];
            [self addSubview:imageView2];
            [self addSubview:imageView3];
            [self addSubview:imageView4];
            [self addSubview:imageView5];
            [imageView1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.bottom.equalTo(wself.mas_centerY).with.offset(-LSpadding);
                make.left.equalTo(wself).with.offset((WIDTH - 3*Logo_Width - 2*LSpadding)/2);
            }];
            [imageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.bottom.equalTo(wself.mas_centerY).with.offset(-LSpadding);
                make.left.equalTo(imageView1.mas_right).with.offset(LSpadding);
            }];
            [imageView3 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.bottom.equalTo(wself.mas_centerY).with.offset(-LSpadding);
                make.left.equalTo(imageView2.mas_right).with.offset(LSpadding);
            }];
            [imageView4 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.top.equalTo(wself.mas_centerY);
                make.left.equalTo(wself).with.offset((WIDTH - 2*Logo_Width - LBpadding)/2);
            }];
            [imageView5 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(Logo_Width, Logo_Height));
                make.top.equalTo(wself.mas_centerY);
                make.left.equalTo(imageView4.mas_right).with.offset(LBpadding);
            }];
        }
            break;
        default:
            break;
    }
}

- (void)addBottomLogo {
    if (!self.bottomLogoImageView) {
        UIImageView *bottomLogo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo_union"]];
        bottomLogo.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:bottomLogo];
        [bottomLogo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(LBottomHeight);
            make.leading.and.trailing.equalTo(@0);
            make.height.equalTo(@13);
        }];
    }
}

@end

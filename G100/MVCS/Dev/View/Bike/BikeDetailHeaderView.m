//
//  BikeDetailHeaderView.m
//  G100
//
//  Created by yuhanle on 16/8/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "BikeDetailHeaderView.h"
#import <UIImageView+WebCache.h>

@interface BikeDetailHeaderView ()<UIGestureRecognizerDelegate,SDWebImageManagerDelegate>
@property (weak, nonatomic) IBOutlet UIView *noUserGrayView;
@property (weak, nonatomic) IBOutlet UIImageView *defaultImageView;

@property (weak, nonatomic) IBOutlet UIImageView *bikeHeadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backMengHeiView;
@property (weak, nonatomic) IBOutlet UILabel *currentUserLabel;
@property (weak, nonatomic) IBOutlet UIButton *qrcodeBtn;

@property (weak, nonatomic) IBOutlet UILabel *bikeNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *bikeLogoImageView;

@property (weak, nonatomic) IBOutlet UIButton *ic_backButton;
@property (weak, nonatomic) IBOutlet UIView *tapView;

@end

@implementation BikeDetailHeaderView

+ (instancetype)loadViewFromNib {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                          owner:self
                                        options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tapGesutre = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(bikeHeaderViewTapAction:)];
    [self.tapView addGestureRecognizer:tapGesutre];
    
    self.noUserGrayView.backgroundColor = [UIColor colorWithHexString:@"#868686"];
}

- (void)setBikeDomain:(G100BikeDomain *)bikeDomain {
    _bikeDomain = bikeDomain;
    //设置车辆名称
    self.bikeNameLabel.text = bikeDomain.name;
    
    //主用户显示 logo 图标, 副用户不显示
    if (bikeDomain.isMaster) {
        self.bikeLogoImageView.alpha = 1.f;
    }else{
        self.bikeLogoImageView.alpha = 0.f;
    }
    
    G100BikeFeatureDomain *feature = bikeDomain.feature;
    NSString *imageUrl = feature.cover_picture;
    if (imageUrl) {
        [self.bikeHeadImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                self.bikeHeadImageView.alpha = 1.0;
                self.backMengHeiView.alpha = 1.0;
            }else{
                self.bikeHeadImageView.alpha = 0.0;
                self.backMengHeiView.alpha = 0.0;
            }
            
        }];
    }else {
        self.bikeHeadImageView.alpha = 0.0;
        self.backMengHeiView.alpha = 0.0;
    }
  
}

- (void)setCurrentUserName:(NSString *)username {
    self.currentUserLabel.text = [NSString stringWithFormat:@"当前用户：%@", username];
}

- (IBAction)qrcodeBtnClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(bikeDetailHeaderView:qrcodeBtnClick:)]) {
        [self.delegate performSelector:@selector(bikeDetailHeaderView:qrcodeBtnClick:) withObject:self withObject:sender];
    }
}

- (IBAction)icon_backButtonClick:(id)sender {
    if ([_delegate respondsToSelector:@selector(bikeDetailHeaderView:icon_backButtonClick:)]) {
        [self.delegate performSelector:@selector(bikeDetailHeaderView:icon_backButtonClick:) withObject:self withObject:sender];
    }
    
}

- (void)bikeHeaderViewTapAction:(UIView *)gestureView{

    if ([_delegate respondsToSelector:@selector(bikeDetailHeaderView:backImageViewTapgesture:)]) {
        [self.delegate performSelector:@selector(bikeDetailHeaderView:backImageViewTapgesture:) withObject:self withObject:gestureView];
    }
}
@end

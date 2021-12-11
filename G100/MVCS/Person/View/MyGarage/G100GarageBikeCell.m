//
//  G100GarageBikeCell.m
//  G100
//
//  Created by yuhanle on 2017/3/14.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100GarageBikeCell.h"
#import <UIImageView+WebCache.h>

#import "G100BikeManager.h"

#import "G100GarageBikeBottomView.h"

@interface G100GarageBikeCell ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (weak, nonatomic) IBOutlet UILabel *bikeNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *master_flag;

@property (weak, nonatomic) IBOutlet G100GarageBikeBottomView *firstView;
@property (weak, nonatomic) IBOutlet G100GarageBikeBottomView *secondView;
@property (weak, nonatomic) IBOutlet G100GarageBikeBottomView *thirdView;
@property (weak, nonatomic) IBOutlet G100GarageBikeBottomView *fourthView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoWidthConstraint;

@property (strong, nonatomic) G100BikeModel *bikeModel;

@end

@implementation G100GarageBikeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBike:(G100BikeDomain *)bike {
    _bike = bike;
    
    NSString *guardDays = [NSString stringWithFormat:@"%@", @(bike.guardDays)];
    NSString *bindDeviceCount = [NSString stringWithFormat:@"%@", @(bike.gps_devices.count)];
    NSString *bikeFeatureIntegrity = [NSString stringWithFormat:@"%@", @(bike.feature.integrity)];
    NSString *bindUserCount = [NSString stringWithFormat:@"%@", @(bike.user_count)];
    
    [self.firstView setResultWithResult:bindDeviceCount unit:@"台" desc:@"绑定设备"];
    [self.secondView setResultWithResult:bindUserCount unit:@"人" desc:@"绑定用户"];
    [self.thirdView setResultWithResult:bikeFeatureIntegrity unit:@"%" desc:@"特征信息"];
    [self.fourthView setResultWithResult:guardDays unit:@"天" desc:@"安全守护"];
    
    self.bikeNameLabel.text = bike.name;
    if ([_bike isMOTOBike]) {
        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:bike.feature.cover_picture] placeholderImage:[UIImage imageNamed:@"icon_motor"]];
    }else{
        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:bike.feature.cover_picture] placeholderImage:[UIImage imageNamed:@"ic_bike_defaultnew"]];
    }
    
    G100BikeManager *bikeManager = [[G100BikeManager alloc] init];
    
    [bikeManager getBikeModelWithData:bike compete:^(G100BikeModel *bikeModel) {
        self.bikeModel = bikeModel;
    }];
    
    self.master_flag.hidden = !bike.isMaster;
}

- (void)setBikeModel:(G100BikeModel *)bikeModel {
    _bikeModel = bikeModel;
    [self updateBikeUI];
}

- (void)updateBikeUI {
    if (_bikeModel.car_logo) {
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_bikeModel.car_logo] options:SDWebImageHighPriority progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (image) {
                    self.logoWidthConstraint.constant = [self fitsize:image.size].width;
                    self.brandImageView.image = image;
                } else {
                    UIImage *defauleImage = [UIImage imageNamed:@"g100_main_left_logo"];
                    self.logoWidthConstraint.constant = [self fitsize:defauleImage.size].width;
                    self.brandImageView.image = defauleImage;
                }
            });
        }];
    } else {
        UIImage *image = [UIImage imageNamed:@"g100_main_left_logo"];
        self.logoWidthConstraint.constant = [self fitsize:image.size].width;
        self.brandImageView.image = image;
    }
}

- (CGSize)fitsize:(CGSize)thisSize {
    if(thisSize.width == 0 && thisSize.height ==0)
        return CGSizeMake(0, 0);
    CGFloat hscale = thisSize.height/36.0;
    CGSize newSize = CGSizeMake(thisSize.width/hscale, thisSize.height/hscale);
    return newSize;
}

@end

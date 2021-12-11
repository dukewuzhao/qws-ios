//
//  G100DiscoveryShopDetailCell.m
//  G100
//
//  Created by 天奕 on 15/12/28.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100DiscoveryShopDetailCell.h"
#import "LYPhotoBrowser.h"
#import <UIImageView+WebCache.h>

@interface G100DiscoveryShopDetailCell ()

@property (strong, nonatomic) NSArray *imageDataArray;

@property (weak, nonatomic) IBOutlet UILabel *imageCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shopTypeViewConstraintW;

- (IBAction)buttonClick:(UIButton *)sender;

@end

@implementation G100DiscoveryShopDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellDataWithModel:(G100ShopPlaceDomain*)model {
    
    self.placeDomain = model;
    self.shopNameLabel.text = model.name;
    self.shopAddressLabel.text = model.address;
    self.shopPhoneNumLabel.text = [NSString stringWithFormat:@"联系电话：%@",model.phone_num];
    if (model.distance < 1000) {
        self.distanceLabel.text = [NSString stringWithFormat:@"%@m",@(model.distance)];
    }else{
        self.distanceLabel.text = [NSString stringWithFormat:@"%.1lfkm",model.distance/1000.0];
    }
    
    if (model.picture.count) {
        self.imageCountLabel.hidden = NO;
        self.imageCountLabel.text = [NSString stringWithFormat:@"%@图", @(model.picture.count)];
    }else {
        self.imageCountLabel.hidden = YES;
    }

    [self.shopImageView sd_setImageWithURL:[NSURL URLWithString:model.picture[0]] placeholderImage:[UIImage imageNamed:@"ic_store"]];
    if (!_imageDataArray) {
        _imageDataArray = model.picture;
    }
    [self addShopTypeTipsWithType:model.type];
}

- (void)addShopTypeTipsWithType:(NSString *)typeStr {
    NSArray *shopType = [typeStr componentsSeparatedByString:@","];
    for (int i = 0; i < shopType.count; i++) {

        UILabel *typeLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*i, 0, 16, 16)];
        
        NSString *type;
        if ([shopType[i] isEqualToString:@"1"]) {
            type = @"修";
            typeLabel.backgroundColor = MyBlueColor;
        }else if ([shopType[i] isEqualToString:@"2"]) {
            type = @"售";
            typeLabel.backgroundColor = MyGreenColor;
        }else if ([shopType[i] isEqualToString:@"3"]) {
            type = @"充";
            typeLabel.backgroundColor = MyYellowColor;
        }else if ([shopType[i] isEqualToString:@"4"]) {
            type = @"P";
            typeLabel.backgroundColor = MyOrangeColor;
        }
        typeLabel.text = type;
        
        typeLabel.textAlignment = NSTextAlignmentCenter;
        typeLabel.textColor = [UIColor whiteColor];
        typeLabel.font = [UIFont boldSystemFontOfSize:10.0f];
        [typeLabel.layer setMasksToBounds:YES];
        [typeLabel.layer setCornerRadius:3.0];
        [self.shopTypeView addSubview:typeLabel];
    }
    
    self.shopTypeViewConstraintW.constant = 20 * shopType.count;
}

+ (CGFloat)heightForModel:(G100ShopPlaceDomain *)domain {
    
    
    
    
    return 100;
}

- (IBAction)showImage:(id)sender {
    NSMutableArray *photoArrayM = @[].mutableCopy;
    
    for (UIImageView *imageView in self.imageDataArray) {
        NSInteger index = [self.imageDataArray indexOfObject:imageView];
        LYPhoto *photo = nil;
        photo = [LYPhoto photoWithImageView:nil placeHold:nil photoUrl:self.imageDataArray[index]];
        [photoArrayM addObject:photo];
    }
    [LYPhotoBrowser showPhotos:photoArrayM currentPhotoIndex:0 countType:LYPhotoBrowserCountTypePageControl];
}

- (IBAction)buttonClick:(UIButton *)sender {
    
    if (_buttonClick) {
        self.buttonClick(_placeDomain, sender.tag);
    }
    
}

@end

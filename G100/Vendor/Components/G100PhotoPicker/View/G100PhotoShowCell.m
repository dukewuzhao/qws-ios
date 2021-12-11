//
//  G100PhotoShowCell.m
//  PhotoPicker
//
//  Created by William on 16/3/22.
//  Copyright © 2016年 William. All rights reserved.
//

#import "G100PhotoShowCell.h"
#import "G100PhotoShowModel.h"
#import <UIImageView+WebCache.h>
#import <AssetsLibrary/AssetsLibrary.h>

@implementation G100PhotoShowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setImageViewWithModel:(G100PhotoShowModel*)model {
    if (model.data) {
        self.photoImageView.image = [UIImage imageWithData:model.data];
    }else if (model.image) {
        self.photoImageView.image = model.image;
    }else if (model.url) {
        [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:model.url] placeholderImage:[UIImage imageNamed:@""]];
    }else if (model.photoName) {
        self.photoImageView.image = [UIImage imageNamed:model.photoName];
    }else {
        
    }
}

@end

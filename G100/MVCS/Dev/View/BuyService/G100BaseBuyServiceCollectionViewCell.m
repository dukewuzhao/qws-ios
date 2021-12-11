//
//  G100BaseBuyServiceCollectionViewCell.m
//  G100
//
//  Created by 曹晓雨 on 2016/10/24.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import "G100BaseBuyServiceCollectionViewCell.h"

@implementation G100BaseBuyServiceCollectionViewCell

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected) {
        self.layer.borderColor = [UIColor colorWithRed:0 green:0.69 blue:0 alpha:1].CGColor;
        self.layer.borderWidth = 2;
    }
    else
    {
        self.layer.borderColor = [UIColor colorWithRed:0.63 green:0.63 blue:0.63 alpha:1.00].CGColor;
        self.layer.borderWidth = 0.5;
    }
}

- (void)setLayer
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 7;
    self.layer.borderColor = [UIColor colorWithRed:0.63 green:0.63 blue:0.63 alpha:1.00].CGColor;
    self.layer.borderWidth = 0.5;
}

@end

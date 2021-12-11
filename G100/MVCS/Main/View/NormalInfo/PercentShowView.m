//
//  PercentShowView.m
//  G100
//
//  Created by sunjingjing on 16/7/7.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "PercentShowView.h"

@interface PercentShowView ()

@property (weak, nonatomic) IBOutlet UIImageView *hunImageView;
@property (weak, nonatomic) IBOutlet UIImageView *tenImageView;

@property (weak, nonatomic) IBOutlet UIImageView *perImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hunWidConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tenWidConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *perWidConstraint;

@end

@implementation PercentShowView

+ (instancetype)showView
{
    
    PercentShowView *showView = [[[NSBundle mainBundle] loadNibNamed:@"PercentShowView" owner:nil options:nil] firstObject];
    return showView;
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setPercentAnimateWithPercent:self.percent];
    
}

- (void)setPercentAnimateWithPercent:(NSInteger)percent
{
    
    if (percent<10 && percent >=0) {
        
        self.hunWidConstraint.constant = 0;
        self.tenWidConstraint.constant = 0;
        if (percent == 1) {
            self.perWidConstraint.constant = 14;
        }else
        {
            self.perWidConstraint.constant = 23;
        }

        NSString *imageNamePer = [NSString stringWithFormat:@"ic_big%ld",(long)percent];
        self.perImageView.image = [UIImage imageNamed:imageNamePer];
        
    }else if(percent < 0)
        
    {
        self.hunWidConstraint.constant = 0;
        self.tenWidConstraint.constant = 20;
        self.perWidConstraint.constant = 20;
        self.tenImageView.image = [UIImage imageNamed:@"icon_wea_-0"];
        self.perImageView.image = [UIImage imageNamed:@"icon_wea_-0"];
    }else if(percent >99)
        
    {
        self.hunWidConstraint.constant = 14;
        self.tenWidConstraint.constant = 20;
        self.perWidConstraint.constant = 20;
        self.hunImageView.image = [UIImage imageNamed:@"ic_big1"];
        self.tenImageView.image = [UIImage imageNamed:@"ic_big0"];
        self.perImageView.image = [UIImage imageNamed:@"ic_big0"];
    }else
    {
        NSInteger ten = percent/10;
        NSInteger per = percent%10;
        self.hunWidConstraint.constant = 0;
        if (ten == 1) {
            self.tenWidConstraint.constant = 14;
        }else
        {
            self.tenWidConstraint.constant = 20;
        }
        
        if (per == 1) {
            self.perWidConstraint.constant = 14;
        }else
        {
            self.perWidConstraint.constant = 20;
        }
        NSString *imageNameTen = [NSString stringWithFormat:@"ic_big%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_big%ld",(long)per];
        self.tenImageView.image = [UIImage imageNamed:imageNameTen];
        self.perImageView.image = [UIImage imageNamed:imageNamePer];
    }
    
}

@end

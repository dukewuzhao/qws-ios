//
//  G100MainNavigationView.m
//  G100
//
//  Created by yuhanle on 2016/10/26.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MainNavigationView.h"
#import "G100BikeDomain.h"

@implementation G100MainNavigationView

+ (instancetype)loadXibView {
    G100MainNavigationView *xibView = [[[NSBundle mainBundle] loadNibNamed:@"G100MainNavigationView" owner:self options:nil] lastObject];
    [xibView setBikeDoamin:nil];
    return xibView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.menuBtn setImage:[UIImage imageNamed:@"ic_menu_up"] forState:UIControlStateNormal];
    [self.menuBtn setImage:[UIImage imageNamed:@"ic_menu_down"] forState:UIControlStateHighlighted];
    
    [self.addBtn setImage:[UIImage imageNamed:@"ic_addbike_up"] forState:UIControlStateNormal];
    [self.addBtn setImage:[UIImage imageNamed:@"ic_addbike_down"] forState:UIControlStateHighlighted];
}

- (void)setNavigationTitle:(NSString *)navigationTitle {
    _navigationTitle = navigationTitle;
    
    self.nameLabel.text = navigationTitle;
}

- (void)setNavigationTitleAlpha:(CGFloat)navigationTitleAlpha {
    self.nameLabel.alpha = navigationTitleAlpha;
    self.flagImageView.alpha = navigationTitleAlpha;
}

- (void)setBikeDoamin:(G100BikeDomain *)bikeDoamin {
    _bikeDoamin = bikeDoamin;
    
    self.flagImageView.hidden = !bikeDoamin.isMaster;
    
    if (self.flagImageView.hidden) {
        self.titleLabelCenterX.constant = 0;
    }else {
        self.titleLabelCenterX.constant = -12.5;
    }
}

@end

//
//  G100InsuranceActivity.m
//  G100
//
//  Created by sunjingjing on 16/12/7.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100InsuranceActivity.h"
#import "G100InsuranceManager.h"
@interface G100InsuranceActivity ()



@end

@implementation G100InsuranceActivity

+ (float)heightWithWidth:(float)width{
    //return 0;
    return width * 12/27;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

-(void)setInsuranceCardModel:(G100InsuranceCardModel *)insuranceCardModel{
    _insuranceCardModel = insuranceCardModel;
    [self updateUI];
}

- (void)setupView{
    
    _imageScrollView = [G100ScrollView createScrollViewWithFrame:self.bounds imagesArr:nil];
    [self addSubview:_imageScrollView];
    
    [_imageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    _expireButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _expireButton.layer.cornerRadius = 8.0f;
    _expireButton.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.4];
    _expireButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [_expireButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_expireButton setTitleColor:[UIColor colorWithHexString:@"EDECEE"] forState:UIControlStateHighlighted];
    _expireButton.contentEdgeInsets = UIEdgeInsetsMake(2, 6, 2, 6);
    [_expireButton setTitle:@"您有1份保险将过期" forState:UIControlStateNormal];
    [_expireButton addTarget:self action:@selector(expireInsuranceClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_expireButton];
    [_expireButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@8);
        make.leading.equalTo(@8);
        make.width.equalTo(@120);
        make.height.equalTo(@20);
    }];
}

- (void)updateUI{
    if (self.insuranceCardModel.prompt.desc.length > 0) {
        [self.expireButton setTitle:self.insuranceCardModel.prompt.desc forState:UIControlStateNormal];
        self.expireButton.hidden = NO;
    }else{
        self.expireButton.hidden = YES;
    }
    NSMutableArray *imageUrls = [NSMutableArray array];
    for (G100InsuranceActivityDomain *activityDomain in self.insuranceCardModel.activityList) {
        if (activityDomain.picture.length) {
            [imageUrls addObject:activityDomain.picture];
        }else{
             [imageUrls addObject:@"insurance_ad_default"];
        }
    }
    if (imageUrls.count > 0) {
        self.imageScrollView.imageUrlArr = imageUrls;
    }
}

- (void)expireInsuranceClicked:(UIButton *)button{
    if (self.expireButtonTaped) {
        self.expireButtonTaped();
    }
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _imageScrollView.frame = self.bounds;
}
@end

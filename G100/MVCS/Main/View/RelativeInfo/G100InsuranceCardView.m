//
//  G100InsuranceCardView.m
//  G100
//
//  Created by sunjingjing on 16/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100InsuranceCardView.h"
#import "G100InsuranceManager.h"
@interface G100InsuranceCardView ()

@property (weak, nonatomic) IBOutlet UILabel *insuranceTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *insuranceDetailLable;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UILabel *actionTitle;

@end

@implementation G100InsuranceCardView

+ (instancetype)showView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100InsuranceCardView" owner:nil options:nil] firstObject];
}

+ (float)heightWithWidth:(float)width{
    //return 0;
    return width * 30/207;
}

-(void)awakeFromNib{
    [super awakeFromNib];
}

- (void)setInsuranceBanner:(G100InsuranceBanner *)insuranceBanner{
    _insuranceBanner = insuranceBanner;
    [self updateUI];
}

- (void)updateUI{
    self.insuranceTitleLabel.text = self.insuranceBanner.title;
    self.insuranceDetailLable.text = self.insuranceBanner.brief;
    self.actionTitle.text = self.insuranceBanner.button.text;
}
//领取保险
- (IBAction)getInsurance:(id)sender {
    if ([self.delegate respondsToSelector:@selector(viewTapedToPushDetail:)]) {
        [self.delegate viewTapedToPushDetail:self];
    }
}
@end

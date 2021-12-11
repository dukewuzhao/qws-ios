//
//  G100BattInfoView.m
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BattInfoView2.h"


@interface G100BattInfoView2 ()
@property (weak, nonatomic) IBOutlet UILabel *eleDoorDesc;
@property (weak, nonatomic) IBOutlet UILabel *eleDoorState;

@property (weak, nonatomic) IBOutlet UIImageView *eleDoorImageView;
@property (weak, nonatomic) IBOutlet UILabel *driveDescLabel;

@property (weak, nonatomic) IBOutlet UIImageView *driveHunImageView;
@property (weak, nonatomic) IBOutlet UIImageView *driveTenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *drivePerImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drivePerWidBigConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drivePerWidSmallConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *driveTenWidBigConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *driveTenWidSmallConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *battBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *battImageView;
@property (weak, nonatomic) IBOutlet UILabel *nobattLabel;


@end

@implementation G100BattInfoView2

+ (instancetype)showView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100BattInfoView" owner:nil options:nil] firstObject];
}

+ (CGFloat)heightWithWidth:(CGFloat)width{
    return 30*width/197;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.driveHunImageView.image = [[UIImage imageNamed:@"ic_num_1"] imageWithTintColor:[UIColor blackColor]];
    self.driveTenImageView.image = [[UIImage imageNamed:@"ic_num_0"] imageWithTintColor:[UIColor blackColor]];
    self.drivePerImageView.image = [[UIImage imageNamed:@"ic_num_0"] imageWithTintColor:[UIColor blackColor]];
}
-(void)setBikeModel:(G100BikeModel *)bikeModel{
    _bikeModel = bikeModel;
}
- (void)updateBattDataUI{
    [self updateEleDoorStateWithisOpen:_bikeModel.eleDoorState];
    NSString *eleImageName = [NSString stringWithFormat:@"ic_batt_%ld",_bikeModel.soc/10];
    self.battImageView.image = [UIImage imageNamed:eleImageName];
    self.battBgImageView.image = [UIImage imageNamed:@"ic_card_right_normal"];
    self.battImageView.hidden = NO;
    if (_bikeModel.soc <= 10 && _bikeModel.soc >0) {
        self.battBgImageView.image = [UIImage imageNamed:@"ic_card_right_main"];
        self.nobattLabel.hidden = YES;
    }else if(_bikeModel.soc == 0){
        self.battImageView.hidden = YES;
        self.nobattLabel.hidden = NO;
        self.nobattLabel.text = @"电量无法计算";
    }else if(_bikeModel.soc < 0){
        self.battImageView.hidden = YES;
        self.nobattLabel.hidden = NO;
        self.nobattLabel.text = @"未检测到电池";
    }else
    {
        self.nobattLabel.hidden = YES;
    }
    [self setMilesUIWithMile:(NSInteger)_bikeModel.expecteddistance];
}

-(void)updateEleDoorStateWithisOpen:(BOOL)isOpen
{
    if (isOpen) {
        
        self.eleDoorImageView.image = [UIImage imageNamed:@"ic_batt_on"];
        self.eleDoorState.text = @"已打开";
    }else
    {
        self.eleDoorImageView.image = [UIImage imageNamed:@"ic_batt_off"];
        self.eleDoorState.text = @"已关闭";
    }
}
- (void)setMilesUIWithMile:(NSInteger)mile
{
    if (mile<10 && mile >0) {
        
        self.driveHunImageView.hidden = YES;
        self.driveTenImageView.hidden = YES;
        self.drivePerImageView.hidden = NO;
        if (mile == 1) {
            self.drivePerWidBigConstraint.priority = 700;
            self.drivePerWidSmallConstraint.priority = 999;
        }else
        {
            self.drivePerWidSmallConstraint.priority = 700;
            self.drivePerWidBigConstraint.priority = 999;
        }
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_num_%ld",(long)mile];
        self.drivePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
        
    }else if (mile <= 0)
    {
        self.driveHunImageView.hidden = YES;
        self.driveTenImageView.hidden = YES;
        self.drivePerImageView.hidden = NO;
        self.drivePerImageView.image = [[UIImage imageNamed:@"ic_num_0"] imageWithTintColor:[UIColor blackColor]];
    }else if(mile >99)
        
    {
        self.driveHunImageView.hidden = NO;
        self.driveTenImageView.hidden = NO;
        self.drivePerImageView.hidden = NO;
        self.drivePerWidSmallConstraint.priority = 700;
        self.drivePerWidBigConstraint.priority = 999;
        self.driveTenWidSmallConstraint.priority = 700;
        self.driveTenWidBigConstraint.priority = 999;
        self.driveHunImageView.image = [[UIImage imageNamed:@"ic_num_1"] imageWithTintColor:[UIColor blackColor]];
        self.driveTenImageView.image = [[UIImage imageNamed:@"ic_num_0"] imageWithTintColor:[UIColor blackColor]];
        self.drivePerImageView.image = [[UIImage imageNamed:@"ic_num_0"] imageWithTintColor:[UIColor blackColor]];
    }else
    {
        NSInteger ten = mile/10;
        NSInteger per = mile%10;
        self.driveHunImageView.hidden = YES;
        self.driveTenImageView.hidden = NO;
        self.drivePerImageView.hidden = NO;
        if (ten == 1) {
            self.driveTenWidBigConstraint.priority = 700;
            self.driveTenWidSmallConstraint.priority = 999;
        }else
        {
            self.driveTenWidSmallConstraint.priority = 700;
            self.driveTenWidBigConstraint.priority = 999;
        }
        if (per == 1) {
            self.drivePerWidBigConstraint.priority = 700;
            self.drivePerWidSmallConstraint.priority = 999;
        }else
        {
            self.drivePerWidSmallConstraint.priority = 700;
            self.drivePerWidBigConstraint.priority = 999;
        }
        NSString *imageNameTen = [NSString stringWithFormat:@"ic_num_%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"ic_num_%ld",(long)per];
        self.driveTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor blackColor]];
        self.drivePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
    }
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];
}

@end

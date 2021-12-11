//
//  G100BattInfoView.m
//  G100
//
//  Created by sunjingjing on 16/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BattInfoView.h"

@interface G100BattInfoView ()
@property (weak, nonatomic) IBOutlet UILabel *eleDoorDesc;
@property (weak, nonatomic) IBOutlet UILabel *eleDoorState;

@property (weak, nonatomic) IBOutlet UIImageView *eleDoorImageView;
@property (weak, nonatomic) IBOutlet UILabel *driveDescLabel;

@property (weak, nonatomic) IBOutlet UIImageView *driveHunImageView;
@property (weak, nonatomic) IBOutlet UIImageView *driveTenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *drivePerImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drivePerWidBigConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drivePerLeadConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *driveTenLeadConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *driveTenWidBigConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *driveDotImageView;

@property (weak, nonatomic) IBOutlet UIImageView *battBgImageView;
@property (weak, nonatomic) IBOutlet UIImageView *battImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *driveDotSmallConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *driveDotBigConstraint;
@property (weak, nonatomic) IBOutlet UILabel *driveNull;
@property (weak, nonatomic) IBOutlet UIImageView *driveUnit;
@property (weak, nonatomic) IBOutlet UIButton *noBattButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *driveImageHeightBigConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *driveImageHeightSmallConstraint;

@end

@implementation G100BattInfoView

+ (instancetype)showView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100BattInfoView" owner:nil options:nil] firstObject];
}

+ (CGFloat)heightWithWidth:(CGFloat)width{
    return 30*width/197;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.driveDotImageView.image = [[UIImage imageNamed:@"ic_batt_dot"] imageWithTintColor:[UIColor blackColor]];
    self.driveNull.hidden = NO;
    if (ISIPHONE_4 || ISIPHONE_5) {
        self.noBattButton.titleLabel.font = [UIFont boldSystemFontOfSize:11];
       // self.nobattLabel.font = [UIFont boldSystemFontOfSize:11];
        self.driveNull.font = [UIFont boldSystemFontOfSize:11];
        self.eleDoorState.font = [UIFont boldSystemFontOfSize:11];
        self.eleDoorDesc.font = [UIFont boldSystemFontOfSize:11];
        self.driveDescLabel.font = [UIFont boldSystemFontOfSize:11];
        self.driveImageHeightBigConstraint.priority = 700;
        self.driveImageHeightSmallConstraint.priority = 999;
    }else{
        self.driveImageHeightSmallConstraint.priority = 700;
        self.driveImageHeightBigConstraint.priority = 999;
    }
    CGFloat imgWidth = self.noBattButton.imageView.bounds.size.width;
    CGFloat labWidth = self.noBattButton.titleLabel.bounds.size.width;
    [self.noBattButton setImageEdgeInsets:UIEdgeInsetsMake(0, labWidth, 0, -labWidth)];
    [self.noBattButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -imgWidth, 0, imgWidth)];
}
-(void)setBikeModel:(G100BikeModel *)bikeModel{
    _bikeModel = bikeModel;
}
- (void)updateBattDataUI{
    if (!self.bikeModel) {
        return;
    }
//    _bikeModel.soc = @"20";
//    _bikeModel.expecteddistance = [NSString stringWithFormat:@"%f",(float)(arc4random() % 200)];
    [self updateEleDoorStateWithisOpen:_bikeModel.eleDoorState];
    NSString *eleImageName = [NSString stringWithFormat:@"ic_batt_%ld",_bikeModel.soc/10];
    self.battImageView.image = [UIImage imageNamed:eleImageName];
    self.battBgImageView.image = [UIImage imageNamed:@"ic_card_normalnew"];
    self.battImageView.hidden = NO;
    self.driveNull.hidden = YES;
    self.driveUnit.hidden = NO;
    if (_bikeModel.soc <= 10 && _bikeModel.soc >=0) {
        self.battBgImageView.image = [UIImage imageNamed:@"ic_card_import"];
        //self.nobattLabel.hidden = YES;
        self.noBattButton.hidden = YES;
    }else if(_bikeModel.soc == -100){
        self.battImageView.hidden = YES;
        //self.nobattLabel.hidden = NO;
        self.noBattButton.hidden = NO;
        [self.noBattButton setTitle:@"未检测到电池" forState:UIControlStateNormal];
        [self.noBattButton setImage:nil forState:UIControlStateNormal];
        self.noBattButton.userInteractionEnabled = NO;
        //self.nobattLabel.text = @"未检测到电池";
        
        [self.noBattButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }else if(_bikeModel.soc == -200){
        self.battImageView.hidden = YES;
       // self.nobattLabel.hidden = NO;
        self.noBattButton.hidden = NO;
        [self.noBattButton setTitle:@"电量无法计算" forState:UIControlStateNormal];
        [self.noBattButton setImage:[UIImage imageNamed:@"ic_batt_help"] forState:UIControlStateNormal];
        self.noBattButton.userInteractionEnabled = YES;
       // self.nobattLabel.text = @"电量无法计算";
        
        CGFloat imgWidth = self.noBattButton.imageView.bounds.size.width;
        CGFloat labWidth = self.noBattButton.titleLabel.bounds.size.width;
        [self.noBattButton setImageEdgeInsets:UIEdgeInsetsMake(0, labWidth, 0, -labWidth)];
        [self.noBattButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -imgWidth, 0, imgWidth)];
    }else
    {
        self.noBattButton.hidden = YES;
       // self.nobattLabel.hidden = YES;
    }
    [self setMilesUIWithMile:_bikeModel.expecteddistance];
}
- (IBAction)handleNoBatt:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(buttonClickedToPushBattDetail:)]) {
        [self.delegate buttonClickedToPushBattDetail:sender];
    }
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
- (void)setMilesUIWithMile:(CGFloat)mile
{
    if (mile < 0 || _bikeModel.soc < 0) {
        self.driveHunImageView.hidden = YES;
        self.driveTenImageView.hidden = YES;
        self.drivePerImageView.hidden = YES;
        self.driveUnit.hidden = YES;
        self.driveDotImageView.hidden = YES;
        self.driveNull.hidden = NO;
        return;
    }
    NSInteger mileN = (NSInteger)mile;
    CGFloat mileD = mile-mileN;
    NSInteger mileDN = mileD *10;
    if (mileN<10 && mileN >0) {
        
        self.driveHunImageView.hidden = YES;
        self.driveTenImageView.hidden = NO;
        self.drivePerImageView.hidden = NO;
        self.driveDotImageView.hidden = NO;
        self.driveDotSmallConstraint.priority = 700;
        self.driveDotBigConstraint.priority = 999;
        NSInteger dotNum;
        if (mileDN >=0 && mileDN < 5) {
            dotNum = 0;
        }else
        {
            dotNum = 5;
        }
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)mileN];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)dotNum];
        self.driveTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor blackColor]];
        self.drivePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
        
    }else if (mileN == 0)
    {
        if (mileDN ==0 ) {
            self.driveHunImageView.hidden = YES;
            self.driveTenImageView.hidden = YES;
            self.drivePerImageView.hidden = NO;
            self.driveDotImageView.hidden = YES;
            NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec0"];
            self.drivePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
        }else
        {
            self.driveHunImageView.hidden = YES;
            self.driveTenImageView.hidden = NO;
            self.drivePerImageView.hidden = NO;
            self.driveDotImageView.hidden = NO;
            self.driveDotSmallConstraint.priority = 700;
            self.driveDotBigConstraint.priority = 999;
            NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec0"];
            NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec5"];
            self.driveTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor blackColor]];
            self.drivePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
        }
       
    }else if(mileN >99)
        
    {
        NSInteger tenNum = mileN%100;
        NSInteger ten = tenNum/10;
        NSInteger per = tenNum%10;
        self.driveHunImageView.hidden = NO;
        self.driveTenImageView.hidden = NO;
        self.drivePerImageView.hidden = NO;
        self.driveDotImageView.hidden = YES;
        self.driveDotBigConstraint.priority = 700;
        self.driveDotSmallConstraint.priority = 999;
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)per];
        self.driveHunImageView.image = [[UIImage imageNamed:@"icon_elec1"] imageWithTintColor:[UIColor blackColor]];
        self.driveTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor blackColor]];
        self.drivePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
    }else
    {
        NSInteger ten = mileN/10;
        NSInteger per = mileN%10;
        self.driveHunImageView.hidden = YES;
        self.driveTenImageView.hidden = NO;
        self.drivePerImageView.hidden = NO;
        self.driveDotImageView.hidden = YES;
        self.driveUnit.hidden = NO;
        self.driveDotBigConstraint.priority = 700;
        self.driveDotSmallConstraint.priority = 999;
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)per];
        self.driveTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:[UIColor blackColor]];
        self.drivePerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor blackColor]];
    }
}

@end

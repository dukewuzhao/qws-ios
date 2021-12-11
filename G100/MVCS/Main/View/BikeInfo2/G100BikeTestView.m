//
//  G100BikeTestView.m
//  G100
//
//  Created by sunjingjing on 2017/4/17.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeTestView.h"

@interface G100BikeTestView ()
@property (weak, nonatomic) IBOutlet UILabel *testDetailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *testHunImageView;
@property (weak, nonatomic) IBOutlet UIImageView *testTenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *testPerImageView;
@property (weak, nonatomic) IBOutlet UILabel *testUnitImageView;
@property (weak, nonatomic) IBOutlet UIImageView *noTenImageView;
@property (weak, nonatomic) IBOutlet UIImageView *noPerImageView;

@end

@implementation G100BikeTestView

+ (instancetype)showView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100BikeTestView" owner:nil options:nil] firstObject];
}

+ (float)heightWithWidth:(float)width{
    return width * 30/207;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.testHunImageView.image = [[UIImage imageNamed:@"icon_elec1"] imageWithTintColor:[UIColor colorWithHexString:@"00CA99"]];
    self.testTenImageView.image = [[UIImage imageNamed:@"icon_elec0"] imageWithTintColor:[UIColor colorWithHexString:@"00CA99"]];
    self.testPerImageView.image = [[UIImage imageNamed:@"icon_elec0"] imageWithTintColor:[UIColor colorWithHexString:@"00CA99"]];
    self.noPerImageView.image = [[UIImage imageNamed:@"ic_bike_-"] imageWithTintColor:[UIColor colorWithHexString:@"00CA99"]];
    self.noTenImageView.image = [[UIImage imageNamed:@"ic_bike_-"] imageWithTintColor:[UIColor colorWithHexString:@"00CA99"]];
}

-(void)setTestResultDomin:(G100TestResultDomain *)testResultDomin{
    _testResultDomin = testResultDomin;
    [self updateTestResultUI];
}

- (void)updateTestResultUI {
    if (!self.testResultDomin) {
        if (IsLogin()) {
            self.testHunImageView.hidden = YES;
            self.testTenImageView.hidden = YES;
            self.testPerImageView.hidden = YES;
            self.noTenImageView.hidden = NO;
            self.noPerImageView.hidden = NO;
        }
        else {
            self.testHunImageView.hidden = NO;
            self.testTenImageView.hidden = NO;
            self.testPerImageView.hidden = NO;
            self.noTenImageView.hidden = YES;
            self.noPerImageView.hidden = YES;
        }
        self.testDetailLabel.text = @"爱车安全，点击一键检测";
        self.testDetailLabel.textColor = [UIColor colorWithHexString:@"878787"];
        self.testUnitImageView.textColor = [UIColor colorWithHexString:@"00CA99"];
        return;
    }
    
    self.noTenImageView.hidden = YES;
    self.noPerImageView.hidden = YES;
    int days = [NSDate getTimeIntervalDaysFromNowWithDateStr:_testResultDomin.lastTestTime];
    if (days > 0) {
        self.testDetailLabel.text = [NSString stringWithFormat:@"%@/%d天前检测",self.testResultDomin.testResultHint,days];
    }
    else {
        self.testDetailLabel.text = [NSString stringWithFormat:@"%@",self.testResultDomin.testResultHint];
    }
    if (self.testResultDomin.showType == 1) {
        self.testDetailLabel.textColor = [UIColor colorWithHexString:@"FF6600"];
    }
    else {
        self.testDetailLabel.textColor = [UIColor colorWithHexString:@"878787"];
    }
    
    [self updateTestGradeWithGrade:_testResultDomin.score];
}
- (void)updateTestGradeWithGrade:(NSInteger)grade
{
    self.testUnitImageView.textColor = grade > 59 ? [UIColor colorWithHexString:@"00CA99"] : [UIColor colorWithHexString:@"FF6600"];
    if (grade<10 && grade >=0) {
        
        self.testHunImageView.hidden = YES;
        self.testTenImageView.hidden = YES;
        self.testPerImageView.hidden = NO;
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)grade];
        self.testPerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:[UIColor colorWithHexString:@"FF6600"]];
        
    }else if(grade < 0)
    {
        self.testHunImageView.hidden = YES;
        self.testTenImageView.hidden = YES;
        self.testPerImageView.hidden = YES;
        self.testUnitImageView.hidden = YES;
        self.noTenImageView.hidden = NO;
        self.noPerImageView.hidden = NO;
    }else if(grade >99)
    {
        self.testHunImageView.hidden = NO;
        self.testTenImageView.hidden = NO;
        self.testPerImageView.hidden = NO;
        self.testHunImageView.image = [[UIImage imageNamed:@"icon_elec1"] imageWithTintColor:[UIColor colorWithHexString:@"00CA99"]];
        self.testTenImageView.image = [[UIImage imageNamed:@"icon_elec0"] imageWithTintColor:[UIColor colorWithHexString:@"00CA99"]];
        self.testPerImageView.image = [[UIImage imageNamed:@"icon_elec0"] imageWithTintColor:[UIColor colorWithHexString:@"00CA99"]];
    }else
    {
        NSInteger ten = grade/10;
        NSInteger per = grade%10;
        self.testHunImageView.hidden = YES;
        self.testTenImageView.hidden = NO;
        self.testPerImageView.hidden = NO;
        NSString *imageNameTen = [NSString stringWithFormat:@"icon_elec%ld",(long)ten];
        NSString *imageNamePer = [NSString stringWithFormat:@"icon_elec%ld",(long)per];
        
        self.testTenImageView.image = [[UIImage imageNamed:imageNameTen] imageWithTintColor:ten > 5 ? [UIColor colorWithHexString:@"00CA99"] : [UIColor colorWithHexString:@"FF6600"]];
        self.testPerImageView.image = [[UIImage imageNamed:imageNamePer] imageWithTintColor:ten > 5 ? [UIColor colorWithHexString:@"00CA99"] : [UIColor colorWithHexString:@"FF6600"]];
    }
}
- (IBAction)viewTaped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(viewTapToPushTestDetailWithView:)]) {
        [self.delegate viewTapToPushTestDetailWithView:self];
    }
}

@end

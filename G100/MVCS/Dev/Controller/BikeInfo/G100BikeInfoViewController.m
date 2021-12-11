//
//  G100BikeInfoViewController.m
//  G100
//
//  Created by 曹晓雨 on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeInfoViewController.h"

#import "G100DevApi.h"
#import "G100BikeApi.h"
#import "G100BikeDomain.h"

#import "G100BikeEditFeatureViewController.h"

#import "UILabeL+AjustFont.h"

@interface G100BikeInfoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *infoIntegrityLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikePlateNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikeTypeLabel;
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (nonatomic, strong) G100BikeDomain * bikeDomain;

@end

@implementation G100BikeInfoViewController

#pragma mark - Override
- (void)setBikeInfoModel:(G100BikeInfoCardModel *)bikeInfoModel{
    _bikeInfoModel = bikeInfoModel;
    
    self.bikeDomain = bikeInfoModel.bike;
    
    [self updateUI];
}

#pragma mark - 更新UI
- (void)updateUI {
    if ([self checkNotNull:self.bikeDomain.name]) {
        self.bikeNameLabel.text = self.bikeDomain.name;
    }else{
        self.bikeNameLabel.text = @"未填写";
    }
    
    if ([self checkNotNull:self.bikeDomain.feature.plate_number]) {
        self.bikePlateNumLabel.text = self.bikeDomain.feature.plate_number;
    }else{
        self.bikePlateNumLabel.text = @"未填写";
    }
    
    if ([self checkNotNull:self.bikeDomain.brand.name]) {
        self.brandLabel.text = self.bikeDomain.brand.name;
    }else{
        self.brandLabel.text = @"未填写";
    }
    
    if (self.bikeDomain.feature.integrity > 0) {
        self.infoIntegrityLabel.text =  [NSString stringWithFormat:@"资料完整度 %@%%", @(self.bikeDomain.feature.integrity)];
    }else{
        self.infoIntegrityLabel.text = @"快来补全信息吧";
    }
    
    self.bikeTypeLabel.text = [self bikeType];
}

#pragma mark - Private Method
- (BOOL)checkNotNull:(NSString *)string {
    if (string.length == 0 || string == NULL) {
        return NO;
    }
    return YES;
}

- (NSString *)bikeType {
    NSString *bikeType;
    if (![self.bikeDomain isMOTOBike]) {
        switch (self.bikeDomain.feature.type) {
            case 0:
                bikeType = @"";
                break;
            case 1:
                bikeType = @"滑板车";
                break;
            case 2:
                bikeType = @"两轮电动车";
                break;
            case 3:
                bikeType = @"三轮电动车";
                break;
            case 4:
                bikeType = @"四轮电动车";
                break;
            case 5:
                bikeType = @"电动自行车";
                break;
            case 99:
                bikeType = @"其他";
                break;
            default:
                bikeType = @"其他";
                break;
        }
        
    } else {
        switch (self.bikeDomain.feature.type) {
            case 6:
                bikeType = @"摩托车";
                break;
            case 99:
                bikeType = @"其他";
                break;
            default:
                bikeType = @"其他";
                break;
        }
    }
    
    return bikeType;
}

#pragma mark - 车辆特征编辑
- (void)editBikeFeature{
    G100BikeEditFeatureViewController *bikeFeatureEditVC = [[G100BikeEditFeatureViewController alloc]init];
    bikeFeatureEditVC.userid = self.userid;
    bikeFeatureEditVC.bikeid = self.bikeid;
    [self.navigationController pushViewController:bikeFeatureEditVC animated:YES];
}

#pragma mark - Public Method
+ (CGFloat)heightWithWidth:(CGFloat)width
{
    return width / 414.0 * 184;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editBikeFeature)];
    [self.topView addGestureRecognizer:tap];
    
    [UILabel adjustAllLabel:self.view multiple:0.5];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.bikeDomain = self.bikeInfoModel.bike;
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

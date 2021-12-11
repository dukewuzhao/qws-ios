//
//  G100BikeInfoBatteryViewController.m
//  G100
//
//  Created by 曹晓雨 on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeInfoBatteryViewController.h"

#import "G100WebViewController.h"
#import "G100UrlManager.h"
#import "UILabeL+AjustFont.h"

@interface G100BikeInfoBatteryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *batteryTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *battryVoltageLabel;
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (nonatomic, strong) G100BikeDomain * bikeDomain;

@end

@implementation G100BikeInfoBatteryViewController

#pragma mark - Override
- (void)setBikeInfoModel:(G100BikeInfoCardModel *)bikeInfoModel{
    _bikeInfoModel = bikeInfoModel;
    self.bikeDomain = _bikeInfoModel.bike;
    [self updateUI];
}

#pragma mark - 更新UI
- (void)updateUI {
    if (self.bikeDomain.feature.batteryInfo == 1) {
          self.batteryTypeLabel.text  = @"铅酸电池";
    }else if(self.bikeDomain.feature.batteryInfo == 2){
        self.batteryTypeLabel.text   = @"锂电池";
    }else{
        self.batteryTypeLabel.text   = @"未知";
    }

    if (self.bikeDomain.feature.voltageInfo < 1) {
        self.battryVoltageLabel.text = @"未知";
    }else{
        self.battryVoltageLabel.text = [NSString stringWithFormat:@"%.0fV",self.bikeDomain.feature.voltageInfo];
    }
}

#pragma mark - Public Method
+ (CGFloat)heightWithWidth:(CGFloat)width{
    return WIDTH / 414.00 * 112;
}

#pragma mark - 编辑电池信息
- (void)showBatteryDetailPagection{
    NSString *isMaster = [NSString stringWithFormat:@"%@", [NSNumber numberWithBool:[self.bikeDomain isMaster]]];
    G100WebViewController *webVc = [[G100WebViewController alloc]init];
    webVc.httpUrl = [[G100UrlManager sharedInstance] getBatteryAndVoltageUrlWithUserid:self.userid
                                                                                bikeid:self.bikeid
                                                                              isMaster:isMaster
                                                                                 devid:[NSString stringWithFormat:@"%ld",(long)self.bikeDomain.mainDevice.device_id]
                                                                              model_id:self.bikeDomain.mainDevice.model_id];
    [self.navigationController pushViewController:webVc animated:YES];

}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBatteryDetailPagection)];
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

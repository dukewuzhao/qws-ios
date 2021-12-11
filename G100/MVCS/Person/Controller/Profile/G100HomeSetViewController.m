//
//  G100HomeSetViewController.m
//  G100
//
//  Created by sunjingjing on 2017/7/12.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100HomeSetViewController.h"
#import "G100HomeLocViewController.h"

@interface G100HomeSetViewController ()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UISwitch *statusOpen;
@property (weak, nonatomic) IBOutlet UIView *homeView;

@property (weak, nonatomic) IBOutlet UILabel *homeAddress;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeDesLabel;
@property (weak, nonatomic) IBOutlet UILabel *bikeName;

@end

@implementation G100HomeSetViewController

#pragma mark - Action
- (void)rightNavgationButtonClick:(UIButton *)button {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[@"homeinfo"] = [self.homeInfo mj_keyValues];
    
    __weak G100HomeSetViewController *wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        if (requestSuccess) {
            [[UserManager shareManager] updateUserInfoWithUserid:wself.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                if (requestSuccess) {
                    [[G100InfoHelper shareInstance] updateMyUserInfoWithUserid:wself.userid userInfo:userInfo];
                    
                    if (self.setHomeBloc) {
                        self.setHomeBloc([self.homeInfo.homeaddr stringByReplacingOccurrencesOfString:@"&" withString:@""]);
                    }
                    
                    [self actionClickNavigationBarLeftButton];
                }
            }];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    [[G100UserApi sharedInstance] sv_updateUserdataWithUserinfo:userInfo callback:callback];
}

-(void)actionClickNavigationBarLeftButton{
    if (self.setHomeBloc) {
        self.setHomeBloc([self.homeInfo.homeaddr stringByReplacingOccurrencesOfString:@"&" withString:@""]);
    }
    
    [super actionClickNavigationBarLeftButton];
}

- (IBAction)pushToLoction:(id)sender {
    G100HomeLocViewController *homeLocVC = [[G100HomeLocViewController alloc] init];
    homeLocVC.homeInfo = self.homeInfo;
    homeLocVC.userid = self.userid;
    __weak typeof(self) weakSelf = self;
    homeLocVC.setHomeBloc = ^(NSString *homeAddr, CLLocationCoordinate2D location) {
        weakSelf.homeInfo.homeaddr = homeAddr;
        weakSelf.homeInfo.homelat = location.latitude;
        weakSelf.homeInfo.homelon = location.longitude;
        weakSelf.homeAddress.text = [homeAddr stringByReplacingOccurrencesOfString:@"&" withString:@""];
    };
    
    [self.navigationController pushViewController:homeLocVC animated:YES];
}

- (IBAction)openCloseAction:(UISwitch *)sender {
    self.homeInfo.home_addr_switch = (sender.on ? 1 : 2);
    
    [self updateUI];
}

- (void)updateUI {
    if (self.homeInfo.home_addr_switch == 1) {
        self.statusLabel.text = @"开启中";
        self.homeView.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
    }else {
        self.statusLabel.text = @"关闭中";
        self.homeView.backgroundColor = [UIColor colorWithHexString:@"efefef"];
    }
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationTitle:@"家的地址"];
    
    UIButton *endButton = [UIButton buttonWithType:UIButtonTypeSystem];
    endButton.titleLabel.font = [UIFont systemFontOfSize:17];
    endButton.exclusiveTouch = YES;
    endButton.titleLabel.textColor = [UIColor whiteColor];
    [endButton setTintColor:[UIColor clearColor]];
    [endButton setTitle:@"完成" forState:UIControlStateNormal];
    [endButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    endButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [endButton addTarget:self action:@selector(rightNavgationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self setRightNavgationButton:endButton];
    
    if (self.homeInfo.homeaddr.length) {
        self.homeAddress.text = [self.homeInfo.homeaddr stringByReplacingOccurrencesOfString:@"&" withString:@""];
    }else{
        self.homeAddress.text = [NSString stringWithFormat:@"点击打开地图定位"];
    }
    
    self.homeDesLabel.text = @"在回家的路上，如果太阳灭了，\n就把我点亮吧，我载着你回家。";
    
    NSArray *bikesArray = [[[G100InfoHelper shareInstance] findMyBikeListWithUserid:self.userid] mutableCopy];
    if (!bikesArray.count) {
        self.bikeName.text = nil;
    }else {
        G100BikeDomain *bikeDomian = [bikesArray safe_objectAtIndex:0];
        self.bikeName.text = [NSString stringWithFormat:@"——%@", bikeDomian.name];
    }
    
    self.homeAddress.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *locationTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToLoction:)];
    [self.homeAddress addGestureRecognizer:locationTap];
    
    self.statusOpen.on = (self.homeInfo.home_addr_switch == 1 ? YES : NO);
    
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

//
//  G100FuncSetOverSpeedViewController.m
//  G100
//
//  Created by 曹晓雨 on 2017/3/27.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100FuncSetOverSpeedViewController.h"

#import "G100OverSpeedCell.h"
#import "G100OverSpeedCustomeCell.h"
#import "G100SafeSetHintViewCell.h"
#import "G100BikeApi.h"
#import "G100BikeDomain.h"

#import "G100TopHintView.h"

@interface G100FuncSetOverSpeedViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) NSArray *detailHintArr;

@property (nonatomic, assign) BOOL isMotorcycle;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger maxSpeed;
@property (nonatomic, assign) NSInteger minSpeed;
@property (nonatomic, assign) float currentSliderValue;
@property (nonatomic, assign) float selectedSpeed;
@property (nonatomic, strong) G100BikeDomain *bikeDomain;
@property (nonatomic, strong) G100TopHintView *topHintView;

@property (nonatomic, assign) BOOL switchOn;
@property (nonatomic, strong) UISwitch *switchview;

@end

@implementation G100FuncSetOverSpeedViewController

#pragma mark - Over Write
- (void)actionClickNavigationBarLeftButton {
    if (!_bikeDomain.isMaster) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    _selectedSpeed = [NSString stringWithFormat:@"%.0ldKm/H", (long)_selectedSpeed].integerValue;
    [self showHudInView:self.view hint:@"正在保存设置"];
    __block typeof(self)weakself = self;
    [[G100BikeApi sharedInstance] setOverSpeedWithBikeid:self.bikeid maxSpeed:_selectedSpeed callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [weakself hideHud];
        if (requestSuccess) {
            // 更新电动车列表信息
            [[UserManager shareManager]updateBikeListWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                [weakself.navigationController popViewControllerAnimated:YES];
            }];
        }else {
            [self showHint:response.errDesc];
            [weakself.navigationController popViewControllerAnimated:YES];
        }
        
    }];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else {
        if (self.switchOn) {
            if (self.isMotorcycle) {
                return self.dataArr.count + 1;
            }
            return self.dataArr.count;
        }else {
            return 0;
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            G100SafeSetHintViewCell *safeSetHintCell = [tableView dequeueReusableCellWithIdentifier:@"G100SafeSetHintViewCell"];
            safeSetHintCell.detailBtnClicked = ^(){
                [self showAlert];
            };
            safeSetHintCell.selectionStyle = UITableViewCellSelectionStyleNone;
            return safeSetHintCell;
        }else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
                self.switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
                [self.switchview addTarget:self action:@selector(openOverspeed:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = self.switchview;
            }
            [self.switchview setOn:self.switchOn];
            cell.textLabel.text = self.switchOn ? @"开" : @"关";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }else {
        if (_isMotorcycle) {
            if (indexPath.item != self.dataArr.count) {
                G100OverSpeedCell *overSpeedCell = [tableView dequeueReusableCellWithIdentifier:@"G100OverSpeedCell"];
                if (!overSpeedCell) {
                    overSpeedCell = [[[NSBundle mainBundle] loadNibNamed:@"G100OverSpeedCell" owner:self options:nil] lastObject];
                }
                
                overSpeedCell.speedLable.text =  self.dataArr[indexPath.row];
                overSpeedCell.detailLabel.text = self.detailHintArr[indexPath.row];
                if (indexPath.row != 0) {
                    overSpeedCell.speedLable.text =  [NSString stringWithFormat:@"%@Km/H",self.dataArr[indexPath.row]];
                }
                if (indexPath.row == _selectedIndex) {
                    overSpeedCell.selectedImg.image = [UIImage imageNamed:@"select-single"];
                }else{
                    overSpeedCell.selectedImg.image = [UIImage imageNamed:@"select-single-none"];
                }
                
                if (!self.bikeDomain.isMaster) {
                    overSpeedCell.userInteractionEnabled = NO;
                } else {
                    overSpeedCell.userInteractionEnabled = YES;
                }
                return overSpeedCell;
            }else {
                G100OverSpeedCustomeCell *overSpeedCustomCell = [tableView dequeueReusableCellWithIdentifier:@"G100OverSpeedCustomeCell"];
                if (!overSpeedCustomCell) {
                    overSpeedCustomCell = [[[NSBundle mainBundle]loadNibNamed:@"G100OverSpeedCustomeCell" owner:self options:nil] lastObject];
                }
                
                overSpeedCustomCell.slider.maximumValue = _maxSpeed / 10.0;
                overSpeedCustomCell.slider.minimumValue = _minSpeed / 10.0;
                overSpeedCustomCell.sliderValue = _currentSliderValue / 10.0;
                
                __block typeof(self)weakself = self;
                overSpeedCustomCell.sliderValueBlock = ^(float value){
                    weakself.selectedSpeed =  weakself.currentSliderValue = value ;
                };
                if (_selectedIndex == indexPath.row) {
                    overSpeedCustomCell.isSelected = YES;
                }else{
                    overSpeedCustomCell.isSelected = NO;
                    
                }
                if (!self.bikeDomain.isMaster) {
                    overSpeedCustomCell.userInteractionEnabled = NO;
                } else {
                    overSpeedCustomCell.userInteractionEnabled = YES;
                }
                return overSpeedCustomCell;
            }
        }else {
            G100OverSpeedCell *overSpeedCell = [tableView dequeueReusableCellWithIdentifier:@"G100OverSpeedCell"];
            if (!overSpeedCell) {
                overSpeedCell = [[[NSBundle mainBundle] loadNibNamed:@"G100OverSpeedCell" owner:self options:nil] lastObject];
            }
            
            if (indexPath.row == 0) {
                overSpeedCell.speedLable.text =  [self.dataArr safe_objectAtIndex:indexPath.row];
            }else {
                overSpeedCell.speedLable.text =  [NSString stringWithFormat:@"%@Km/H",[self.dataArr safe_objectAtIndex:indexPath.row]];
            }
            
            overSpeedCell.detailLabel.text = [self.detailHintArr safe_objectAtIndex:indexPath.row];
            if (indexPath.row == _selectedIndex) {
                overSpeedCell.selectedImg.image = [UIImage imageNamed:@"select-single"];
            }else {
                overSpeedCell.selectedImg.image = [UIImage imageNamed:@"select-single-none"];
            }
            
            if (!self.bikeDomain.isMaster) {
                overSpeedCell.userInteractionEnabled = NO;
            } else {
                overSpeedCell.userInteractionEnabled = YES;
            }
            
            return overSpeedCell;
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44;
    }else {
        if (_isMotorcycle) {
            if (indexPath.row == self.dataArr.count) {
                return 113;
            }
        }
        return 70;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        NSString *content = nil;
        if (self.switchOn) {
            content  = @"为了倡导安全骑行,用车报告中提醒您本次骑行是否超速，请根据国家/地区道路标准自行选择";
        }else{
            content = @"最高时速设置为开，会显示超速提醒设置";
        }
        CGSize contentSize = [content calculateSize:CGSizeMake(WIDTH - 40, 1000) font:[UIFont systemFontOfSize:14]];
        return contentSize.height + 28;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.01;
    }else{
        return 20;
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return self.switchOn ? @"超速提醒" : nil;
    }
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 0) {
        UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH,60)];
        UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, backView.v_width - 40, 40)];
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont systemFontOfSize:14];
        
        [backView addSubview:titleLabel];
        
        if (self.switchOn) {
            titleLabel.textColor = [UIColor lightGrayColor];
            titleLabel.text = @"为了倡导安全骑行，用车报告中提醒您本次骑行是否超速,请根据国家/地区道路标准自行选择。";
        }else{
            titleLabel.textColor = [UIColor grayColor];
            titleLabel.text = @"最高时速设置为开，会显示超速提醒设置";
        }
        return backView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (kNetworkNotReachability) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    if (indexPath.row == _selectedIndex) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if (indexPath.row != 0) {
        if (indexPath.row == self.dataArr.count) {
            _selectedSpeed = _currentSliderValue == 0 ?_minSpeed  : _currentSliderValue;
        }else{
            _selectedSpeed = [self.dataArr[indexPath.row] floatValue];
        }
    }else {
        _selectedSpeed = 0;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    _selectedIndex = indexPath.row;
    [self.contentTableView reloadData];
}

#pragma mark - Private Method
- (void)openOverspeed:(id)sender {
    UISwitch *switchBtn = (UISwitch *)sender;
    self.switchOn = switchBtn.isOn;
    
    [[G100InfoHelper shareInstance] updateMyBikeInfoWithUserid:self.userid bikeid:self.bikeid bikeInfo:@{ @"max_speed_on": @(self.switchOn) }];
    [self.contentTableView reloadData];
    
    if (self.switchOn) {
        [self showAlert];
    }
}
- (void)showAlert {
    __weak typeof(self) wself = self;
    G100ReactivePopingView *popBox = [G100ReactivePopingView popingViewWithReactiveView];
    popBox.backgorundTouchEnable = NO;
    [popBox showPopingViewWithTitle:@"免责声明" content:@"最高时速计算结果受网络信号，卫星信号、天气情况影响，计算结果与仪表盘有误差，仅供参考" noticeType:ClickEventBlockCancel otherTitle:nil confirmTitle:@"我知道了" clickEvent:^(NSInteger index) {
        [popBox dismissWithVc:wself animation:YES];
    } onViewController:self onBaseView:self.view];
}

#pragma mark - Lazy load
- (G100TopHintView *)topHintView {
    if (!_topHintView) {
        _topHintView = [[G100TopHintView alloc]initWithDefaultHintText];
    }
    return _topHintView;
}

#pragma mark - setupView
- (void)initView {
    if (!self.bikeDomain.isMaster) {
        [self.view insertSubview:self.topHintView belowSubview:self.navigationBarView];
        self.topHintView.alpha = 0;
        [self.topHintView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.navigationBarView.mas_bottom);
            make.leading.trailing.equalTo(@0);
        }];
        [UIView animateWithDuration:1 animations:^{
            self.topHintView.alpha = 1;
        }];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                self.topHintView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.topHintView removeFromSuperview];
            }];
        });
    }
    
    _contentTableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    [_contentTableView registerNib:[UINib nibWithNibName:@"G100SafeSetHintViewCell" bundle:nil] forCellReuseIdentifier:@"G100SafeSetHintViewCell"];
}
- (void)initData {
    _bikeDomain = [[G100InfoHelper shareInstance]findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    if (![_bikeDomain isMOTOBike]) {
        self.dataArr = @[@"不显示", @"20", @"50"];
        self.detailHintArr = @[@"用车报告中不显示\"已超速\"", @"国家规定电动自行车限速标准", @"国家规定电动摩托车限速标准"];
        int i = 0;
        for (NSString *speed in self.dataArr) {
            if (speed.floatValue == _bikeDomain.max_speed) {
                _selectedIndex = i;
            }
            i++;
        }
    }else {
        self.dataArr = @[@"不显示", @"120", @"80"];
        self.detailHintArr = @[@"用车报告中不显示\"已超速\"", @"高速公路限速", @"一般道路限速"];
        _isMotorcycle = YES;
        int i = 0;
        BOOL hasSlected = NO;
        for (NSString *speed in self.dataArr) {
            if (speed.floatValue == _bikeDomain.max_speed) {
                _selectedIndex = i;
                hasSlected = YES;
            }
            i++;
        }
        if (!hasSlected) {
            _selectedIndex = self.dataArr.count; //选择自定义
            _currentSliderValue = _bikeDomain.max_speed;
        }
    }
    _selectedSpeed = _bikeDomain.max_speed;
    _maxSpeed = 200;
    _minSpeed = 40;
    
    self.switchOn = self.bikeDomain.max_speed_on;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationTitle:@"超速设置"];
    [self initData];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated{
    if (self.bikeDomain.isMaster) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }else {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

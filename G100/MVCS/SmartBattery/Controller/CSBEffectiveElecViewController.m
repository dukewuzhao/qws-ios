//
//  CSBEffectiveElecViewController.m
//  CloudSmartBattery
//
//  Created by yuhanle on 2016/12/13.
//  Copyright © 2016年 tilink. All rights reserved.
//

#import "CSBEffectiveElecViewController.h"
#import "CSBEffectiveElectricityView.h"
#import "ZFChart.h"
#import "ZEEBarChart.h"
#import "UIColor+Zirkfied.h"

#import "G100UrlManager.h"
#import "G100WebViewController.h"


#import "G100BatteryApi.h"
#import "G100BatteryDomain.h"

@interface CSBEffectiveElecViewController () <EffectiveElecHelpBtnDelegate, ZEEGenericChartDataSource, ZEEBarChartDelegate> {
    BOOL _hasLoadAnimation;
}

@property (strong, nonatomic) UIScrollView *containerView;
@property (nonatomic, strong) CSBEffectiveElectricityView *effectiveView;
@property (nonatomic, strong) ZEEBarChart * barChart;
@property (nonatomic, assign) CGFloat bottomViewHeight;

@property (nonatomic, strong) BatteryLoss *batteryLoss;

@end

@implementation CSBEffectiveElecViewController

#pragma mark - setupView
- (void)setUpEffectiveView
{
    // 布局容器
    self.containerView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.containerView.bounces = NO;
    self.containerView.showsVerticalScrollIndicator = NO;
    self.containerView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.containerView];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.effectiveView = [CSBEffectiveElectricityView showView];
    _effectiveView.showBackImgView = NO;
    _effectiveView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    _effectiveView.delegate = self;
    self.effectiveView.type = DefaultCircleView;
    [self.containerView addSubview:_effectiveView];
    
    _bottomViewHeight = (HEIGHT / 672.00)*(672 - 622);
    self.containerView.contentSize = CGSizeMake(self.containerView.frame.size.width, HEIGHT - 64 - _bottomViewHeight+ 420);
}

- (void)setUpSingleBarChartView
{
    //电池损耗记录label 切图上位置与电池循环view在同一界面 此处已自定义在图表标题上 故上移覆盖~
    self.barChart = [[ZEEBarChart alloc] initWithFrame:CGRectMake(0, HEIGHT - _bottomViewHeight - 54, WIDTH, 420)];
    self.barChart.dataSource = self;
    self.barChart.delegate = self;
    self.barChart.topicLabel.text = @"电池损耗记录";
    self.barChart.isShadow = NO;
    self.barChart.isResetAxisLineMaxValue = YES;
    [self.barChart setAxisLineNameColor:[UIColor colorWithHexString:@"7D7D7D"]];
    [self.barChart setAxisLineNameFont:[UIFont systemFontOfSize:14]];
    [self.barChart setAxisLineNameNormalFont:[UIFont systemFontOfSize:14]];
    [self.barChart setAxisLineNameSelectedFont:[UIFont boldSystemFontOfSize:14]];
    
    self.barChart.xTopDescLabel.text = @"100%";
    self.barChart.xTopDescLabel.font = [UIFont systemFontOfSize:17];
    self.barChart.xTopDescLabel.textColor = [UIColor colorWithHexString:@"#1FC0CF"];
    
    self.barChart.gradientBgView.image = [UIImage imageNamed:@"bg_chart_battery_effectice"];
    [self.barChart.leftGuideBtn setImage:[UIImage imageNamed:@"ic_chart_left_arrow"] forState:UIControlStateNormal];
    
    self.barChart.backgroundColor = [UIColor whiteColor];
    [self.containerView addSubview:self.barChart];
    [self.barChart strokePath];
    
    // 默认滚动到最右侧
    [self.barChart scrollToRight:NO];
    
    // 默认选中最后一个bar
    [self.barChart configSelectedBarAtGroupIndex:[[self valueArrayInGenericChart:self.barChart] count] - 1];

}
#pragma mark - CSBEffectiveElectricityView delegate
- (void)helpBtnClicked
{
    G100WebViewController *webVc = [[G100WebViewController alloc]init];
    webVc.httpUrl =  [[G100UrlManager sharedInstance]getMsgsHelp];
    [self.navigationController pushViewController:webVc animated:YES];
}

#pragma mark - ZEEGenericChartDataSource

- (NSArray *)valueArrayInGenericChart:(ZEEGenericChart *)chart{
    NSMutableArray *result = [NSMutableArray array];
    
    for (BatteryLossDetail *detial in self.batteryLoss.list) {
        NSString *tmp = [NSString stringWithFormat:@"%@", @(detial.loss)];
        [result addObject:tmp];
    }
    
    result = result.count ? result : @[@"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0"].mutableCopy;
    
    return result.copy;
}

- (NSArray *)nameArrayInGenericChart:(ZEEGenericChart *)chart{
    NSMutableArray *result = [NSMutableArray array];
    
    for (BatteryLossDetail *detial in self.batteryLoss.list) {
        NSString *tmp = [NSString stringWithFormat:@"%@", detial.chartDisplayDate];
        [result addObject:tmp];
    }
    
    result = result.count ? result : @[@"2016\n9月", @"2016\n10月", @"2016\n11月", @"2016\n12月", @"2017\n1月", @"2017\n2月", @"2017\n3月", @"2017\n4月", @"2017\n5月", @"2017\n6月", @"2017\n7月", @"本月"].mutableCopy;
    
    return result.copy;
}

- (NSArray *)topTitleArrayInZEEBarChart:(ZEEBarChart *)chart {
    NSMutableArray *result = [NSMutableArray array];
    
    for (BatteryLossDetail *detial in self.batteryLoss.list) {
        NSString *tmp = [NSString stringWithFormat:@"%.1lf%%", detial.loss];
        [result addObject:tmp];
    }
    
    result = result.count ? result : @[@"0%", @"0%", @"0%", @"0%", @"0%", @"0%", @"0%", @"0%", @"0%", @"0%", @"0%", @"0%"].mutableCopy;
    
    return result.copy;
}

- (CGFloat)axisLineMaxValueInGenericChart:(ZEEGenericChart *)chart{
    return 100;
}

- (NSUInteger)axisLineSectionCountInGenericChart:(ZEEGenericChart *)chart{
    return 10;
}

#pragma mark - ZEEBarChartDelegate

- (CGFloat)barWidthInBarChart:(ZEEBarChart *)barChart{
    return 52.f;
}

- (CGFloat)paddingForGroupsInBarChart:(ZEEBarChart *)barChart {
    return 8.0f;
}

- (NSArray *)gradientColorArrayInBarChart:(ZEEBarChart *)barChart{
    NSMutableArray *gradientAttributes = [[NSMutableArray alloc] init];
    
    for (NSString *result in [self valueArrayInGenericChart:barChart]) {
        NSInteger res = [result integerValue];
        
        ZFGradientAttribute * gradientAttribute = [[ZFGradientAttribute alloc] init];
        
        UIColor *redColor = [UIColor colorWithHexString:@"#EE1515"];
        UIColor *yellowColor = [UIColor colorWithHexString:@"#FF9C00"];
        
        UIColor *blueColor = [UIColor colorWithHexString:@"#1FC0CF"];
        UIColor *greenColor = [UIColor colorWithHexString:@"#26EF42"];
        
        if (res > 50) {
            gradientAttribute.colors = @[(__bridge id)blueColor.CGColor, (__bridge id)greenColor.CGColor];
        }else {
            gradientAttribute.colors = @[(__bridge id)redColor.CGColor, (__bridge id)yellowColor.CGColor];
        }
        
        gradientAttribute.locations = @[@(0.2), @(1.0)];
        gradientAttribute.startPoint = CGPointMake(0, 0);
        gradientAttribute.endPoint = CGPointMake(0, 1);
        
        [gradientAttributes addObject:gradientAttribute];
    }
    
    return [gradientAttributes copy];
}

- (void)barChart:(ZEEBarChart *)barChart didSelectBarAtGroupIndex:(NSInteger)groupIndex barIndex:(NSInteger)barIndex bar:(ZFBar *)bar {
    NSLog(@"第%ld组========第%ld个",(long)groupIndex,(long)barIndex);
    
    //可在此处进行bar被点击后的自身部分属性设置,可修改的属性查看ZFBar.h
    bar.barColor = ZFGold;
    bar.isAnimated = YES;
    [bar strokePath];
}

#pragma mark - 查询电池循环使用次数
- (void)quereyBatteryLossWithBatteryid:(NSString *)batteryid quereytype:(NSInteger)quereytype callback:(API_CALLBACK)callback {
    __weak typeof(self) wself = self;
    [[G100BatteryApi sharedInstance] getBatteryLossWithBatteryid:batteryid quereytype:quereytype callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            BatteryLoss *batt = [[BatteryLoss alloc] initWithDictionary:response.data];
            self.batteryLoss = batt;
            [self.barChart strokePath];
            
            // 默认滚动到最右侧
            [self.barChart scrollToRight:NO];
            // 默认选中最后一个bar
            [self.barChart configSelectedBarAtGroupIndex:[[self valueArrayInGenericChart:self.barChart] count] - 1];
        }else {
            [wself showHint:response.errDesc];
        }
        
        if (callback) {
            callback(statusCode, response, requestSuccess);
        }
    }];
}

#pragma mark - Setter
- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain {
    _batteryDomain = batteryDomain;
    [_effectiveView setBatteryDomain:batteryDomain animated:NO];
}

- (void)setBatteryDomain:(G100BatteryDomain *)batteryDomain animated:(BOOL)animated {
    _batteryDomain = batteryDomain;
    [_effectiveView setBatteryDomain:batteryDomain animated:animated];
}

- (void)becameActived {
    if (!self.batteryDomain) {
        return;
    }
    
    if (!_hasLoadAnimation) {
        [_effectiveView setBatteryDomain:self.batteryDomain animated:YES];
    }else {
        [_effectiveView setBatteryDomain:self.batteryDomain animated:NO];
    }
    _hasLoadAnimation = YES;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUpEffectiveView];
    [self setUpSingleBarChartView];
    
    [self quereyBatteryLossWithBatteryid:self.batteryid quereytype:2 callback:nil];
}

- (void)dealloc
{
     self.effectiveView = nil;
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

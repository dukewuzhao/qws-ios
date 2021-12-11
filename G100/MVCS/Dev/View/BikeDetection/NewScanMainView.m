//
//  NewScanMainView.m
//  G100
//
//  Created by Tilink on 15/3/30.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "NewScanMainView.h"
#import "G100TestResultDomain.h"
#import "NewScoreTestingCell.h"

#import "G100BikeEditFeatureViewController.h"

#import "G100BikeApi.h"

#import <pop/POP.h>

#define DefaultTopH 210 * WIDTH / 320.0f

@interface NewScanMainView () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressWConstant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHConstant;

@property (nonatomic,assign) CGFloat lastOffSet;

@property (strong, nonatomic) NSMutableArray *testArray;
@property (strong, nonatomic) NSMutableArray *handBetter;
@property (strong, nonatomic) NSMutableArray *completeBetter;

@property (strong, nonatomic) NSMutableArray *safeArray;
@property (strong, nonatomic) NSMutableArray *betterArray;

@property (strong, nonatomic) NSTimer *detectionTimer;

@property (assign, nonatomic) BOOL hasAppear;

@end

@implementation NewScanMainView

- (void)dealloc {
    if ([_detectionTimer isValid]) {
        [_detectionTimer invalidate];
        _detectionTimer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (NSTimer *)detectionTimer {
    if (_detectionTimer == nil) {
        self.detectionTimer = [NSTimer scheduledTimerWithTimeInterval:1.2f
                                                               target:self
                                                             selector:@selector(timerChanged:)
                                                             userInfo:nil
                                                              repeats:YES];
        [self.detectionTimer setFireDate:[NSDate distantFuture]];
    }
    return _detectionTimer;
}
- (NSMutableArray *)safeArray {
    if (!_safeArray) {
        _safeArray = [NSMutableArray array];
    }
    return _safeArray;
}
- (NSMutableArray *)betterArray {
    if (!_betterArray) {
        _betterArray = [NSMutableArray array];
    }
    return _betterArray;
}

#pragma mark - 顶部缩放核心代码 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;//取出offset的y值
    CGFloat delta = offset - _lastOffSet;//与上次存放的值相减
    if (delta > 0)//差值大于0，则是往上滑，因为contentOffset.y值是增加的
    {
        //当往上滑动时，发现ImageView的高度大于0，则要按照滑动的速率也就是delta值减去ImageView的高度，直到小于0停止
        if (self.topViewHConstant.constant > DefaultTopH) {
            self.topViewHConstant.constant -= delta;
        }else
        {
            self.topViewHConstant.constant = DefaultTopH;//ImageView高度已经小于0，重置为0,因为滑动快的话，高度会变负数
        }
    }else if(delta < 0)//差值小于0，往下滑
    {
        //当我们设置了tableView的顶部EdgeInset，正常情况下，tableView的contentOffset一开始是为负数的，我们这里一开始就是-244，也就是Imageview的高度加上红色View的高度
        //当第一行cell滚动到红色View底部时，offset为-44，大家可以停下来想想看是不是，然后当继续往下滑动时，offset更加小了
        //这时Imageview就要出现了
        if (offset < -DefaultTopH) {
            //ImageView出现了，开始设置其高度
            //而ImageView的高度应该与self.view顶部到红色View的顶部的间距相等
            //大家想想看是不是
            //于是我直接用contentOffset减去（因为是负数）红色View的高度，然后不就等于这间距了么，于是功能就实现了
            self.topViewHConstant.constant = ABS(scrollView.contentOffset.y);
        }
    }
    
    _lastOffSet = offset;
}

#pragma mark - 更新主页分数
-(void)updateScoreNumber {
    if (_scoreNumber >= 100) {
        _scoreNumber = 100;
    }
    if (_scoreNumber <= 0) {
        _scoreNumber = 0;
    }
    
    NSInteger a = [self.scoreLabel.text integerValue];
    
    POPBasicAnimation *anim = [POPBasicAnimation animation];
    anim.duration = 1.0;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    __weak NewScanMainView * wself = self;
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"count" initializer:^(POPMutableAnimatableProperty *prop) {
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [[obj description] floatValue];
        };
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            wself.scoreLabel.attributedText = [wself formatProgressString:[NSString stringWithFormat:@"%ld", (long)values[0]]];
            wself.topView.backgroundColor = [wself dynamicChangeTopViewBackgroundColorWithScore:values[0]];
        };
        
        prop.threshold  = 0.01;
    }];
    
    anim.property = prop;
    anim.fromValue = @(a);
    anim.toValue = @(_scoreNumber);
    
    [self.scoreLabel pop_addAnimation:anim forKey:@"count"];
}

- (NSAttributedString *)formatProgressString:(NSString *)score {
    
    NSMutableAttributedString *attributedString;
    NSString * status = @"分";
    
    if (status.length > 0) {
        
        attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", score, status]];
        
        [attributedString addAttributes:@{
                                          NSFontAttributeName: [UIFont boldSystemFontOfSize:80]}
                                  range:NSMakeRange(0, score.length)];
        
        [attributedString addAttributes:@{
                                          NSFontAttributeName: [UIFont systemFontOfSize:24],
                                        }
                                  range:NSMakeRange(score.length, status.length)];
    }
    else
    {
        attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",score]];
        
        [attributedString addAttributes:@{
                                          NSFontAttributeName: [UIFont boldSystemFontOfSize:80]}
                                  range:NSMakeRange(0, score.length)];
    }
    
    return attributedString;
}

-(void)timerChanged:(NSTimer *)detectionTimer {
    if (_currentIndex < _dataArray.count) {
        [_testArray addObject:_dataArray[_currentIndex++]];
        self.progressWConstant.constant = self.testAnimationView.v_width / _dataArray.count * _currentIndex;
        _tableView.contentOffset = CGPointMake(0, _tableView.contentSize.height - _tableView.v_height + kNavigationBarHeight);
    }else {
        self.testAnimationView.hidden = YES;
        [self endAnimation];
        _tableView.contentOffset = CGPointMake(0, -DefaultTopH);
        [self updateUserDefault];
        
        if (_testOverAction) {
            self.testOverAction();
        }
    }
    
    if (_isTesting) {
        self.tableView.scrollEnabled = NO;
        self.resultLabel.hidden = YES;
    }else {
        self.tableView.scrollEnabled = YES;
        [UIView animateWithDuration:0.3f animations:^{
            self.resultLabel.hidden = NO;
        }];
    }
    
    [_tableView reloadData];
}

#pragma mark - Private Method
-(void)updateUserDefault {
    if (_scoreNumber >= 100) {
        _scoreNumber = 100;
    }
    if (_scoreNumber <= 0) {
        _scoreNumber = 0;
    }
    
    if (_isTesting) {
        
    }else {
        if (!_testResult) {
            self.testResult = [[G100TestResultDomain alloc]init];
        }
        [self.safeArray removeAllObjects];
        [self.betterArray removeAllObjects];
        self.testResult.userid = _userid;
        self.testResult.devid = _bikeid;
        self.testResult.lastTestTime = GetCurrentTimeStr();
        if (self.handBetter.count) {
            NSMutableArray * arr = [[NSMutableArray alloc]initWithCapacity:self.handBetter.count];
            for (G100DevTestDomain * model in self.handBetter) {
                NSDictionary * dict = [model mj_keyValues];
                [arr addObject:dict];
                if (model.security_class == 1) {
                    [self.safeArray addObject:model];
                }else if (model.security_class == 2){
                    [self.betterArray addObject:model];
                }
            }
            self.testResult.waitSetBetter = arr.copy;
        }else {
            self.testResult.waitSetBetter = nil;
        }
        
        self.testResult.score = _scoreNumber;
        if (self.safeArray.count > 0) {
            self.testResult.testResultHint = [NSString stringWithFormat:@"爱车有%ld项安全问题，请尽快处理",self.safeArray.count];
            self.testResult.showType = 1;
        }else{
            if (self.betterArray.count >0) {
                self.testResult.testResultHint = [NSString stringWithFormat:@"爱车有%ld项问题需要优化，请尽快处理",self.betterArray.count];
            }else{
                self.testResult.testResultHint = @"赞爆了，遥遥领先其他用户，继续保持哦";
            }
            self.testResult.showType = 2;
        }
        [[G100InfoHelper shareInstance] updateMyBikeTestResultWithuserid:self.userid bikeid:self.bikeid result:[self.testResult mj_keyValues]];
        [[UserManager shareManager]setAsynchronous:[NSNumber numberWithBool:YES] withKey:kGXScoreChanged];
    }
    
    [self.resultLabel adjustsFontSizeToFitWidth];
    self.resultLabel.text = [self.displayResult displayTextWithScore:_scoreNumber];
}

#pragma mark - Public Method
-(void)inAnimation {
    __weak NewScanMainView * wself = self;
    [UIView animateWithDuration:0.3f animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        wself.scoreLabel.transform=CGAffineTransformMakeScale(1.2f, 1.2f);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            wself.scoreLabel.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:^(BOOL finished) {
            
        }];
    }];
}

-(void)startAnimation {
    _currentIndex = 0;
    
    _isTesting = YES;
    [_detectionTimer setFireDate:[NSDate distantPast]];
}

-(void)endAnimation {
    [_detectionTimer setFireDate:[NSDate distantFuture]];
    _isTesting = NO;
    
    if ([_detectionTimer isValid]) {
        [_detectionTimer invalidate];
        _detectionTimer = nil;
    }
    _currentIndex = 0;
}

-(void)setupViewWithOwner:(G100ScanViewController *)owner {
    self.currentTestLabel.adjustsFontSizeToFitWidth = YES;
    
    self.resultLabel.font = [UIFont fontWithName:@"Helvetica" size:FontInBiggest(17)];
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.hidden = YES;
    self.scoreNumber = 100;
    
    //设置界面的按钮显示 根据自己需求设置
    self.scoreLabel.attributedText = [self formatProgressString:[NSString stringWithFormat:@"%ld", (long)_scoreNumber]];
    self.testArray = [[NSMutableArray alloc]init];
    self.handBetter = [[NSMutableArray alloc]init];
    self.completeBetter = [[NSMutableArray alloc]init];
    self.backgroundColor = MyBackColor;
    
    self.topView.backgroundColor = MyHomeColor;
    self.topViewHConstant.constant = 210 * WIDTH / 320.0f;
    self.tableView.backgroundColor = MyBackColor;
    self.tableView.contentInset = UIEdgeInsetsMake(DefaultTopH, 0, 0, 0);
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.detectionTimer setFireDate:[NSDate distantFuture]];
    
    self.isTesting = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newScanMainViewDidBecameActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newScanMainViewWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    
    // iOS 11 UI 显示bug 修复
    if ([self.tableView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.tableView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
}

- (void)reloadResult {
    if (_isTesting) {
        return;
    }
    
    NSInteger addScoreNumber = 0;
    for (G100DevTestDomain *model in self.dataArray) {
        if (model.deduct == 0) {
            BOOL hasHanlded = NO;
            for (G100DevTestDomain *handledModel in _completeBetter) {
                if (handledModel.item_id == model.item_id) {
                    hasHanlded = YES;
                }
            }
            
            if (!hasHanlded) {
                [_completeBetter addObject:model];
                addScoreNumber += model.suggestions.action_buttons.firstObject.bonus;
            }
            
            NSMutableArray *hasTratedArr = [[NSMutableArray alloc] init];
            for (G100DevTestDomain *betterModel in _handBetter) {
                if (betterModel.item_id == model.item_id) {
                    [hasTratedArr addObject:betterModel];
                }
            }
            
            [_handBetter removeObjectsInArray:hasTratedArr];
        }
    }
    
    _scoreNumber += addScoreNumber;
    
    [self updateScoreNumber];
    [self updateUserDefault];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isTesting) {
        return 1;
    }
    if (_handBetter.count && _completeBetter.count) {
        return 2;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isTesting) {
        return  _testArray.count;
    }
    if (_handBetter.count && section == 0) {
        return _handBetter.count;
    }
    return _completeBetter.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.tableView.v_width, 40)];
    label.backgroundColor = MyBackColor;
    label.font = [UIFont systemFontOfSize:18];
    if (_isTesting) {
        UIView * backView = [[UIView alloc]initWithFrame:label.bounds];
        label.textColor = MyGreenColor;
        label.text = @"检查中";
        
        UIView * bottomLine = [[UIView alloc]initWithFrame:CGRectMake(-15, 39, WIDTH, 1)];
        bottomLine.backgroundColor = MyGreenColor;
        
        [backView addSubview:label];
        [backView addSubview:bottomLine];
        
        return backView;
    }else {
        label.textColor = [UIColor grayColor];
        if (_handBetter.count && section == 0) {
            label.text = @"手动优化项:";
        }else {
            label.text = @"已完成项:";
        }
    }
    
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isTesting) {
        return 80;
    }else {
        if (_handBetter.count && indexPath.section == 0) {
            G100DevTestDomain * model = [_handBetter safe_objectAtIndex:indexPath.row];
            CGSize size1 = [model.description_pro calculateSize:CGSizeMake((WIDTH - 74), MAXFLOAT) font:[UIFont systemFontOfSize:17]];
            CGSize size = [model.suggestions.description_pro calculateSize:CGSizeMake((WIDTH - 74), MAXFLOAT) font:[UIFont systemFontOfSize:15]];
            return 140-18-21 + size.height + size1.height;
        }
    }
    
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak NewScanMainView * wself = self;
    if (_isTesting) {
        NewScoreTestingCell * cell = [tableView dequeueReusableCellWithIdentifier:@"testcell"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"NewScoreTestingCell" owner:self options:nil]lastObject];
        }
        
        G100DevTestDomain * model = [_testArray safe_objectAtIndex:indexPath.row];
        if (_currentIndex == indexPath.row + 1) {
            [cell showUIWithModel:model test:YES];
            self.currentTestLabel.text = [NSString stringWithFormat:@"正在检查:%@", model.checking_desc];
            if (model.deduct == 0) {
                [_completeBetter addObject:model];
            }else {
                [_handBetter addObject:model];
                // 执行扣分操作   每一项扣2分
                _scoreNumber += model.deduct;
                
                [self updateScoreNumber];
                [self updateUserDefault];
            }
        }else {
            [cell showUIWithModel:model test:NO];
        }
        
        return cell;
    }else {
        if (_handBetter.count && indexPath.section == 0) {
            NewScoreTestingCell * cell = [tableView dequeueReusableCellWithIdentifier:@"handlecell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"NewScoreTestingCell" owner:self options:nil]firstObject];
            }
            
            G100DevTestDomain * model = [_handBetter safe_objectAtIndex:indexPath.row];
            cell.handleSetSoon = ^(NSInteger action) {
                [wself setSoonHandleBetter:model action:action];

            };
            [cell showResultWithModel:model];
            
            return cell;
        }else {
            NewScoreTestingCell * cell = [tableView dequeueReusableCellWithIdentifier:@"completecell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"NewScoreTestingCell" owner:self options:nil]lastObject];
            }
            
            G100DevTestDomain * model = [_completeBetter safe_objectAtIndex:indexPath.row];
            [cell showUIWithModel:model test:NO];
            
            return cell;
        }
    }
}

#pragma mark - Private
- (void)setSoonHandleBetter:(G100DevTestDomain *)testModel action:(NSInteger)action {
    __weak NewScanMainView * wself = self;
    __weak UIViewController * scanVC = CURRENTVIEWCONTROLLER;
    
    switch (testModel.item_id) {
        case SecureScrBatteryPower:
        {
            // 电池电量
            G100SecurityActionButtons *actionBtn = [testModel.suggestions.action_buttons safe_objectAtIndex:action - 1];
            if (actionBtn && actionBtn.path.length) {
                G100BikeDomain *bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
                NSString *opUrl = [NSString stringWithFormat:@"%@&ismaster=%@", actionBtn.path, bikeDomain.is_master];
                if ([G100Router canOpenURL:opUrl]) {
                    [G100Router openURL:opUrl];
                }            }
            else {
                [self handleTwoActionWithTestDomain:testModel action:action];
            }
        }
            break;
        case SecureScrSecuritySetting:
        {
            // 设防撤防状态
            API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
                if (requestSuccess) {
                    testModel.description_pro = @"设防已经打开";
                    testModel.deduct = 0;
                    [wself.completeBetter addObject:testModel];
                    [wself.handBetter removeObject:testModel];
                    
                    wself.scoreNumber += testModel.suggestions.action_buttons.firstObject.bonus;
                    testModel.deduct = 0;
                    [wself updateScoreNumber];
                    [wself updateUserDefault];
                    [wself.tableView reloadData];
                    
                    [[UserManager shareManager] updateBikeInfoWithUserid:wself.userid bikeid:wself.bikeid complete:nil];
                }else {
                    if (response) {
                        [scanVC showHint:response.errDesc];
                    }
                }
            };
            
            // 默认标准模式
            [[G100BikeApi sharedInstance] setBikeSecuritySettingsWithUserid:self.userid bikeid:self.bikeid devid:self.devid mode:2 callback:callback];
        }
            break;
        default:
        {
            // 默认操作
            [self handleTwoActionWithTestDomain:testModel action:action];
        }
            break;
    }
}

#pragma mark - 统一处理
- (void)handleTwoActionWithTestDomain:(G100DevTestDomain *)testModel action:(NSInteger)action {
    if (!testModel.suggestions.action_buttons.count) {
        testModel.deduct = 0;
        [_completeBetter addObject:testModel];
        [_handBetter removeObject:testModel];
        
        self.scoreNumber += testModel.suggestions.action_buttons.firstObject.bonus;
        [self updateScoreNumber];
        [self updateUserDefault];
        [self.tableView reloadData];
    }
    else {
        G100SecurityActionButtons *actionBtn = [testModel.suggestions.action_buttons safe_objectAtIndex:action - 1];
        if (actionBtn && actionBtn.path.length) {
            if ([G100Router canOpenURL:actionBtn.path]) {
                [G100Router openURL:actionBtn.path];
            }
        }
        else {
            [self addBonusWithTestDomain:testModel actionButtons:actionBtn];
        }
    }
}

- (void)addBonusWithTestDomain:(G100DevTestDomain *)testModel actionButtons:(G100SecurityActionButtons *)actionButton {
    testModel.deduct = 0;
    [_completeBetter addObject:testModel];
    [_handBetter removeObject:testModel];
    
    self.scoreNumber += actionButton.bonus;
    [self updateScoreNumber];
    [self updateUserDefault];
    [self.tableView reloadData];
}

- (UIColor *)dynamicChangeTopViewBackgroundColorWithScore:(NSInteger)score {
    CGFloat h = (CGFloat)(MIN_COLOR + (score-MIN_SCORE) * mRate);
    h = (h <= 0 ? 0 : h);
    return [UIColor colorWithHue:h / 360.0 saturation:0.72f brightness:0.7f alpha:1.0f];
}

#pragma mark - Life cycle
- (void)viewDidAppear {
    // 如果正在测试 在出现的时候继续测试
    if (_isTesting) {
        [self.detectionTimer setFireDate:[NSDate distantPast]];
    }
}
- (void)viewDidDisappear {
    [_detectionTimer setFireDate:[NSDate distantFuture]];
    
    if ([_detectionTimer isValid]) {
        [_detectionTimer invalidate];
        _detectionTimer = nil;
    }
}
- (void)viewWillAppear { }
- (void)viewWillDisappear { }

#pragma mark - 程序前后台监听处理
- (void)newScanMainViewDidBecameActive:(NSNotification *)notification {
    if (_isTesting) {
        if ([_detectionTimer isValid]) {
            [_detectionTimer setFireDate:[NSDate distantPast]];
        }
    }
}

- (void)newScanMainViewWillResignActive:(NSNotification *)notification {
    if (_isTesting) {
        if ([_detectionTimer isValid]) {
            [_detectionTimer setFireDate:[NSDate distantFuture]];
        }
    }
}

@end

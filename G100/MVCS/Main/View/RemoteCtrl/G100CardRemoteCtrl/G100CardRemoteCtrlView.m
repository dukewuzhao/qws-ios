//
//  G100CardRemoteCtrlView.m
//  G100CardRemoteCtrlView
//
//  Created by yuhanle on 16/6/27.
//  Copyright © 2016年 yuhanle. All rights reserved.
//

#import "G100CardRemoteCtrlView.h"
#import "G100CardManager.h"

#define kTopViewH 40

#define kBLEColor [UIColor colorWithRed:26/255.0 green:152/255.0 blue:252/255.0 alpha:1.0]
#define kGPRSColor [UIColor colorWithHexString:@"FFFFFF"]

#define kBLELineColor [UIColor colorWithRed:18/255.0 green:122/255.0 blue:201/255.0 alpha:1.0]
#define kGPRSLineColor [UIColor colorWithHexString:@"E5E5E5"]

#define kBLEColor1 [UIColor colorWithRed:26/255.0 green:152/255.0 blue:252/255.0 alpha:1.0]
#define kGPRSColor1 [UIColor colorWithRed:53/255.0 green:179/255.0 blue:30/255.0 alpha:1.0]

#define kBLELineColor1 [UIColor colorWithRed:18/255.0 green:122/255.0 blue:201/255.0 alpha:1.0]
#define kGPRSLineColor1 [UIColor colorWithRed:34/255.0 green:116/255.0 blue:16/255.0 alpha:1.0]

static CGFloat itemW2HRatio = 295/270.0;

@interface G100CardRemoteCtrlView () <UICollectionViewDelegate, UICollectionViewDataSource, G100CtrlTopStatusViewDelegate, G100RTCollectionViewCellDelegate> {
    BOOL _hasLoaded;
}

@property (nonatomic, strong) NSMutableDictionary *cellIdentifierDict;

@end

@implementation G100CardRemoteCtrlView

- (instancetype)init {
    if (self = [super init]) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)setupView {
    _hasLoaded = NO;
    self.needSingleCtrl = YES;
    CGRect frame = self.frame;
    if (frame.size.height < kNavigationBarHeight) {
        frame.size.height = kNavigationBarHeight;
        self.frame = frame;
    }
    
    self.backgroundColor = kGPRSLineColor;
    
    _isCommandSending = NO;

    self.topStatusView = [[G100CtrlTopStatusView alloc] init];
    [self.topStatusView setStatus:0];
    self.topStatusView.delegate = self;
    [self addSubview:self.topStatusView];
    
    [self.topStatusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(@0);
        make.height.equalTo(kTopViewH);
    }];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    self.ctrlBtnsView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 80) collectionViewLayout:flowLayout];
    self.ctrlBtnsView.delegate = self;
    self.ctrlBtnsView.dataSource = self;
    self.ctrlBtnsView.scrollEnabled = NO;
    self.ctrlBtnsView.backgroundColor = kGPRSLineColor;
    [self addSubview:self.ctrlBtnsView];
    
    [self.ctrlBtnsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topStatusView.mas_bottom).with.offset(1);
        make.left.right.bottom.equalTo(@0);
    }];
    
    [self bringSubviewToFront:self.topStatusView];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataGPSArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *commonKey = [NSString stringWithFormat:@"remode_ctrl%@-%@", @(indexPath.section), @(indexPath.row)];
    NSString *identifier = [self.cellIdentifierDict objectForKey:commonKey];
    if (identifier == nil) {
        identifier = commonKey;
        [self.cellIdentifierDict setValue:identifier forKey:commonKey];
        [self.ctrlBtnsView registerClass:[G100RTCollectionViewCell class]
              forCellWithReuseIdentifier:identifier];
    }
    
    G100RTCollectionViewCell *viewCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier
                                                                                   forIndexPath:indexPath];
    
    NSMutableArray *array;
    if (self.status == 0) {
        if (self.rtStatus == 0) {
            array = self.dataGPSArray;
        }else if (self.rtStatus == 1) {
            array = self.dataBLEArray;
        }else if (self.rtStatus == 2) {
            array = self.dataGPSArray;
        }else if (self.rtStatus == 3) {
            array = self.dataGPSArray;
        }else {
            array = self.dataGPSArray;
        }
    }else if (self.status == 1) {
        array = self.dataBLEArray;
    }else if (self.status == 2) {
        array = self.dataGPSArray;
    }else {
        array = self.dataGPSArray;
    }
    G100RTCommandModel *model = [array safe_objectAtIndex:indexPath.row];
    if (self.status == 0 || self.rtStatus == 0) {
        model.rt_status = 0;
    }else {
        model.rt_status = self.status;
    }
    
    viewCell.totalCount = self.dataGPSArray.count;
    viewCell.rtCommand = model;
    viewCell.indexPath = indexPath;
    viewCell.delegate = self;
    viewCell.rtEnabled = !_isCommandSending;
    viewCell.rtCustomBgImage = YES;
    
    return viewCell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((CGRectGetWidth(self.frame)-2.0)/4.0, (CGRectGetWidth(self.frame)-2.0)/4.0/itemW2HRatio);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    cell.alpha = 0.3;
    [UIView animateWithDuration:0.6 animations:^{
        cell.alpha = 1.0;
    }];
}

#pragma mark - G100CtrlTopStatusViewDelegate
- (void)valueDidChanged:(G100CtrlTopStatusView *)mwsTopStatusView status:(int)status {
    if (_rtStatus == 0 || _rtStatus == 1 || _rtStatus == 2) {
        return;
    }
    if (_status == 0) {
        return;
    }
    
    self.status = status+1;
    
    if ([_delegate respondsToSelector:@selector(cardRemoteCtrlView:switchDidChanged:status:)]) {
        [self.delegate cardRemoteCtrlView:self switchDidChanged:mwsTopStatusView status:self.status];
    }
}

#pragma mark - G100RTCollectionViewCellDelegate
- (void)cellDidTapped:(G100RTCollectionViewCell *)viewCell indexPath:(NSIndexPath *)indexPath {
    if (_status == 0 || _isCommandSending) {
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(cardRemoteCtrlView:commandViewDidTapped:)]) {
        [self.delegate cardRemoteCtrlView:self commandViewDidTapped:viewCell];
    }
}

#pragma mark - Setter/Getter 
- (void)setRtStatus:(int)rtStatus {
    _rtStatus = rtStatus;
    
    if (_rtStatus == 0) {
        // 非正常状态
        self.status = 0;
        self.topStatusView.mwsSwitch.mws_enable = NO;
        self.ctrlBtnsView.backgroundColor = [UIColor darkGrayColor];
    }else if (_rtStatus == 1)  {
        self.status = 1;
        self.topStatusView.mwsSwitch.mws_enable = YES;
        self.ctrlBtnsView.backgroundColor = kBLELineColor;
    }else if (_rtStatus == 2)  {
        self.status = 2;
        self.topStatusView.mwsSwitch.mws_enable = YES;
        self.ctrlBtnsView.backgroundColor = kGPRSLineColor;
    }else if (_rtStatus == 3) {
        // 同时拥有两种远程控制 优先使用蓝牙控制
        self.status = 1;
        [self.topStatusView setMwsSwitchStatus:0];
    }
    
    [self.topStatusView setStatus:_rtStatus];
    //[self reloadData];
}

- (void)setStatus:(int)status {
    _status = status;
    
    if (_status == 0) {
        // 非正常状态
        self.topStatusView.mwsSwitchStatus = 1;
        self.topStatusView.mwsSwitch.mws_enable = NO;
        self.ctrlBtnsView.backgroundColor = [UIColor darkGrayColor];
    }else if (_status == 1)  {
        self.topStatusView.mwsSwitchStatus = 0;
        self.topStatusView.mwsSwitch.mws_enable = YES;
        self.ctrlBtnsView.backgroundColor = kBLELineColor;
    }else if (_status == 2)  {
        self.topStatusView.mwsSwitchStatus = 1;
        self.topStatusView.mwsSwitch.mws_enable = YES;
        self.ctrlBtnsView.backgroundColor = kGPRSLineColor;
    }
    
    [self reloadData];
}

- (void)setIsCommandSending:(BOOL)isCommandSending {
    _isCommandSending = isCommandSending;
    for (G100RTCollectionViewCell *cell in [self.ctrlBtnsView visibleCells]) {
        cell.rtEnabled = !_isCommandSending;
    }
}

- (void)reloadData {
    [self.ctrlBtnsView reloadData];
    [self setNeedsDisplay];
}

#pragma mark - 准备控制器相关数据源
- (void)prepareGPSData {
    [_dataGPSArray removeAllObjects];
    
    [_dataGPSArray addObject:[G100RTCommandModel rt_commandEmpty]];
    [_dataGPSArray addObject:[G100RTCommandModel rt_commandEmpty]];
}

- (void)prepareBLEData {
    [_dataBLEArray removeAllObjects];
    
    [_dataGPSArray addObject:[G100RTCommandModel rt_commandEmpty]];
    [_dataGPSArray addObject:[G100RTCommandModel rt_commandEmpty]];
}

- (NSMutableArray *)dataGPSArray {
    if (!_dataGPSArray) {
        _dataGPSArray = [[NSMutableArray alloc] init];
        [self prepareGPSData];
    }
    return _dataGPSArray;
}

- (NSMutableArray *)dataBLEArray {
    if (!_dataBLEArray) {
        _dataBLEArray = [[NSMutableArray alloc] init];
        [self prepareBLEData];
    }
    return _dataBLEArray;
}

- (NSMutableDictionary *)cellIdentifierDict {
    if (!_cellIdentifierDict) {
        _cellIdentifierDict = [[NSMutableDictionary alloc] init];
    }
    return _cellIdentifierDict;
}

#pragma mark - Public Method
+ (CGFloat)heightForItem:(id)item width:(CGFloat)width {
    G100DeviceDomain *devDomain = nil;
    if ([item isKindOfClass:[G100DeviceDomain class]]) {
        devDomain = (G100DeviceDomain *)item;
    }else if ([item isKindOfClass:[G100CardModel class]]) {
        devDomain = ((G100CardModel *)item).device;
    }
    
    NSArray *func = devDomain.func.alertor.remote_ctrl_func;
    
    if (devDomain.remote_ctrl_mode == 1) {
        CGFloat topH = kTopViewH;
        CGFloat bottomH = width/4.0*2/itemW2HRatio;
        return topH + bottomH + 1;
    }
    
    NSInteger count = 0;
    for (NSNumber * result in func) {
        if ([result integerValue] == 1) {
            count++;
        }
    }
    
    CGFloat topH = kTopViewH;
    CGFloat bottomH = width/4.0*(count/4+(count%4 > 0 ? 1 : 0))/itemW2HRatio;
    return topH + bottomH + 1;
}

- (void)mws_setupGPRS_signalLevel:(int)level {
    [self.topStatusView mws_setupGPRS_signalLevel:level];
}
- (void)mws_setupBLE_signalLevel:(int)level {
    [self.topStatusView mws_setupBLE_signalLevel:level];
}
- (void)mws_setupCardTitle:(NSString *)cardTitle {
    [self.topStatusView mws_setupCardTitle:cardTitle];
}
- (void)mws_setupCardDetail:(NSString *)cardDetail {
    [self.topStatusView mws_setupCardDetail:cardDetail];
}
- (void)mws_setupSecurityStatus:(int)status {
    [self.topStatusView mws_setupSecurityStatus:status];
}

@end

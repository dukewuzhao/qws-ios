//
//  G100BuyServiceViewController.m
//  G100
//
//  Created by 曹晓雨 on 2016/10/21.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import "G100BuyServiceViewController.h"
#import "G100AllGoodsDomain.h"
#import "G100GoodsApi.h"
#import "G100InfoHelper.h"
#import "G100BuyServiceDevTypeCollectionViewCell.h"
#import "G100PriceCollectionViewCell.h"
#import "G100DeviceDomain.h"
#import "G100GoodDomain.h"
#import "G100OrderApi.h"
#import "G100PayOrderViewController.h"
#import "G100OrderHandler.h"
#import "NSString+CalHeight.h"

static NSString *DEVTYPEREUSEINDENTIFIE = @"G100BuyServiceDevTypeCollectionViewCell";
static NSString *PRICEREUSEINDETIFIE = @"G100PriceCollectionViewCell";
static NSString *ORDERSUCCESS = @"G100BuyServiceOrderSuccess";

typedef NSComparisonResult (^NSComparator)(id obj1, id obj2);

@interface G100BuyServiceViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, OrderServiceDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSMutableDictionary *localDataDic;
@property (nonatomic, strong) G100AllGoodsDomain *allGoods;
@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSMutableArray *allDomainArr;

@property (nonatomic, strong) NSArray *allDevsArr;
@property (strong, nonatomic) G100DeviceDomain   * selectDev;
@property (strong, nonatomic) G100GoodDomain     * selectGood;
@property (nonatomic, strong) NSMutableIndexSet *selectedIndexSet;
@property (nonatomic, assign) NSInteger amount;
@property (nonatomic, assign) CGFloat totalAmount;
@property (nonatomic, strong) NSString *orderNumber;
@property (nonatomic, strong) NSMutableArray *payAvailableArr;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat lastCellHeight;
@property (nonatomic, strong) NSIndexPath *indexpathOfselectDev;
@property (nonatomic, assign) CGFloat priceCellHeight;
@property (nonatomic, strong) NSMutableArray *priceCellHeightArr;
@property (nonatomic, strong) NSMutableArray *devCellHeightArr;
@property (nonatomic, strong) NSMutableArray *enableBuyServiceArr;

@end

@implementation G100BuyServiceViewController

- (void)dealloc {
    NSLog(@"购买服务界面已释放");
}

#pragma mark - setupView
- (void)initView {
    if (!_collectionView) {
        self.layout = [[UICollectionViewFlowLayout alloc]init];
        self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.layout.itemSize = CGSizeMake((WIDTH - 50)/2, 70);
        self.layout.minimumLineSpacing = 6;
        self.layout.sectionInset = UIEdgeInsetsMake(10, 20, 6, 20);
        self.layout.headerReferenceSize = CGSizeMake(WIDTH, 30);
        self.collectionView.scrollEnabled = YES;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.v_width, self.contentView.v_height) collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
        [ self.collectionView registerNib:[UINib nibWithNibName:@"G100BuyServiceDevTypeCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:DEVTYPEREUSEINDENTIFIE];
        [self.collectionView registerNib:[UINib nibWithNibName:@"G100PriceCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:PRICEREUSEINDETIFIE];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
        [self.contentView addSubview:_collectionView];
    }
}
- (void)setupNavigationBarView {
    [self setNavigationTitle:@"延长服务期"];
}

- (void)initLocData {
    if (!_localDataDic) {
        _localDataDic = [[NSMutableDictionary alloc] init];
    }
    if (!_allDomainArr) {
        _allDomainArr = [[NSMutableArray alloc] init];
    }
    if (!_allDevsArr) {
        _allDevsArr = [[NSMutableArray alloc] init];
    }
    if (!_priceCellHeightArr) {
        _priceCellHeightArr = [NSMutableArray array];
    }
    if (!_devCellHeightArr) {
        _devCellHeightArr = [NSMutableArray array];
    }
    if (!_enableBuyServiceArr) {
        _enableBuyServiceArr = [NSMutableArray array];
    }
    
    _payAvailableArr = [[NSMutableArray alloc] init];
    _titleArr = @[ @"请选择设备", @"请选择续费套餐" ];
    
    self.priceCellHeight = 90;
}

- (void)initData {
    if (!_bikeid.length) {
        // 列出所有车辆的所有设备
        NSArray *bikelist = [[G100InfoHelper shareInstance] findMyBikeListWithUserid:self.userid];
        NSMutableArray *alldevs = [NSMutableArray array];
        for (G100BikeDomain *bikeDomain in bikelist) {
            [alldevs addObjectsFromArray:bikeDomain.gps_devices];
        }
        
        _allDevsArr = alldevs.copy;
        [_allDomainArr setObject:_allDevsArr atIndexedSubscript:0];
        
        _selectDev = _allDevsArr.firstObject;
    } else if (!_devid.length) {
        _allDevsArr = [[G100InfoHelper shareInstance] findMyDevListWithUserid:self.userid bikeid:self.bikeid];
        [_allDomainArr setObject:_allDevsArr atIndexedSubscript:0];
        
        [_enableBuyServiceArr removeAllObjects];
        for (G100DeviceDomain *deviceDomain in _allDevsArr) {
            BOOL enableSubmit =   [self enableSubmitOfDeviceDomain:deviceDomain];
            if (enableSubmit) {
                [_enableBuyServiceArr addObject:deviceDomain];
            }
        }
        
        if (_indexpathOfselectDev) {
            _selectDev = [_allDevsArr safe_objectAtIndex:_indexpathOfselectDev.item];
        } else {
            _selectDev = _enableBuyServiceArr.firstObject;
        }
    } else {
        if (_fromVc.intValue == 1) {
            [_enableBuyServiceArr removeAllObjects];
            _allDevsArr = [[G100InfoHelper shareInstance] findMyDevListWithUserid:self.userid bikeid:self.bikeid];
            _selectDev = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
            [_allDomainArr setObject:_allDevsArr atIndexedSubscript:0];
            if (_selectDev) {
                [_enableBuyServiceArr addObject:_selectDev];
            }
        } else {
            _selectDev = [[G100InfoHelper shareInstance] findMyDevWithUserid:self.userid bikeid:self.bikeid devid:self.devid];
            NSMutableArray *tmpArr = [[NSMutableArray alloc]init];
            if (_selectDev) {
                [tmpArr addObject:_selectDev];
                [_enableBuyServiceArr addObject:_selectDev];
            }
            [_allDomainArr setObject:tmpArr atIndexedSubscript:0];
        }
    }
    
    // 计算设备View 行高
    [self.devCellHeightArr removeAllObjects];
    for (G100DeviceDomain *domain in [_allDomainArr safe_objectAtIndex:0]) {
        CGFloat res = [G100BuyServiceDevTypeCollectionViewCell heightForItem:domain];
        [self.devCellHeightArr addObject:[NSNumber numberWithFloat:res]];
    }
}

#pragma mark - 获取套餐数据
- (void)loadAllGoodShowHUD:(BOOL)showHUD
{
    // 避免商品数量不一致导致崩溃
    [self.priceCellHeightArr removeAllObjects];
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        [self.collectionView.mj_header endRefreshing];
        return;
    }
    
    __weak G100BuyServiceViewController *weakself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [weakself.collectionView.mj_header endRefreshing];
        
        if (showHUD) {
            [weakself hideHud];
        }
        
        if (response.success) {
            weakself.allGoods = [[G100AllGoodsDomain alloc]initWithDictionary:response.data];
            
            if (weakself.allGoods.prods.count) {
                [weakself.allDomainArr setObject:weakself.allGoods.prods atIndexedSubscript:1];
                _selectGood = weakself.allGoods.prods.firstObject;
            } else {
                [weakself.allDomainArr removeAllObjects];
            }
            
            [weakself initData];
        }else {
            if (response) {
                [weakself showHint:response.errDesc];
            }
            weakself.allGoods = nil;
        }
        
        [weakself.collectionView reloadData];
    };
    
    if (showHUD) {
        [self showHudInView:self.contentView hint:@"正在更新"];
    }
    
    if (self.productid.length) {
        [[G100GoodsApi sharedInstance] loadProductListWithType:self.type productid:[self.productid intValue]  devid:self.selectDev.device_id callback:callback];
    } else {
        [[G100GoodsApi sharedInstance] loadProductListWithType:self.type devid:self.selectDev.device_id callback:callback];
    }
}

#pragma mark - collctionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        //从重用池中获取头部
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        
        for (UIView *view in headerView.subviews) {
            [view removeFromSuperview];
        }
        headerView.backgroundColor = [UIColor clearColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, 30)];
        label.text = _titleArr[indexPath.section];
        label.textColor = [UIColor colorWithRed:0.61 green:0.61 blue:0.61 alpha:1];
        label.font = [UIFont systemFontOfSize:14];
        [headerView addSubview:label];
        return headerView;
    }
    else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"footer" forIndexPath:indexPath];
        UIButton *payBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 60, WIDTH - 40, 38)];
        payBtn.backgroundColor = [UIColor colorWithRed:0.13 green:0.72 blue:0 alpha:1];
        payBtn.layer.masksToBounds = YES;
        payBtn.layer.cornerRadius = 8;
        if (!_selectDev) {
            payBtn.alpha = 0.3;
        }
        else {
            payBtn.alpha = 1;
        }
        [payBtn setTitle:@"提交订单" forState:UIControlStateNormal];
        [footerView addSubview:payBtn];
        [payBtn addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
        if (indexPath.section == 0 ) {
            for (UIView *view in footerView.subviews) {
                [view removeFromSuperview];
            }
        }
        return footerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    
    if (section == 1) {
        return CGSizeMake(WIDTH, 220);
    }else {
        return CGSizeZero;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[_allDomainArr safe_objectAtIndex:section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    G100BuyServiceDevTypeCollectionViewCell *devTypeCell = [collectionView dequeueReusableCellWithReuseIdentifier:DEVTYPEREUSEINDENTIFIE forIndexPath:indexPath];
    G100PriceCollectionViewCell *priceCell = [collectionView dequeueReusableCellWithReuseIdentifier:PRICEREUSEINDETIFIE forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if (![self enableSubmitOfDeviceDomain:(G100DeviceDomain *)[(NSArray *)[_allDomainArr safe_objectAtIndex:0] safe_objectAtIndex:indexPath.item]]) {
            if (indexPath.item == 0) {
                //如果第一个设备超过15天 则不选择
                [collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES];
                devTypeCell.selected = NO;
            }
            devTypeCell.userInteractionEnabled = NO;
        }else {
            devTypeCell.userInteractionEnabled = YES;
            if (!_indexpathOfselectDev) {
                NSInteger device = ((G100DeviceDomain *)[[_allDomainArr safe_objectAtIndex:0] safe_objectAtIndex:indexPath.row]).device_id ;
                NSInteger enableBuyServiceDevice =  ((G100DeviceDomain *)[_enableBuyServiceArr safe_objectAtIndex:0]).device_id;
                if ( device == enableBuyServiceDevice ) {
                    [collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                    devTypeCell.selected = YES;
                }
            }else {
                [collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:_indexpathOfselectDev.item inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
                if (indexPath.item == _indexpathOfselectDev.item) {
                    devTypeCell.selected = YES;
                }
            }
        }
        
        devTypeCell.indexPath = indexPath;
        [devTypeCell initUIWithMode:((G100DeviceDomain *)[(NSArray *)[_allDomainArr safe_objectAtIndex:0] safe_objectAtIndex:indexPath.item])];
        //计算行高
        self.cellHeight = [devTypeCell heightForRow];
        return devTypeCell;
    }else {
        [collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        [priceCell initUIWithMode:[[_allDomainArr safe_objectAtIndex:1] safe_objectAtIndex:indexPath.item]];
        
        //所有行高保存在数组中
        if (_priceCellHeightArr.count != [[_allDomainArr safe_objectAtIndex:1] count]) {
            self.priceCellHeight = [priceCell heightForRow];
            [_priceCellHeightArr setObject:[NSNumber numberWithFloat:self.priceCellHeight] atIndexedSubscript:indexPath.item];
            if (_priceCellHeightArr.count == [[_allDomainArr safe_objectAtIndex:1] count]) {
                [self performSelector:@selector(reloadAllData) withObject:nil afterDelay:0.1];
            }
        }
        
        return  priceCell;
    }
}
- (void)reloadAllData
{
    [self.collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self selectActionWithSection:indexPath];
    
    if (indexPath.section == 0) {
        _selectDev = [[_allDomainArr safe_objectAtIndex:0] safe_objectAtIndex:indexPath.item];
        _indexpathOfselectDev = indexPath;
        
        // 刷新设备对应的商品列表
        [self loadAllGoodShowHUD:NO];
    } else if (indexPath.section == 1){
        _selectGood = [[_allDomainArr safe_objectAtIndex:1] safe_objectAtIndex:indexPath.item];
    }
}
- (void)selectActionWithSection:(NSIndexPath *)indexPath
{
    for (NSInteger i = 0; i < [[_allDomainArr safe_objectAtIndex:indexPath.section] count]; i++) {
        if (i == indexPath.item) {
            [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:i
                                                                           inSection:indexPath.section]
                                              animated:YES
                                        scrollPosition:UICollectionViewScrollPositionNone];
        }else {
            [self.collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:i
                                                                             inSection:indexPath.section]
                                                animated:YES];
        }
    }
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item
                                                              inSection:indexPath.section]
                                 animated:YES
                           scrollPosition:UICollectionViewScrollPositionNone];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        // 同一行中高度较高的作为行高
        CGFloat leftH = 0;
        CGFloat rightH = 0;
        
        if (indexPath.item%2 == 0) {
            leftH = [[self.devCellHeightArr safe_objectAtIndex:indexPath.item] floatValue];
            rightH = [[self.devCellHeightArr safe_objectAtIndex:indexPath.item+1] floatValue];
        }else {
            leftH = [[self.devCellHeightArr safe_objectAtIndex:indexPath.item-1] floatValue];
            rightH = [[self.devCellHeightArr safe_objectAtIndex:indexPath.item] floatValue];
        }
        
        return CGSizeMake((WIDTH - 50)/2, MAX(leftH, rightH) + 10);
    }
    else {
        if (self.priceCellHeightArr.count == 0) {
            return CGSizeMake((WIDTH - 50)/2, self.priceCellHeight);
        }else {
            CGFloat cellHeight =  [self.priceCellHeightArr[indexPath.item] floatValue];
            //价格cell自适应高度 只有同一行每个cell相等高度
            if (indexPath.item % 2 == 0) {
                if (indexPath.item != [[self.allDomainArr safe_objectAtIndex:1] count] - 1) {
                    BOOL LeftCellHigher =  [[self.priceCellHeightArr safe_objectAtIndex:indexPath.item] floatValue] > [[self.priceCellHeightArr safe_objectAtIndex:indexPath.item + 1] floatValue];
                    if (LeftCellHigher) {
                        cellHeight = [self.priceCellHeightArr[indexPath.item] floatValue];
                    }else {
                        cellHeight = [self.priceCellHeightArr[indexPath.item + 1] floatValue];
                    }
                }
            }else {
                BOOL LeftCellHigher =  [[self.priceCellHeightArr safe_objectAtIndex:indexPath.item] floatValue] < [[self.priceCellHeightArr safe_objectAtIndex:indexPath.item - 1] floatValue];
                if (LeftCellHigher) {
                    cellHeight = [self.priceCellHeightArr[indexPath.item - 1] floatValue];
                }else {
                    cellHeight = [self.priceCellHeightArr[indexPath.item ] floatValue];
                }
            }
            return CGSizeMake((WIDTH - 50)/2, cellHeight);
        }
    }
}

#pragma mark - Private Method
//超过15天或者是移动特供机不能充值 禁止交互
- (BOOL)enableSubmitOfDeviceDomain:(G100DeviceDomain *)deviceDomain
{
    if (deviceDomain.service.left_days <= -15 || [deviceDomain isSpecialChinaMobileDevice]) {
        return NO;
    }
    return YES;
}
#pragma mark - 提交订单
- (void)commit {
    if (_selectDev) {
        G100OrderHandler *orderHandler = [[G100OrderHandler alloc] initWithDev:_selectDev good:_selectGood bikeid:_bikeid devid:_devid];
        orderHandler.delegate = self;
        [orderHandler commit];
    }
}

#pragma mark - orderHanldler delegate
- (void)orderStatus:(orderStatusEnum)orderStatus msg:(NSString *)message {
    switch (orderStatus) {
        case showHint:
            [self showHint:message];
            break;
        case showWarningHint:
            [self showWarningHint:message];
            break;
        case showHudInView:
            [self showHudInView:self.contentView hint:message];
            break;
        default:
            break;
    }
}

- (void)submmitOrderResult:(ApiResponse *)response requestSucces:(BOOL)requestSucces orderNum:(NSString *)orderNum totalAmount:(CGFloat)totalAmount
{
    [self hideHud];
    if (requestSucces) {
        G100PayOrderViewController *viewController = [G100PayOrderViewController loadXibViewController];
        viewController.userid = self.userid;
        viewController.bikeid = self.bikeid;
        viewController.devid = [NSString stringWithFormat:@"%ld", self.selectDev.device_id];
        viewController.orderid = orderNum;
        [self.navigationController pushViewController:viewController animated:YES];
    }else {
        if (response) {
            [self showHint:response.errDesc];
        }
    }
}

#pragma mark - Lazy load
- (NSString *)type {
    if (!_type) {
        _type = @"1";
    }
    return _type;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initLocData];
    [self initData];
    [self initView];
    
    [self loadAllGoodShowHUD:YES];
    
    __weak G100BuyServiceViewController * weakself = self;
    MJRefreshHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakself loadAllGoodShowHUD:NO];
    }];
    
    header.lastUpdatedTimeKey = NSStringFromClass([self class]);
    self.collectionView.mj_header = header;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

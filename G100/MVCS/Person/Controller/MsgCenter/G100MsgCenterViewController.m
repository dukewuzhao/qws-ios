//
//  G100MsgCenterViewController.m
//  G100
//
//  Created by yuhanle on 16/3/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MsgCenterViewController.h"
#import "G100TwoSwitchView.h"
#import "G100MsgAllSelDeleteView.h"
#import "G100MsgListViewController.h"
#import "DatabaseOperation.h"
#import "NotificationHelper.h"

#define AllSelDeleteBtnHeight   44+kBottomPadding

@interface G100MsgCenterViewController () <G100TwoSwitchDelegate, G100MsgAllSelDeleteViewDelegate, G100MsgListViewDelegate> {
    BOOL _isEditingMode;
    NSInteger _personalUnreadCount;
    NSInteger _systemUnreadCount;
}

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) G100TwoSwitchView *twoSwitchView;
@property (nonatomic, strong) G100MsgAllSelDeleteView *allSelDeleteView;

@property (nonatomic, strong) UIScrollView *listContainer;
@property (nonatomic, strong) G100MsgListViewController *listPersonVC;
@property (nonatomic, strong) G100MsgListViewController *listSystemVC;
@property (nonatomic, strong) G100MsgListViewController *selectedListVC;

@end

@implementation G100MsgCenterViewController

- (void)dealloc {
    DLog(@"消息中心已释放");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGNShowNewMsgSignal object:nil];
}

#pragma mark - lazy load
- (G100MsgListViewController *)listPersonVC {
    if (!_listPersonVC) {
        G100MsgListViewController *vc = [[G100MsgListViewController alloc] init];
        vc.userid = self.userid;
        vc.msgTypeMode = MsgTypeModePersonal;
        vc.delegate = self;
        vc.view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        [self addChildViewController:vc];
        [self.listContainer addSubview:vc.view];
        
        _listPersonVC = vc;
    }
    return _listPersonVC;
}

- (G100MsgListViewController *)listSystemVC {
    if (!_listSystemVC) {
        G100MsgListViewController *vc = [[G100MsgListViewController alloc] init];
        vc.userid = self.userid;
        vc.msgTypeMode = MsgTypeModeSystem;
        vc.delegate = self;
        vc.view.frame = CGRectMake(self.contentView.frame.size.width, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        [self addChildViewController:vc];
        [self.listContainer addSubview:vc.view];
        
        _listSystemVC = vc;
    }
    return _listSystemVC;
}

#pragma mark - 私有方法
- (void)loadMsgData {
    [[DatabaseOperation operation] fetchAllDataWithUserid:[self.userid integerValue] completion:^(NSMutableArray *personalMsgArr, NSMutableArray *systemMsgArr) {
        self.listPersonVC.items = personalMsgArr.mutableCopy;
        self.listSystemVC.items = systemMsgArr.mutableCopy;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
            [self.listPersonVC reloadUIData];
            [self.listSystemVC reloadUIData];
        });
    }];
}

- (void)loadUnreadCountData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[DatabaseOperation operation] countUnreadNumberWithUserid:[self.userid integerValue] success:^(NSInteger personalUnreadNum, NSInteger systemUnreadNum) {
            _personalUnreadCount = personalUnreadNum;
            _systemUnreadCount = systemUnreadNum;
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_twoSwitchView setUnreadCount:_personalUnreadCount forIndex:0];
            [_twoSwitchView setUnreadCount:_systemUnreadCount forIndex:1];
            
            [[NotificationHelper shareInstance] nh_newBadge:_personalUnreadCount + _systemUnreadCount];
        });
    });
}

#pragma mark - 布局元素
- (void)setupNavigationView {
    _twoSwitchView = [[G100TwoSwitchView alloc] initWithTitleArray:@[@"个人", @"系统"] unreadCount:@[@(0), @(0)]];
    _twoSwitchView.delegate = self;
    [self.navigationBarView addSubview:_twoSwitchView];
    
    [_twoSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.navigationBarView).with.offset(@(-10));
        make.centerX.equalTo(self.navigationBarView);
        make.height.equalTo(@28);
        make.width.equalTo(WIDTH*(220.0/414.0));
    }];
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _editButton.titleLabel.font = [UIFont systemFontOfSize:17];
    _editButton.exclusiveTouch = YES;
    _editButton.titleLabel.textColor = [UIColor whiteColor];
    [_editButton setTintColor:[UIColor clearColor]];
    [_editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [_editButton setTitle:@"取消" forState:UIControlStateSelected];
    [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    _editButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_editButton addTarget:self action:@selector(rightNavgationButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setRightNavgationButton:_editButton];
}

- (void)setupContainerView {
    self.listContainer = [[UIScrollView alloc] init];
    self.listContainer.frame = self.contentView.bounds;
    self.listContainer.contentSize = CGSizeMake(self.contentView.frame.size.width * 2, self.contentView.frame.size.height);
    self.listContainer.bounces = NO;
    self.listContainer.scrollEnabled = NO;
    self.listContainer.pagingEnabled = YES;
    [self.contentView addSubview:self.listContainer];
}

- (void)setupAllSelDeleteView {
    _allSelDeleteView = [G100MsgAllSelDeleteView allSelDeleteView];
    _allSelDeleteView.delegate = self;
    _allSelDeleteView.frame = CGRectMake(0, self.contentView.frame.size.height, self.contentView.frame.size.width, AllSelDeleteBtnHeight);
    [self.contentView addSubview:_allSelDeleteView];
}

#pragma mark - 编辑按钮事件
- (void)rightNavgationButtonClick:(UIButton *)button {
    if (self.selectedListVC.items.count == 0) {
        [self showHint:@"暂无消息可编辑"];
        return;
    }
    
    button.selected = !button.selected;
    _isEditingMode = button.selected;
    if (button.selected) {
        [_allSelDeleteView showAllSelDeleteView];
        [self.selectedListVC enterEditMode];
    }else {
        [_allSelDeleteView hideAllSelDeleteView];
        [self.selectedListVC exitEditMode];
    }
}

#pragma mark - G100TwoSwitchViewDelegate
- (void)switchView:(G100TwoSwitchView *)switchView didSwitchButtonFrom:(NSInteger)from to:(NSInteger)to {
    self.editButton.selected = NO;
    [self.allSelDeleteView hideAllSelDeleteView];
    [self.selectedListVC exitEditMode];
    if (to == 0) {
        self.selectedListVC = self.listPersonVC;
        [self.listContainer setContentOffset:CGPointMake(0, 0) animated:YES];
    } else if (to == 1) {
        self.selectedListVC = self.listSystemVC;
        [self.listContainer setContentOffset:CGPointMake(self.contentView.frame.size.width, 0) animated:YES];
    }
}

#pragma mark - G100AllSelDeleteViewDelegate
- (void)msgAllSelDeleteViewWillAppear {
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.editButton.enabled = NO;
}

- (void)msgAllSelDeleteViewDidAppear {
    self.editButton.enabled = YES;
}

- (void)msgAllSelDeleteViewWillDisAppear {
    self.editButton.enabled = NO;
}

- (void)msgAllSelDeleteViewDidDisAppear {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.editButton.enabled = YES;
}

- (void)msgAllSelDeleteView:(G100MsgAllSelDeleteView *)selDeleteView index:(NSInteger)index sender:(UIButton *)sender {
    if (index == 0) {
        /* 全选 */
        if (sender.selected) {
            [self.selectedListVC selectAllItems];
        } else {
            [self.selectedListVC unSelectAllItems];
        }
    }else if (index == 1) {
        /* 删除 */
        [self.selectedListVC deleteItems];
    }
}

#pragma mark - 返回-退出编辑模式
- (void)actionClickNavigationBarLeftButton {
    if (self.selectedListVC.listView.editing == YES) {
        self.selectedListVC.listView.editing = NO;
    }
    
    [super actionClickNavigationBarLeftButton];
}

#pragma mark - G100MsgListViewDelegate
- (void)msg_needReloadFromDB {
    [self loadUnreadCountData];
}

- (void)msg_updateSelectAllStatus:(BOOL)all {
    [self.allSelDeleteView allSelectStatus:all];
}

- (void)msg_deleteFinished {
    self.editButton.selected = NO;
    _isEditingMode = NO;
    
    [_allSelDeleteView hideAllSelDeleteView];
    [self.selectedListVC exitEditMode];
}

#pragma mark - 添加观察者
- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getNewOfflineMessage)
                                                 name:kGNShowNewMsgSignal
                                               object:nil];
}

- (void)getNewOfflineMessage {
    [self loadUnreadCountData];
    [self loadMsgData];
    
    [[G100InfoHelper shareInstance] updateCurrentUserNewMsgCountWithUserId:self.userid
                                                                   hasRead:OfflineMsgReadStatusAll
                                                          needNotification:NO];
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserver];
    [self setupNavigationView];
    [self setupContainerView];
    [self setupAllSelDeleteView];
    
    [self showHudInView:self.view hint:@""];
    [self getNewOfflineMessage];
    
    self.selectedListVC = self.listPersonVC;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

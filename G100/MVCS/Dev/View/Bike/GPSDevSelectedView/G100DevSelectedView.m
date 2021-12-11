//
//  G100DevSelectedView.m
//  G100
//
//  Created by yuhanle on 2016/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevSelectedView.h"
#import "G100DevOptionCell.h"
#import "G100DeviceDomain.h"

static CGFloat IndexBtnWidth = 40;
static CGFloat IndexBtnHeight = 48;

static CGFloat DetailBtnWidth = 200;


@interface G100DevSelectedView () <UITableViewDelegate, UITableViewDataSource, G100DevOptionCellDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITableView *indexTableView;
@property (nonatomic, strong) UITableView *detailTableView;
@property (nonatomic, strong) UIView *seperatorLine;
@property (nonatomic, strong) UIButton *menuButton;

@property (nonatomic, assign) NSInteger selectedIndex; //!< 选中的索引

@end

@implementation G100DevSelectedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.openState = 0;
        self.selectedIndex = -1;
        
        [self setupView];
    }
    return self;
}

- (void)setupView {
    // 添加一个容器 两个table 还有一个菜单btn
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.detailTableView];
    [self.containerView addSubview:self.indexTableView];
    [self.containerView addSubview:self.menuButton];
    [self.containerView addSubview:self.seperatorLine];
}

#pragma mark - Lazy load
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    return _containerView;
}

- (UITableView *)indexTableView {
    if (!_indexTableView) {
        _indexTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _indexTableView.delegate = self;
        _indexTableView.dataSource = self;
        _indexTableView.bounces = NO;
        
        [_indexTableView setBackgroundColor:[UIColor colorWithHexString:@"000000" alpha:0.7f]];
        [_indexTableView registerNib:[UINib nibWithNibName:@"G100DevOptionCell" bundle:nil] forCellReuseIdentifier:@"DevOptionCell"];
        [_indexTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _indexTableView;
}

- (UITableView *)detailTableView {
    if (!_detailTableView) {
        _detailTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _detailTableView.delegate = self;
        _detailTableView.dataSource = self;
        _detailTableView.bounces = NO;
        
        [_detailTableView setBackgroundColor:[UIColor colorWithHexString:@"000000" alpha:0.7f]];
        [_detailTableView registerNib:[UINib nibWithNibName:@"G100DevOptionCell" bundle:nil] forCellReuseIdentifier:@"DevOptionCell"];
        [_detailTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _detailTableView;
}

- (UIView *)seperatorLine {
    if (!_seperatorLine) {
        _seperatorLine = [[UIView alloc] init];
        _seperatorLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _seperatorLine;
}

- (UIButton *)menuButton {
    if (!_menuButton) {
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_menuButton setImage:[UIImage imageNamed:@"ic_devselected_menu_more"] forState:UIControlStateNormal];
        [_menuButton setImage:[UIImage imageNamed:@"ic_devselected_menu_close"] forState:UIControlStateSelected];
        [_menuButton setBackgroundColor:[UIColor colorWithHexString:@"000000" alpha:0.7f]];
        [_menuButton addTarget:self action:@selector(menuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuButton;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100DevOptionCell *resultCell = [tableView dequeueReusableCellWithIdentifier:@"DevOptionCell"];
    
    G100DeviceDomain *domain = [self.dataArray safe_objectAtIndex:indexPath.row];
    resultCell.selectionStyle = UITableViewCellSelectionStyleNone;
    resultCell.backgroundColor = [UIColor clearColor];
    
    resultCell.totalCount = self.dataArray.count;
    resultCell.delegate = self;
    resultCell.device = domain;
    
    if (indexPath.row == self.selectedIndex) {
        resultCell.selectedStatus = YES;
    }else {
        resultCell.selectedStatus = NO;
    }
    
    return resultCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_delegate respondsToSelector:@selector(G100DevSelectedView:device:)]) {
        G100DeviceDomain *domain = [self.dataArray safe_objectAtIndex:indexPath.row];
        [self.delegate G100DevSelectedView:self device:domain];
    }
    
    self.selectedIndex = indexPath.row;
    
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return IndexBtnHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

#pragma mark - G100DevOptionCellDelegate
- (void)G100DevOptionCell:(G100DevOptionCell *)optionCell device:(G100DeviceDomain *)device visibleState:(BOOL)visibleState {
    if ([_delegate respondsToSelector:@selector(G100DevSelectedView:device:visiableState:)]) {
        [self.delegate G100DevSelectedView:self device:device visiableState:visibleState];
    }
}

- (BOOL)G100DevOptionCell:(G100DevOptionCell *)optionCell visibleDevice:(G100DeviceDomain *)device {
    if ([_delegate respondsToSelector:@selector(G100DevSelectedView:visibleDevice:)]) {
        return [self.delegate G100DevSelectedView:self visibleDevice:device];
    }
    
    return NO;
}

#pragma mark - Public Method
- (void)setAcpoint:(CGPoint)acpoint {
    _acpoint = acpoint;
    
    [self layoutIfNeeded];
    [self layoutSubviews];
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    [self.indexTableView reloadData];
    [self.detailTableView reloadData];
    
    [self layoutIfNeeded];
    [self layoutSubviews];
}

- (void)invertSelection {
    self.selectedIndex = -1;
    
    [self.indexTableView reloadData];
    [self.detailTableView reloadData];
}

- (void)selectedDeviceAtIndex:(NSInteger)index {
    self.selectedIndex = index;
    
    [self.indexTableView reloadData];
    [self.detailTableView reloadData];
}

#pragma mark - Private Method
- (void)menuButtonClick:(UIButton *)button {
    _openState = !self.openState;
    
    [self layoutIfNeeded];
    [self layoutSubviews];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (!CGRectContainsPoint(self.containerView.frame, point)) {
        _openState = !self.openState;
        
        [self layoutIfNeeded];
        [self layoutSubviews];
    }
}

#pragma mark - Layout SubViews
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.openState == G100DevSelectedViewOpenStateClose) {
        // 显示索引
        CGRect result = CGRectMake(self.acpoint.x - IndexBtnWidth, self.acpoint.y, IndexBtnWidth, IndexBtnHeight*self.dataArray.count + IndexBtnHeight);
        self.frame = result;
        
        self.containerView.frame = self.bounds;
        
        CGRect frame = self.containerView.bounds;
        frame.size.height -= IndexBtnHeight;
        
        self.indexTableView.frame = frame;
        
        frame.origin.y = IndexBtnHeight*self.dataArray.count;
        frame.origin.x = 2;
        frame.size.width = IndexBtnWidth - 4;
        frame.size.height = 0.5;
        
        self.seperatorLine.frame = frame;
        
        frame.origin.x = 0;
        frame.origin.y = IndexBtnHeight*self.dataArray.count;
        frame.size.width = IndexBtnWidth;
        frame.size.height = IndexBtnHeight;
        
        self.menuButton.frame = frame;
        
        self.detailTableView.alpha = 0.0;
        self.indexTableView.alpha = 1.0;
        
        if ([self superview]) {
            [[self superview] insertSubview:self atIndex:1];
        }
        
        self.menuButton.selected = NO;
    }else {
        // 显示详情
        CGRect result = CGRectMake(self.acpoint.x - DetailBtnWidth, self.acpoint.y - (kNavigationBarHeight - 44), DetailBtnWidth, IndexBtnHeight*self.dataArray.count + IndexBtnHeight);
        self.frame = [[self superview] frame];
        
        self.containerView.frame = result;
        
        CGRect frame = self.containerView.bounds;
        frame.size.height -= IndexBtnHeight;
        
        self.detailTableView.frame = frame;
        
        frame.origin.y = IndexBtnHeight*self.dataArray.count;
        frame.origin.x = DetailBtnWidth - IndexBtnWidth + 2;
        frame.size.width = IndexBtnWidth - 4;
        frame.size.height = 0.5;
        
        self.seperatorLine.frame = frame;
        
        frame.origin.x = DetailBtnWidth - IndexBtnWidth;
        frame.origin.y = IndexBtnHeight*self.dataArray.count;
        frame.size.width = IndexBtnWidth;
        frame.size.height = IndexBtnHeight;
        
        self.menuButton.frame = frame;
        
        self.detailTableView.alpha = 1.0;
        self.indexTableView.alpha = 0.0;
        
        if ([self superview]) {
            [[self superview] bringSubviewToFront:self];
        }
        
        self.menuButton.selected = YES;
    }
    
    [self.indexTableView.layer.mask removeFromSuperlayer];
    [self.detailTableView.layer.mask removeFromSuperlayer];
    [self.menuButton.layer.mask removeFromSuperlayer];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.indexTableView.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(6.0f, 6.0f)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.indexTableView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.indexTableView.layer.mask = maskLayer;
    
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:self.detailTableView.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft
                                                         cornerRadii:CGSizeMake(6.0f, 6.0f)];
    CAShapeLayer *maskLayer1 = [CAShapeLayer layer];
    maskLayer1.frame = self.detailTableView.bounds;
    maskLayer1.path = maskPath1.CGPath;
    self.detailTableView.layer.mask = maskLayer1;
    
    UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:self.menuButton.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(6.0f, 6.0f)];
    CAShapeLayer *maskLayer2 = [CAShapeLayer layer];
    maskLayer2.frame = self.menuButton.bounds;
    maskLayer2.path = maskPath2.CGPath;
    self.menuButton.layer.mask = maskLayer2;
}

@end

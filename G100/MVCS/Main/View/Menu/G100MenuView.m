//
//  G100MenuView.m
//  G100
//
//  Created by William on 16/6/27.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MenuView.h"
#import "G100MenuHeaderView.h"
#import "G100MenuCell.h"
#import "InsuranceCheckService.h"

#import "G100EventDomain.h"
#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>
#import "MenuItem.h"

#define PAN_DURATION 0.2f
#define DURATION 0.4f
#define MENU_WIDTH (WIDTH * 0.8)
#define BACKGROUND_ALPHA 0.2
#define SHADOW_OPACITY 0.9

@interface G100MenuView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, CAAnimationDelegate> {
    CGFloat _initialLocation;/* 滑动手势初始位置 */
    CGFloat _maxX;/* 滑动手势X轴方向最大值 */
    NSInteger _messageNum;/* 未读消息数量 */
}

@property (nonatomic, strong) UIView * contentView;
@property (nonatomic, strong) UITableView * menuTableView;
@property (nonatomic, strong) UITapGestureRecognizer * tap;
@property (nonatomic, strong) UIPanGestureRecognizer * pan;
@property (nonatomic, strong) G100MenuHeaderView * menuHeaderView;

/** 右下角活动容器*/
@property (nonatomic, strong) UIView *activityView;

@end

@implementation G100MenuView

#pragma mark - Lazy loading
- (G100MenuHeaderView *)menuHeaderView {
    if (!_menuHeaderView) {
        __weak G100MenuView * wself = self;
        _menuHeaderView = [G100MenuHeaderView loadMenuHeaderView];
        _menuHeaderView.userActionTap = ^(NSInteger index){
            if (wself.userActionTap) {
                wself.userActionTap(index);
            }
        };
    }
    return _menuHeaderView;
}

- (UITapGestureRecognizer *)tap {
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        _tap.delegate = self;
    }
    return _tap;
}

- (UIPanGestureRecognizer *)pan {
    if (!_pan) {
        _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    }
    return _pan;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(-MENU_WIDTH, 0, MENU_WIDTH, HEIGHT)];
    }
    return _contentView;
}

- (UITableView *)menuTableView {
    if (!_menuTableView) {
        _menuTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _menuTableView.delegate = self;
        _menuTableView.dataSource = self;
        _menuTableView.bounces = NO;
        _menuTableView.estimatedRowHeight = 0;
        _menuTableView.estimatedSectionHeaderHeight = 0;
        _menuTableView.estimatedSectionFooterHeight = 0;
        _menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuTableView.backgroundColor = [UIColor colorWithHexString:@"303030"];
        [self.contentView addSubview:_menuTableView];
    }
    return _menuTableView;
}

- (UIView *)activityView {
    if (!_activityView) {
        _activityView = [[UIView alloc] initWithFrame:CGRectZero];
        _activityView.backgroundColor = [UIColor clearColor];
    }
    return _activityView;
}

- (void)setUserid:(NSString *)userid {
    _userid = userid;
    // 设置侧边栏头视图
    self.menuHeaderView.userid = userid;
}
- (void)setMenuItemArr:(NSArray<MenuItem *> *)menuItemArr{
    _menuItemArr = menuItemArr;
    [self.menuTableView reloadData];
}
#pragma mark - init
- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        self.contentView.alpha = 0;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(10, 0);
        self.layer.shadowRadius = 10;
        self.layer.shadowOpacity = 0.0;
        self.hidden = YES;
        
        [self setupView];
        
        [self.KVOController observe:[InsuranceCheckService sharedService] keyPath:@"totalCount" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            [self.menuTableView reloadData];
        }];
    }
    return self;
}

- (void)setupView {
    [self addGestureRecognizer:self.tap];
    [self addGestureRecognizer:self.pan];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.menuHeaderView];
    [self.menuHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(@0);
        make.height.equalTo(@(MENU_WIDTH*0.7));
    }];
    
    [self.contentView addSubview:self.menuTableView];
    [self.menuTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.menuHeaderView.mas_bottom);
        make.left.right.bottom.equalTo(@0);
    }];
    UIButton * settingsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsBtn setImage:[UIImage imageNamed:@"menu_settings"] forState:UIControlStateNormal];
    [settingsBtn addTarget:self action:@selector(goSettingsAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:settingsBtn];
    [settingsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@50);
        make.left.equalTo(@20);
        make.bottom.equalTo(@-20);
    }];
    
    UILabel * settingsLabel = [[UILabel alloc]init];
    settingsLabel.textColor = [UIColor whiteColor];
    settingsLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    settingsLabel.text = @"设置";
    [self.contentView addSubview:settingsLabel];
    [settingsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(settingsBtn.mas_right).offset(@10);
        make.centerY.equalTo(settingsBtn.mas_centerY);
    }];
    
    [self.contentView bringSubviewToFront:self.menuHeaderView];
    
    [self.contentView addSubview:self.activityView];
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@62);
        make.width.equalTo(@51);
        make.trailing.equalTo(@-10);
        make.bottom.equalTo(@-20);
    }];
    
    // 活动时间按钮 添加抖动动画
    [self scalEventBtnAnimation];
    self.activityView.hidden = YES;
}

- (void)setDelegate:(id<G100MenuViewDelegate>)delegate {
    _delegate = delegate;
    __weak __typeof__(self) weakSelf = self;
    __weak __typeof__(id<G100MenuViewDelegate>) weakDelegate = _delegate;
    _menuHeaderView.headerTapClick = ^(){
        if ([weakDelegate respondsToSelector:@selector(menuView:didSelectRowAtIndexPath:menuItem:)]) {
            [weakDelegate menuView:weakSelf didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1000 inSection:1000] menuItem:nil];
        }
    };
}

- (void)setEventDomain:(G100EventDomain *)eventDomain {
    NSMutableArray *result = [NSMutableArray array];
    for (G100EventDetailDomain *detail in eventDomain.events) {
        if (detail.control.icon) {
            [result addObject:detail];
        }
    }
    
    eventDomain.events = result.copy;
    
    _eventDomain = eventDomain;
    
    // 布局活动入口信息
    [self.activityView removeAllSubviews];
    
    if (![eventDomain.events count]) {
        self.activityView.hidden = YES;
    }else {
        self.activityView.hidden = NO;
        
        // 布局活动信息 只显示前两个活动
        NSInteger count = [eventDomain.events count] <= 2 ? [eventDomain.events count] : 2;
        
        CGFloat right = 0;
        for (NSInteger i = 0; i < count; i++) {
            G100EventDetailDomain *detail = [eventDomain.events safe_objectAtIndex:i];
            
            __block UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 100+i;
            [btn addTarget:self action:@selector(eventDatailBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.activityView addSubview:btn];
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(@62);
                make.width.equalTo(@51);
                make.trailing.equalTo(right);
                make.centerY.equalTo(@0);
            }];
            
            [btn sd_setImageWithURL:[NSURL URLWithString:detail.icon] forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image && !error) {
                    CGFloat h = image.size.height / image.size.width / 1.0 * 51;
                    [btn mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.height.equalTo(h);
                    }];
                }
            }];
            
            right -= 61;
        }
        
        [self.activityView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(51*count+10*(count-1));
        }];
    }
}

#pragma mark - display
- (void)showMenuWithPanAction:(BOOL)isPanAction {
    [self changeMenuState:NO panAction:isPanAction];
}

- (void)hideMenuWithPanAction:(BOOL)isPanAction; {
    [self changeMenuState:YES panAction:isPanAction];
}

- (void)changeMenuState:(BOOL)isOpen panAction:(BOOL)isPanAction{
    if (!isOpen) {
        self.hidden = NO;
        if ([_delegate respondsToSelector:@selector(menuViewShouldStartOpening:)]) {
            [self.delegate menuViewShouldStartOpening:self];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }else{
        if ([_delegate respondsToSelector:@selector(menuViewShouldStartClosing:)]) {
            [self.delegate menuViewShouldStartClosing:self];
        }
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
    
    CGFloat x = isOpen?-MENU_WIDTH:0;
    
    [UIView animateWithDuration:isPanAction?PAN_DURATION:DURATION animations:^{
        self.contentView.frame = CGRectMake(x, 0, MENU_WIDTH, HEIGHT);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:isOpen?0:BACKGROUND_ALPHA];
        self.contentView.alpha = isOpen?0:1;
        self.layer.shadowOpacity = isOpen?0:SHADOW_OPACITY;
    } completion:^(BOOL finished) {
        if (finished) {
            if (!isOpen) {
                if ([_delegate respondsToSelector:@selector(menuViewDidOpened:)]) {
                    [self.delegate menuViewDidOpened:self];
                }
                self.isOpen = YES;
            }else{
                if ([_delegate respondsToSelector:@selector(menuViewDidClosed:)]) {
                    [self.delegate menuViewDidClosed:self];
                }
                self.isOpen = NO;
                self.hidden = YES;
                
            }
        }else {
            // 不知道为什么 会存在未完成的情况 被打断
            if (!isOpen) {
                if ([_delegate respondsToSelector:@selector(menuViewDidOpened:)]) {
                    [self.delegate menuViewDidOpened:self];
                }
                self.isOpen = YES;
            }else{
                if ([_delegate respondsToSelector:@selector(menuViewDidClosed:)]) {
                    [self.delegate menuViewDidClosed:self];
                }
                self.isOpen = NO;
                self.hidden = YES;
                
            }
        }
    }];
}

/** 缩放动画*/
- (void)scalEventBtnAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:1.1];
    animation.duration = 0.6f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.removedOnCompletion = YES;
    animation.autoreverses = NO;
    animation.delegate = self;
    [self.activityView.layer addAnimation:animation forKey:@"scalebtn"];
}
/* 抖动动画*/
- (void)shakeAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 0.06;
    animation.fromValue = @(-0.1/2);
    animation.toValue = @(0.1/2);
    animation.repeatCount = 3;
    animation.removedOnCompletion = YES;
    animation.autoreverses = YES;
    animation.delegate = self;
    [self.activityView.layer addAnimation:animation forKey:@"scalebtn"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([anim isKindOfClass:[CABasicAnimation class]]) {
        CABasicAnimation *ban = (CABasicAnimation *)anim;
        if ([ban.keyPath isEqualToString:@"transform.scale"]) {
            [self shakeAnimation];
        }else if ([ban.keyPath isEqualToString:@"transform.rotation.z"]) {
            [self performSelector:@selector(scalEventBtnAnimation) withObject:nil afterDelay:0.6];
        }
    }
}

#pragma mark - action
- (void)goSettingsAction {
    if ([_delegate respondsToSelector:@selector(menuView:didSelectRowAtIndexPath:menuItem:)]) {
        [self.delegate menuView:self didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:2000 inSection:2000]menuItem:nil];
    }
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
    if (!CGRectContainsPoint(self.contentView.frame, location)) {
        if (recognizer.state == UIGestureRecognizerStateEnded) {
            [self hideMenuWithPanAction:NO];
        }
    }
}

- (void)pan:(UIPanGestureRecognizer *)recognizer {
    [self configViewWithGesture:recognizer];
}

- (void)configViewWithGesture:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _initialLocation = location.x;
    }
    
    CGFloat changedX = _initialLocation - location.x;
    
    if (ABS(changedX) > ABS(_maxX)) {
        _maxX = changedX;
    }
    
    if (changedX > 0 && changedX <= MENU_WIDTH && ![recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:((MENU_WIDTH -changedX) / MENU_WIDTH) * BACKGROUND_ALPHA];
        self.contentView.alpha = (MENU_WIDTH -changedX) / MENU_WIDTH;
        self.layer.shadowOpacity = ((MENU_WIDTH -changedX) / MENU_WIDTH) * SHADOW_OPACITY;
        [self.contentView setV_origin:CGPointMake(-changedX, 0)];
    }else if (changedX < 0 && changedX >= -MENU_WIDTH && [recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        self.hidden = NO;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:(-changedX / MENU_WIDTH) * BACKGROUND_ALPHA];
        self.contentView.alpha = -changedX / MENU_WIDTH;
        self.layer.shadowOpacity = (-changedX / MENU_WIDTH) * SHADOW_OPACITY;
        [self.contentView setV_origin:CGPointMake(-(MENU_WIDTH+changedX), 0)];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [recognizer velocityInView:self];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x));
        CGFloat slideMult = magnitude / 200;
        if (slideMult > 3.0) { //X轴滑动速度
            if (changedX<0) {
                if (changedX - _maxX > 0) {
                    [self hideMenuWithPanAction:YES];
                }else{
                    [self showMenuWithPanAction:YES];
                }
            }else{
                if (_maxX - changedX > 0) {
                    [self showMenuWithPanAction:YES];
                }else{
                    [self hideMenuWithPanAction:YES];
                }
            }
        }else{
            if (self.contentView.v_origin.x < - MENU_WIDTH / 2) {
                [self hideMenuWithPanAction:NO];
            }else{
                [self showMenuWithPanAction:NO];
            }
        }
        _maxX = 0;
    }
}

#pragma mark - 活动信息点击
- (void)eventDatailBtnAction:(UIButton *)sender {
    G100EventDetailDomain *detail = [self.eventDomain.events safe_objectAtIndex:sender.tag - 100];
    
    if (_getEventDetailBlock) {
        self.getEventDetailBlock(detail);
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItemArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"menuCell";
    G100MenuCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"G100MenuCell" owner:self options:nil]lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    MenuItem *item = [self.menuItemArr safe_objectAtIndex:indexPath.row];
    cell.menuTitle.text = item.itemName;
    cell.menuImageView.image = [UIImage imageNamed:item.itemIconName];
    cell.needNoticeDot = item.needNoticeDot;
    cell.detailLabel.text = item.itemDesc;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_delegate respondsToSelector:@selector(menuView:didSelectRowAtIndexPath:menuItem:)]) {
        [self.delegate menuView:self didSelectRowAtIndexPath:indexPath menuItem:[self.menuItemArr safe_objectAtIndex:indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)  {
        return 12;
    }
    return 0.001;
}

#pragma mark - UIGestureRecognizerDelegate
// 点击cell,响应的是，，selectedBtn，加入上面的方法也木有效果
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableView"] ||
        [NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]) {
        //如果当前是tableView 做自己想做的事
        return NO;
    }
    return YES;
}

@end

//
//  G100ShareSheet.m
//  G100ActionSheet
//
//  Created by yuhanle on 15/10/19.
//  Copyright © 2015年 yuhanle. All rights reserved.
//

#import "G100ShareSheet.h"
#import "G100ShareCell.h"
#import "G100ShareModel.h"
#import <UMShare/UMShare.h>
#import "G100UMSocialConfig.h"
#define kG100ShareSheetTitleH 30
#define kG100ShareSheetBtnH   44

#define kG100ShareSheetHeight (kG100ShareCellHeight+kG100ShareSheetBtnH+kG100ShareSheetTitleH+kBottomPadding)

#define screenWidth [[UIScreen mainScreen] bounds].size.width

@interface G100ShareSheet() <UITableViewDelegate, UITableViewDataSource, G100ShareCellDelegate>
{
@private
    NSString *_title;
    NSString *_cancelTitle;
    UIView   *_backgroundView;
}

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, retain) UITableView *tableView;

@end

NSString * const kG100ShareTableCellIdentifier = @"kG100ShareTableCellIdentifier";

@implementation G100ShareSheet

- (instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle
{
    if (!(self = super.init)) return nil;
    
    self.backgroundColor = [UIColor colorWithRed:233.0 / 255.0 green:233.0 / 255.0 blue:233.0 / 255.0 alpha:1.0];
    
    if (title && title.length > 0) _title = title; else _title = @"分  享";
    if (cancelButtonTitle && cancelButtonTitle.length > 0) _cancelTitle = cancelButtonTitle; else _cancelTitle = @"取消";
    
    [self addSubview:self.tableView];
    
    return self;
}

- (void)addShareModel:(G100ShareModel *)shareModel {
    
    if (!shareModel || ![shareModel isKindOfClass:[G100ShareModel class]]) {
        return;
    }
    
    if ([shareModel.platformName isEqualToString:G100UMShareToWechatSession]) {
        if (![[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession]) {
            shareModel.enable = NO;
        }
    }else if ([shareModel.platformName isEqualToString:G100UMShareToWechatTimeline]) {
        if (![[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatTimeLine]) {
            shareModel.enable = NO;
        }
    }else if ([shareModel.platformName isEqualToString:G100UMShareToQQ]) {
        if (![[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ]) {
            shareModel.enable = NO;
        }
    }else if ([shareModel.platformName isEqualToString:G100UMShareToQzone]) {
        if (![[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_Qzone]) {
            shareModel.enable = NO;
        }
    }else if ([shareModel.platformName isEqualToString:G100UMShareToSina]) {
       
    }
    
    if (!self.dataArray.count) {
        NSMutableArray *first = [[NSMutableArray alloc] init];
        [self.dataArray addObject:first];
    }
    
    NSMutableArray * firstData = [self.dataArray firstObject];
    [firstData addObject:shareModel];
    
    // 对data进行排序 不可点击的放在末尾
    NSMutableArray * tmp = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < firstData.count; i++) {
        G100ShareModel * model = firstData[i];
        if (0 == model.enable) {
            [tmp addObject:model];
        }
    }
    
    [firstData removeObjectsInArray:tmp];
    [firstData addObjectsFromArray:tmp];
}

// resetTableView.frame
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

#pragma mark -- getter

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    
    return _dataArray;
}

- (UITableView *)tableView
{
    if (_tableView) return _tableView;
    
    // 初始化tableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    // 代理 && 数据源
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    // 透明背景
    _tableView.backgroundColor = [UIColor clearColor];
    // 禁止滑动
    _tableView.scrollEnabled = NO;
    // 注册缓存
    [_tableView registerClass:[G100ShareCell class] forCellReuseIdentifier:kG100ShareTableCellIdentifier];
    // header
    _tableView.tableHeaderView = [self headerView];
    // footerView
    _tableView.tableFooterView = [self footerView];
    return _tableView;
}

// headerView
- (UILabel *)headerView
{
    UILabel *headerLabel        = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth, kG100ShareSheetTitleH)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment   = NSTextAlignmentCenter;
    headerLabel.font            = [UIFont systemFontOfSize:14.f];
    headerLabel.text            = _title;
    return headerLabel;
}
// footerView
- (UIButton *)footerView
{
    UIButton *cancelBtn         = [[UIButton alloc] initWithFrame :CGRectMake(0, 0, screenWidth, kG100ShareSheetBtnH+kBottomPadding)];
    cancelBtn.backgroundColor   = [UIColor whiteColor];
    cancelBtn.titleLabel.font   = [UIFont systemFontOfSize:18.f];
    cancelBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    [cancelBtn setTitle:_cancelTitle forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    return cancelBtn;
}

#pragma mark -- public
// 弹出
- (void)show
{
    // 刷新table
    [self.tableView reloadData];
    
    UIViewController *topvc = APPDELEGATE.window.currentViewController;
    UIWindow *window        = [UIApplication sharedApplication].keyWindow;
    _backgroundView         = [[UIView alloc] initWithFrame :window.bounds];
    _backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    _backgroundView.userInteractionEnabled = YES;
    [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)]];
    [topvc.view addSubview:_backgroundView];
    
    self.frame = CGRectMake(0, window.bounds.size.height, window.bounds.size.width, kG100ShareSheetHeight);
    [topvc.view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        self.frame = CGRectMake(0, window.bounds.size.height-kG100ShareSheetHeight, window.bounds.size.width, kG100ShareSheetHeight);
    }];
}

#pragma mark -- private
// 隐藏
- (void)hide
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGRect newRect   = self.frame;
    newRect.origin.y = window.bounds.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = newRect;
        _backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
    } completion:^(BOOL finished) {
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
        [self removeFromSuperview];
    }];
}


#pragma mark -- delegate

#pragma mark -- UITableViewDataSource && UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kG100ShareCellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    G100ShareCell *cell = (G100ShareCell *)[tableView dequeueReusableCellWithIdentifier:kG100ShareTableCellIdentifier];
    NSArray * models = _dataArray[indexPath.section];
    cell.models   = models;
    cell.delegate = self;
    return cell;
}

// 点击回调
- (void)selectedButton:(UIButton *)button tag:(NSInteger)tagNumber
{
    UIWindow *window      = [UIApplication sharedApplication].keyWindow;
    __weak __typeof(&*self)weakSelf = self;
    
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
        self.frame = CGRectMake(0, window.bounds.size.height, window.bounds.size.width, kG100ShareSheetHeight);
    } completion:^(BOOL finished) {
        [_backgroundView removeFromSuperview];
        _backgroundView = nil;
        [weakSelf removeFromSuperview];
        
        if (![weakSelf.dataArray[0] count]) {
            return;
        }
        
        id tmp = weakSelf.dataArray[0][tagNumber];
        if ([tmp isKindOfClass:[G100ShareModel class]]) {
            G100ShareModel *shareModel = weakSelf.dataArray[0][tagNumber];
            if (shareModel.handler) {
                shareModel.handler(shareModel);
            }
        }
    }];
}

@end

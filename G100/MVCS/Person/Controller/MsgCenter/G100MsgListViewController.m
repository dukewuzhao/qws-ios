//
//  G100MsgListViewController.m
//  G100
//
//  Created by yuhanle on 2018/7/10.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "G100MsgListViewController.h"
#import "G100ImageMsgTableViewCell.h"
#import "G100WebViewController.h"
#import "DatabaseOperation.h"
#import "G100MsgDomain.h"

#import <UITableView+FDTemplateLayoutCell.h>

#define AllSelDeleteBtnHeight   44+kBottomPadding

@interface G100MsgListViewController () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource> {
    BOOL _editingMode;
    BOOL _emShouldDisplay;
}

@end

@implementation G100MsgListViewController

#pragma mark - Public Method
- (void)reloadUIData {
    [self.listView reloadData];
    [self.listView reloadEmptyDataSet];
}

- (void)enterEditMode {
    _editingMode = YES;
    [self.listView reloadData];
    [self.listView setContentInset:UIEdgeInsetsMake(0, 0, AllSelDeleteBtnHeight, 0)];
}

- (void)exitEditMode {
    _editingMode = NO;
    
    // 取消所有项的选中属性
    [self.items enumerateObjectsUsingBlock:^(G100MsgDomain * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hasPicked = NO;
    }];
    
    [self.listView reloadData];
    [self.listView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)selectAllItems {
    [self.items enumerateObjectsUsingBlock:^(G100MsgDomain * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hasPicked = YES;
    }];
    
    [self.listView reloadData];
}

- (void)unSelectAllItems {
    [self.items enumerateObjectsUsingBlock:^(G100MsgDomain * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hasPicked = NO;
    }];
    
    [self.listView reloadData];
}

- (void)deleteItems {
    NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
    // 从数据源中 取出 用户选中待删除的消息
    for (G100MsgDomain *msg in self.items) {
        if (msg.hasPicked) {
            [deleteArray addObject:msg];
        }
    }
    
    if (deleteArray.count == 0) {
        [self showHint:@"请先选择需要删除的消息"];
        return;
    }
    
    // 从数据库中删除对应的消息
    [[DatabaseOperation operation] deleteDatabaseWithUserid:[self.userid integerValue] msgArray:deleteArray success:^(BOOL success) {
        if (success) {
            [self.items removeObjectsInArray:deleteArray];
            [self.listView reloadData];
            [self showHint:@"删除成功"];
            
            if ([_delegate respondsToSelector:@selector(msg_needReloadFromDB)]) {
                [_delegate msg_needReloadFromDB];
            }
            
            if ([_delegate respondsToSelector:@selector(msg_deleteFinished)]) {
                [_delegate msg_deleteFinished];
            }
        }
    }];
}

#pragma mark - lazy load
- (UITableView *)listView {
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.emptyDataSetSource = self;
        _listView.emptyDataSetDelegate = self;
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_listView registerNib:[UINib nibWithNibName:@"G100ImageMsgTableViewCell" bundle:nil] forCellReuseIdentifier:@"G100ImageMsgTableViewCell"];
    }
    return _listView;
}

- (void)setItems:(NSMutableArray<G100MsgDomain *> *)items {
    _items = items;
    _emShouldDisplay = YES;
}

- (void)setupView {
    [self.view addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = self.msgTypeMode ? @"暂无系统消息" : @"暂无个人消息";
    NSDictionary *attributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                  NSForegroundColorAttributeName: [UIColor colorWithHexString:@"717071"] };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return _emShouldDisplay;
}

#pragma mark - UITableviewDelegate && UITableviewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100MsgDomain *domain = [self.items safe_objectAtIndex:indexPath.row];
    G100ImageMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"G100ImageMsgTableViewCell"];
    cell.editBtn.hidden = !_editingMode;
    cell.domain = domain;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100MsgDomain *domain = [self.items safe_objectAtIndex:indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:@"G100ImageMsgTableViewCell" configuration:^(G100ImageMsgTableViewCell *cell) {
        cell.domain = domain;
    }];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    G100MsgDomain *domain = [self.items safe_objectAtIndex:indexPath.row];
    if (domain == nil) {
        return;
    }
    
    if (_editingMode) {
        /* 编辑模式 */
        domain.hasPicked = !domain.hasPicked;
        NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
        // 从数据源中 取出 用户选中待删除的消息
        for (G100MsgDomain *msg in self.items) {
            if (msg.hasPicked) {
                [deleteArray addObject:msg];
            }
        }
        
        if (deleteArray.count == self.items.count) {
            /* 全选状态 */
            if ([_delegate respondsToSelector:@selector(msg_updateSelectAllStatus:)]) {
                [_delegate msg_updateSelectAllStatus:YES];
            }
        } else {
            /* 非全选 */
            if ([_delegate respondsToSelector:@selector(msg_updateSelectAllStatus:)]) {
                [_delegate msg_updateSelectAllStatus:NO];
            }
        }
        
        [self.listView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
    }else {
        /** 普通模式*/
        [self handleWithMsg:domain];
        
        if (!domain.hasRead) {
            [[DatabaseOperation operation] hasReadMsgWithMsg:domain success:^(BOOL success) {
                if (success) {
                    domain.hasRead = YES;
                    [self.listView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationNone];
                    
                    if ([_delegate respondsToSelector:@selector(msg_needReloadFromDB)]) {
                        [_delegate msg_needReloadFromDB];
                    }
                }
            }];
        }
    }
}

#pragma mark - UITabelview Edit
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_editingMode) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        G100MsgDomain *domain = [self.items safe_objectAtIndex:indexPath.row];
        [[DatabaseOperation operation] deleteDatabaseWithUserid:[self.userid integerValue] msgArray:@[ domain ] success:^(BOOL success) {
            if (success) {
                [self.items removeObject:domain];
                [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationLeft];
                [self showHint:@"删除成功"];
                
                if ([_delegate respondsToSelector:@selector(msg_needReloadFromDB)]) {
                    [_delegate msg_needReloadFromDB];
                }
            }
        }];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Private Method
- (void)handleWithMsg:(G100MsgDomain *)msg {
    // 如果是网页就打开webView
    if ([msg.mcurl hasPrefix:@"http"]) {
        G100WebViewController * msgWeb = [G100WebViewController loadNibWebViewController];
        msgWeb.userid = self.userid;
        msgWeb.bikeid = msg.bikeid;
        msgWeb.devid = msg.deviceid;
        msgWeb.isAllowInpourJS = YES;
        msgWeb.httpUrl = msg.mcurl;
        [self.topParentViewController.navigationController pushViewController:msgWeb animated:YES];
    }else if ([msg.mcurl hasPrefix:@"qwsapp://"]) {
        // 自定义协议跳转
        [G100Router openURL:msg.mcurl];
    }else {
        G100WebViewController * msgWeb = [G100WebViewController loadNibWebViewController];
        msgWeb.userid = self.userid;
        msgWeb.bikeid = msg.bikeid;
        msgWeb.devid = msg.deviceid;
        msgWeb.msg_title = msg.mctitle;
        msgWeb.msg_desc = msg.mcdesc;
        msgWeb.filename = @"msg_template.html";
        [self.topParentViewController.navigationController pushViewController:msgWeb animated:YES];
    }
}

@end

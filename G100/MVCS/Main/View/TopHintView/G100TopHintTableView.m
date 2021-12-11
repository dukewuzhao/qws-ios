//
//  G100TopHintTableView.m
//  G100
//
//  Created by 曹晓雨 on 2017/4/20.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100TopHintTableView.h"
#import "G100InsuranceManager.h"
#import "G100DeviceDomain.h"
#import "G100TopHintViewCell.h"
#import "NSString+CalHeight.h"

@interface G100TopHintTableView() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation G100TopHintTableView

- (instancetype)init {
    if (self = [super init]) {
        [self setUpView];
    }
    return self;
}

- (void)setTopHintModel:(G100TopHintModel *)topHintModel {
    _topHintModel = topHintModel;
    [self.tableView reloadData];
}
- (void)setUpView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self addSubview:self.tableView];
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([self.tableView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.tableView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(0);
    }];
    
    [G100TopHintViewCell registerToTabelView:self.tableView];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.topHintModel.allViewHints.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    G100TopHintViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[G100TopHintViewCell cellID]];
    cell.hintLabel.text = self.topHintModel.allViewHints[indexPath.row].text;
    cell.hintLabel.backgroundColor = self.topHintModel.allViewHints[indexPath.row].bgColor;
    cell.contentView.backgroundColor = self.topHintModel.allViewHints[indexPath.row].bgColor;
    tableView.backgroundColor = self.topHintModel.allViewHints[indexPath.row].bgColor;
    self.backgroundColor = self.topHintModel.allViewHints[indexPath.row].bgColor;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = [NSString heightWithText:self.topHintModel.allViewHints[indexPath.row].text
                                         fontSize:[UIFont systemFontOfSize:14] Width:WIDTH - 40];
    return  cellHeight <= 20 ? 20 : cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    G100TopHintViewModel *thvm = self.topHintModel.allViewHints[indexPath.row];
    if (thvm.hintType == TopHintBuy) {
        if ([self.delegate respondsToSelector:@selector(topTableViewClickedWithDevice:)]) {
            [self.delegate topTableViewClickedWithDevice:[self.topHintModel.devServiceOverdueArr safe_objectAtIndex:indexPath.row]];
        }
    }
    
    if (thvm.hintType == TopHintPullInsurance) {
        if ([self.delegate respondsToSelector:@selector(topTableViewClickedWithInsurance:)]) {
            [self.delegate topTableViewClickedWithInsurance:[self.topHintModel.insuranceBannerArr safe_objectAtIndex:indexPath.row]];
        }
    }
    
    if (thvm.hintType == TopHintUpdate) {
        if ([self.delegate respondsToSelector:@selector(topTableViewClickedWithUpdateVersion:)]) {
            [self.delegate topTableViewClickedWithUpdateVersion:[self.topHintModel.waitUpdateArray safe_objectAtIndex:indexPath.row]];
        }
    }
}

@end

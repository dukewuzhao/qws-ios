//
//  G100DevPhotoCell.m
//  G100
//
//  Created by William on 16/3/25.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevPhotoCell.h"

@interface G100DevPhotoCell ()

@property (nonatomic, strong) UILabel * titleLabel;

@property (nonatomic, strong) G100PhotoPickerView * photoPickerView;

@end

@implementation G100DevPhotoCell


- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 16)];
        _titleLabel.text = @"车辆照片";
        _titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (G100PhotoPickerView *)photoPickerView {
    if (!_photoPickerView) {
        _photoPickerView = [[G100PhotoPickerView alloc] initWithPoint:CGPointMake(20, _titleLabel.v_bottom + 10)];
        [self addSubview:_photoPickerView];
    }
    return _photoPickerView;
}

- (instancetype)initWithDelegate:(id<G100PhotoPickerDelegate>)delegate identifier:(NSString *)identifier dataArray:(NSArray *)dataArray {
    self.isAllowEdit = YES;
    return [self initWithDelegate:delegate identifier:identifier dataArray:dataArray isAllowEdit:YES];
}

- (instancetype)initWithDelegate:(id<G100PhotoPickerDelegate>)delegate identifier:(NSString *)identifier dataArray:(NSArray *)dataArray isAllowEdit:(BOOL)isAllowEdit {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        self.isAllowEdit = isAllowEdit;
        [self titleLabel];
        [self photoPickerView];
        [self.photoPickerView setPickerData:dataArray];
        _photoPickerView.delegate = delegate;
        self.frame = CGRectMake(0, 0, WIDTH, _photoPickerView.v_bottom+10);
        
        if (!isAllowEdit) {
            // 不允许添加照片
            [self.photoPickerView setMaxSeletedNumber:[dataArray count]];
        }
        
        [self.photoPickerView setIsShowCoverBtn:NO];
        [self.photoPickerView setIsAllowEdit:isAllowEdit];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<G100PhotoPickerDelegate>)delegate identifier:(NSString *)identifier dataArray:(NSArray *)dataArray isAllowEdit:(BOOL)isAllowEdit isShowCoverBtn:(BOOL)isShowCoverBtn {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (self) {
        self.isAllowEdit = isAllowEdit;
        self.isShowCoverBtn = isShowCoverBtn;
        
        [self titleLabel];
        [self photoPickerView];
        [self.photoPickerView setPickerData:dataArray];
        _photoPickerView.delegate = delegate;
        self.frame = CGRectMake(0, 0, WIDTH, _photoPickerView.v_bottom+10);
        
        if (!isAllowEdit) {
            // 不允许添加照片
            [self.photoPickerView setMaxSeletedNumber:[dataArray count]];
        }
        
        [self.photoPickerView setIsShowCoverBtn:isShowCoverBtn];
        [self.photoPickerView setIsAllowEdit:isAllowEdit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  G100DevOptionCell.m
//  G100
//
//  Created by yuhanle on 2016/10/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevOptionCell.h"
#import "G100DeviceDomain.h"

@interface G100DevOptionCell ()

@property (nonatomic, weak) IBOutlet UIImageView *flagImageView;
@property (nonatomic, weak) IBOutlet UIImageView *indexView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIButton *visibleBtn;

@end

@implementation G100DevOptionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.contentView.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:0.7f];
    }else{
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

- (void)setDevice:(G100DeviceDomain *)device {
    _device = device;
    
    self.nameLabel.text = device.name;
    
    if ([_delegate respondsToSelector:@selector(G100DevOptionCell:visibleDevice:)]) {
        if (![self.delegate G100DevOptionCell:self visibleDevice:device]) {
            self.visibleBtn.selected = YES;
        }else {
            // 判断用户是否设置显示隐藏功能
            self.visibleBtn.selected = !device.location_display;
        }
    }
    
  //  self.flagImageView.hidden = !device.isMainDevice;
    self.index = device.index;
    
    if (self.totalCount > 1) {
        if (self.index == 0) {
            if (!_selectedStatus) {
                [self.indexView setImage:[UIImage imageNamed:@"ic_devindex0_normal"]];
            }else {
                [self.indexView setImage:[UIImage imageNamed:@"ic_devindex0_sel"]];
            }
            
            if (!device.location_display) {
                [self.indexView setImage:[UIImage imageNamed:@"ic_devindex%0_hidden"]];
            }
        }else{
            if (!_selectedStatus) {
                [self.indexView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_devindex%@_normal", @(self.index+1)]]];
            }else {
                [self.indexView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_devindex%@_sel", @(self.index+1)]]];
            }
            
            if (!device.location_display) {
                [self.indexView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_devindex%@_hidden", @(self.index+1)]]];
            }
        }
        
    }else {
        if (!_selectedStatus) {
            [self.indexView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_devindex%@_normal", @(0)]]];
        }else {
            [self.indexView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_devindex%@_sel", @(0)]]];
        }
    }
    
    self.visibleBtn.hidden = device.isMainDevice;
}

- (void)setSelectedStatus:(BOOL)selectedStatus {
    _selectedStatus = selectedStatus;
    
    if (self.totalCount > 1) {
        if (self.index == 0) {
            if (!_selectedStatus) {
                [self.indexView setImage:[UIImage imageNamed:@"ic_devindex0_normal"]];
            }else {
                [self.indexView setImage:[UIImage imageNamed:@"ic_devindex0_sel"]];
            }
            
            if (!self.device.location_display) {
                [self.indexView setImage:[UIImage imageNamed:@"ic_devindex%0_hidden"]];
            }
        }else{
        if (!selectedStatus) {
            [self.indexView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_devindex%@_normal", @(self.index+1)]]];
        }else {
            [self.indexView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_devindex%@_sel", @(self.index+1)]]];
        }
        
        if (!self.device.location_display) {
            [self.indexView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_devindex%@_hidden", @(self.index+1)]]];
        }
        }
    }else {
        if (!selectedStatus) {
            [self.indexView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_devindex%@_normal", @(0)]]];
        }else {
            [self.indexView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ic_devindex%@_sel", @(0)]]];
        }
    }
}

- (IBAction)visiableBtnClick:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(G100DevOptionCell:device:visibleState:)]) {
        [self.delegate G100DevOptionCell:self device:self.device visibleState:sender.selected];
    }
    
    if ([_delegate respondsToSelector:@selector(G100DevOptionCell:visibleDevice:)]) {
        if ([self.delegate G100DevOptionCell:self visibleDevice:self.device]) {
            //sender.selected = !sender.selected;
        }
    }
}

@end

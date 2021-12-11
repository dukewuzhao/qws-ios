//
//  G100DevFindingCell.m
//  G100
//
//  Created by William on 16/4/14.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100DevFindingCell.h"
#import "G100DevFindLostListDomain.h"
#import "NSDate+TimeString.h"
#import <UIImageView+WebCache.h>
#import "G100PhotoBrowserViewController.h"
#import "G100PhotoShowModel.h"

#define Height_Of_PhotoBackground (WIDTH-56)*(65.0/264.0)

NSString * const kNibNameDevFindingNormalCell = @"DevFindingNormalCell";
NSString * const kNibNameDevFindingCustomCell = @"DevFindingCustomCell";

static NSString * kCellIdentifier = @"photoCell";

@interface G100DevFindingCell () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) G100DevFindLostDomain * domain;

@property (nonatomic, strong) NSArray * imgUrlArray;

@end

@implementation G100DevFindingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.delFindingBtn setExclusiveTouch:YES];
    [self.photoCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (IBAction)deleteFindingRecord:(UIButton *)sender {
    if (self.deleteFindingRecordBlock) {
        self.deleteFindingRecordBlock(self.domain.findlostid);
    }
}

- (void)setCellDataWithModel:(G100DevFindLostDomain *)domain {
    _domain = domain;
    
    _imgUrlArray = [G100PhotoShowModel showModelWithUrlArray:domain.picture];
    
    if (domain.type == FindingRecordTypeCustom) {
        if (domain.picture.count == 0) {
            self.photoBackgroundView.hidden = YES;
        }else{
            self.photoBackgroundView.hidden = NO;
        }
    }else{
        NSString * imageNameStr;
        switch (domain.type) {
            case FindingRecordTypeOpenSwitch:
            case FindingRecordTypeCloseSwitch:
                imageNameStr = @"ic_dev_logs_elec_open";
                break;
            case FindingRecordTypeLocatePosition:
                imageNameStr = @"ic_lost_report_location_pin";
                break;
            case FindingRecordTypeStartFinding:
                imageNameStr = @"ic_lost_start_finding";
                break;
            case FindingRecordTypeEndFinding:
            case FindingRecordTypeLostHasClaims:
                imageNameStr = @"ic_lost_end_finding";
                break;
            case FindingRecordTypeLostPosition:
                imageNameStr = @"ic_lost_lost_position";
                break;
            case FindingRecordTypeBatteryRemove:
                imageNameStr = @"ic_dev_logs_power_move";
                break;
            default:
                imageNameStr = @"ic_lost_report_location_pin";
                break;
        }
        self.findingTypeImageView.image = [UIImage imageNamed:imageNameStr];
    }
    self.timeLabel.text = [NSDate getSummaryTimeStrWithDateStr:domain.time];
    if (domain.desc.length == 0) {
        self.findingDescLabel.text = @"未添加文字描述";
        self.findingDescLabel.textColor = [UIColor grayColor];
    }else{
        self.findingDescLabel.text = domain.desc;
        self.findingDescLabel.textColor = [UIColor blackColor];
    }
    if (domain.type == FindingRecordTypeCustom && domain.picture.count > 0) {
        [self.photoCollectionView reloadData];
    }
}


+ (CGFloat)heightForRow:(G100DevFindLostDomain *)domain {
    if (0 != domain.cellHeight) {
        return domain.cellHeight;
    }
    
    if (domain.type == FindingRecordTypeCustom) {
        CGSize size = [domain.desc calculateSize:CGSizeMake(WIDTH-126, 999) font:[UIFont systemFontOfSize:15.0f]];
        if (domain.picture.count == 0) {
//            if (size.height>54) {
//                domain.cellHeight = 54 + 24;
//            }else{
                domain.cellHeight = size.height + 24;
//            }
        }else{
//            if (size.height>54) {
//                domain.cellHeight = 54 + 24 + Height_Of_PhotoBackground;
//            }else{
                domain.cellHeight = size.height + 24 + Height_Of_PhotoBackground;
//            }
        }
    }else{
        CGSize size = [domain.desc calculateSize:CGSizeMake(WIDTH-100, 999) font:[UIFont systemFontOfSize:16.0f]];
        domain.cellHeight = size.height + 24;
    }
    return domain.cellHeight;
}

+ (NSString *)identifierForRow:(G100DevFindLostDomain *)domain {
    if (domain.type == FindingRecordTypeCustom) {
        return kNibNameDevFindingCustomCell;
    }else{
        return kNibNameDevFindingNormalCell;
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.domain.picture.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UICollectionViewCell alloc]init];
    }
    cell.clipsToBounds = YES;
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.domain.picture[indexPath.row]]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(Height_Of_PhotoBackground-14, Height_Of_PhotoBackground-14);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    G100PhotoBrowserViewController *viewController = [[G100PhotoBrowserViewController alloc] initWithPhotos:self.imgUrlArray currentIndex:indexPath.row];
    [viewController setDelBtnHidden:YES];
    viewController.isShowCoverBtn = NO;
    viewController.hidesBottomBarWhenPushed = YES;
    if ([CURRENTVIEWCONTROLLER isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController*)CURRENTVIEWCONTROLLER pushViewController:viewController animated:YES];
    }else{
        [CURRENTVIEWCONTROLLER.navigationController pushViewController:viewController animated:YES];
    }
}

@end

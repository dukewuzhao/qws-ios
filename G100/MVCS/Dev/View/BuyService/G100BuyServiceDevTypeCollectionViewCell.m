//
//  G100BuyServiceDevTypeCollectionViewCell.m
//  G100
//
//  Created by 曹晓雨 on 2016/10/21.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import "G100BuyServiceDevTypeCollectionViewCell.h"
#import "UILabeL+AjustFont.h"
#import "NSString+CalHeight.h"
#import "UILabeL+AjustFont.h"

@interface G100BuyServiceDevTypeCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *devTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sdHeight;

@end

@implementation G100BuyServiceDevTypeCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setLayer];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)initUIWithMode:(G100DeviceDomain *)deviveDomain {
    _itemLabel.text = [NSString stringWithFormat:@"%ld.", _indexPath.item + 1];
    _devTypeLabel.text = [NSString stringWithFormat:@"%@", deviveDomain.name];
    if (deviveDomain.service.left_days <= 30) {
        if (deviveDomain.service.left_days <= 0) {
            if (deviveDomain.service.left_days <= -15) {
                _serviceDateLabel.text = [NSString stringWithFormat:@"请致电客服重新开通服务"];
                _serviceDateLabel.textColor = [UIColor redColor];
            }else {
                _serviceDateLabel.text = [NSString stringWithFormat:@"服务已过期"];
                _serviceDateLabel.textColor = [UIColor redColor];
            }
        }else {
            _serviceDateLabel.text = [NSString stringWithFormat:@"剩余流量服务%ld天", (long)deviveDomain.service.left_days];
            _serviceDateLabel.textColor = [UIColor colorWithHexString:@"#ff6c00"]; //黄色
        }
    }else {
        _serviceDateLabel.text = [NSString stringWithFormat:@"服务期至 %@", deviveDomain.service.end_date];
        _serviceDateLabel.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.00];
    }
    
    if ([deviveDomain isSpecialChinaMobileDevice]) {
        _serviceDateLabel.text = @"不支持服务购买";
        _serviceDateLabel.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.00];
    }
    
    CGFloat serviceHeight = [NSString heightWithText:_serviceDateLabel.text
                                            fontSize:[_serviceDateLabel adjustFont:[UIFont systemFontOfSize:14] multiple:0.5]
                                               Width:(WIDTH - 50)/2 - 36];
    self.sdHeight.constant = serviceHeight;
    
    _serviceDateLabel.font = [_serviceDateLabel adjustFont:[UIFont systemFontOfSize:14] multiple:0.5];
    _devTypeLabel.font = [_devTypeLabel adjustFont:[UIFont systemFontOfSize:17] multiple:0.5];
    _itemLabel.font = [_itemLabel adjustFont:[UIFont systemFontOfSize:17] multiple:0.5];
}

- (CGFloat)heightForRow {
    CGFloat deviceTypeHeight = [NSString heightWithText:_devTypeLabel.text
                                              fontSize:[_devTypeLabel adjustFont:[UIFont systemFontOfSize:17] multiple:0.5]
                                                 Width:(WIDTH - 50)/2 - 36];
    CGFloat serviceHeight = [NSString heightWithText:_serviceDateLabel.text
                                           fontSize:[_serviceDateLabel adjustFont:[UIFont systemFontOfSize:14] multiple:0.5]
                                              Width:(WIDTH - 50)/2 - 36];
    return deviceTypeHeight + serviceHeight + 30;
}

+ (CGFloat)heightForItem:(G100DeviceDomain *)deviveDomain {
    NSString *des = @"";
    if (deviveDomain.service.left_days <= 15) {
        if (deviveDomain.service.left_days <= 0) {
            if (deviveDomain.service.left_days <= -15) {
                des = [NSString stringWithFormat:@"请致电客服重新开通服务"];
            } else {
                des = [NSString stringWithFormat:@"服务已过期"];
            }
        } else {
            des = [NSString stringWithFormat:@"剩余流量服务%ld天", (long)deviveDomain.service.left_days];
        }
    } else {
        des = [NSString stringWithFormat:@"服务期至 %@", deviveDomain.service.end_date];
    }
    
    if ([deviveDomain isSpecialChinaMobileDevice]) {
        des = @"不支持服务购买";
    }

    CGFloat deviceTypeHeight = [NSString heightWithText:deviveDomain.name
                                              fontSize:[G100BuyServiceDevTypeCollectionViewCell
                                                        adjustFont:[UILabel adjustFontWithFont:[UIFont systemFontOfSize:17] multiple:0.5]
                                                        multiple:0.5]
                                                 Width:(WIDTH - 50)/2 - 36];
    CGFloat serviceHeight = [NSString heightWithText:des
                                           fontSize:[G100BuyServiceDevTypeCollectionViewCell
                                                     adjustFont:[UILabel adjustFontWithFont:[UIFont systemFontOfSize:14] multiple:0.5]
                                                     multiple:0.5]
                                              Width:(WIDTH - 50)/2 - 36];
    return deviceTypeHeight + serviceHeight + 30;
}

+ (UIFont *)adjustFont:(UIFont *)font multiple:(CGFloat)multiple
{
    UIFont *newFont = nil;
    if (IS_IPHONE_4s){
        newFont = [UIFont fontWithName:font.fontName size:font.pointSize - IPHONE4_INCREMENT *multiple];
    }else if (IS_IPHONE_6){
        newFont = [UIFont fontWithName:font.fontName size:font.pointSize - IPHONE6_INCREMENT *multiple];
    }else if (IS_IPHONE_5s){
        newFont = [UIFont fontWithName:font.fontName size:font.pointSize - IPHONE5_INCREMENT *multiple];
    }else {
        newFont = font;
    }
    return newFont;
}

@end

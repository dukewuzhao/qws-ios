//
//  G100PriceCollectionViewCell.m
//  G100
//
//  Created by 曹晓雨 on 2016/10/21.
//  Copyright © 2016年 caoxiaoyu. All rights reserved.
//

#import "G100PriceCollectionViewCell.h"
#import "G100GoodDomain.h"
#import "UILabeL+AjustFont.h"
#import "NSString+CalHeight.h"

@implementation G100PriceCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setLayer];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)initUIWithMode:(G100GoodDomain *)goodsDomain {
    _planYearLabel.text = goodsDomain.name;
    _priceLabel.text = [NSString stringWithFormat:@"¥%.2f", goodsDomain.price];
    _descLabel.text = goodsDomain.desc;
    
    if (goodsDomain.discount != 1) {
        _saleLabel.hidden = NO;
        _saleLabel.text = [NSString stringWithFormat:@" %.2f折优惠! ", goodsDomain.discount * 10];
        _saleLabel.layer.masksToBounds = YES;
        _saleLabel.layer.cornerRadius = 4;
    }else {
        _saleLabel.hidden = YES;
    }
    
    if (goodsDomain.kextraoption.original_price && goodsDomain.kextraoption.original_price.integerValue != -1) {
        NSDictionary *attribtDic = @{ NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle] };
        NSString *str = [NSString stringWithFormat:@"原价%@", goodsDomain.kextraoption.original_price];
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:str attributes:attribtDic];
        _originalPriceLabel.attributedText = attribtStr;
        _originalPriceLabel.hidden = NO;
    }else {
        _originalPriceLabel.hidden = YES;
    }

    _planYearLabel.font = [_priceLabel adjustFont:[UIFont boldSystemFontOfSize:15] multiple:0.5];
    _priceLabel.font = [_priceLabel adjustFont:[UIFont fontWithName:@"Helvetica-Bold" size:25] multiple:1];
    _saleLabel.font = [_saleLabel adjustFont:[UIFont systemFontOfSize:13] multiple:0.5];
}

- (CGFloat)heightForRow {
    CGFloat descLabelHeight = [NSString heightWithText:_descLabel.text
                                              fontSize:_descLabel.font
                                                 Width:self.frame.size.width - 20];
    return 66 + descLabelHeight + 5;
}

@end

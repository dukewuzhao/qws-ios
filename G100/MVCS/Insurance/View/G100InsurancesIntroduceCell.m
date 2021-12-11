//
//  G100InsurancesIntroduceCell.m
//  G100
//
//  Created by 曹晓雨 on 2016/12/2.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100InsurancesIntroduceCell.h"
#import "UILabeL+AjustFont.h"
#import "IMGPlaceholderView.h"
#import <UIImageView+WebCache.h>

@interface G100InsurancesIntroduceCell()

@property (weak, nonatomic) IBOutlet UILabel *componyLabel;

@property (weak, nonatomic) IBOutlet UILabel *descTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *descDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *PriceLabel;
@property (weak, nonatomic) IBOutlet IMGPlaceholderView *backImg;
@property (weak, nonatomic) IBOutlet UILabel *RMBLabel;

@property (weak, nonatomic) IBOutlet UIButton *freeBtn;

@property (weak, nonatomic) IBOutlet UIView *xianshiView;
@property (weak, nonatomic) IBOutlet UILabel *xianshiLabel;
@property (weak, nonatomic) IBOutlet UILabel *yishouLabel;

@end

@implementation G100InsurancesIntroduceCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _freeBtn.layer.masksToBounds = YES;
    _freeBtn.layer.cornerRadius = 8.0;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.contentView.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.00];
    } else {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

- (IBAction)freeBtnAction:(id)sender {
    self.freeBtnClickBlock(self.model);
}

- (void)setModel:(PingAnInsuranceModel *)model {
    _model = model;
    
    _componyLabel.text = _model.kinsurance.insurer.length ? _model.kinsurance.insurer : @"暂无公司";
    _descTitleLabel.text = _model.name.length ? _model.name : @"（暂无名称）";
    _descDescLabel.text = _model.desc.length ? _model.desc : @"暂无描述";
    
    CGFloat disPrice = _model.price * _model.discount;
    NSString *price = [NSString stringWithFormat:@"%.2f", disPrice];
    
    if ([price hasContainString:@"."]) {
        NSUInteger pointLocation = [price rangeOfString:@"."].location;
        NSMutableAttributedString *priceStr = [[NSMutableAttributedString alloc] initWithString:price];
        
        [priceStr addAttribute:NSFontAttributeName  value:[UIFont fontWithName:@"Helvetica-Bold" size:20] range:NSMakeRange(pointLocation,price.length - pointLocation)];
        _PriceLabel.attributedText = priceStr;
    }else {
        _PriceLabel.text = price;
    }
    
    [_backImg iph_setImageWithURL:[NSURL URLWithString:_model.picture] showHUD:YES];
    
    _componyLabel.font = [_descTitleLabel adjustFont:[UIFont fontWithName:_componyLabel.font.fontName size:16] multiple:0.7];
    _descTitleLabel.font =  [_descTitleLabel adjustFont:[UIFont fontWithName:_descTitleLabel.font.fontName size:20] multiple:0.7];
    
    BOOL isActionBtn = _model.action_button.length;
    if (isActionBtn) {
        NSAttributedString *astr = [[NSAttributedString alloc] initWithString:_model.action_button ? : @"免费领取"
                                                                   attributes:@{ NSFontAttributeName : _freeBtn.titleLabel.font,
                                                                                 NSForegroundColorAttributeName : _freeBtn.titleLabel.textColor }];
        
        [_freeBtn setAttributedTitle:astr forState:UIControlStateNormal];
        
        _PriceLabel.hidden = YES;
        _RMBLabel.hidden = YES;
        _freeBtn.hidden = NO;
    }else {
        _PriceLabel.hidden = NO;
        _RMBLabel.hidden = NO;
        _freeBtn.hidden = YES;
    }
    
    self.xianshiView.hidden = !model.kextraoption.sale_tag.length;
    self.xianshiLabel.text = model.kextraoption.sale_tag;
    
    if (model.kextraoption.sold_count > 0) {
        NSString *originalPriceStr = [NSString stringWithFormat:@"原价%@元", model.kextraoption.original_price];
        NSString *soldCountStr = [NSString stringWithFormat:@"\n%@件已售", @(model.kextraoption.sold_count)];
        
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", originalPriceStr, soldCountStr]];
        
        [attrStr addAttribute:NSFontAttributeName value: [UIFont systemFontOfSize:12.f] range:NSMakeRange(0, originalPriceStr.length + soldCountStr.length)];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#acacac"] range:NSMakeRange(0, originalPriceStr.length + soldCountStr.length)];
        [attrStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid) range:NSMakeRange(0, originalPriceStr.length)];
        [attrStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleNone) range:NSMakeRange(originalPriceStr.length, soldCountStr.length)];
        
        [attrStr addAttributes:@{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle), NSBaselineOffsetAttributeName:@(0)} range:NSMakeRange(0, originalPriceStr.length)];
        
        self.yishouLabel.attributedText = attrStr;
    } else {
        self.yishouLabel.attributedText = nil;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

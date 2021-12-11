//
//  PersonThirdAccountCell.m
//  G100
//
//  Created by yuhanle on 16/7/26.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "PersonThirdAccountCell.h"
#import "G100TrAccountDomain.h"

@interface PersonThirdAccountCell ()

@property (nonatomic, strong) MASConstraint *baseViewConstraintW;

@end

@implementation PersonThirdAccountCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.leftTitleLabel = [[UILabel alloc] init];
    self.leftTitleLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.leftTitleLabel];
    
    self.thirdImageBaseView = [[UIView alloc] init];
    self.thirdImageBaseView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.thirdImageBaseView];
    
    [self.leftTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@15);
        make.centerY.equalTo(self);
    }];
    
    [self.thirdImageBaseView mas_makeConstraints:^(MASConstraintMaker *make) {
        self.baseViewConstraintW = make.width.equalTo(@40);
        make.height.equalTo(@40);
        make.centerY.equalTo(self);
        make.trailing.equalTo(@0);
    }];
}

- (void)setThirdAccountArray:(NSArray *)thirdAccountArray {
    [self.thirdImageBaseView removeAllSubviews];
    
    NSMutableArray *hasOpenArray = [[NSMutableArray alloc] init];
    
    for (G100TrAccountDomain *domain in thirdAccountArray) {
        if (domain.isBind) {
            [hasOpenArray addObject:domain];
        }
    }
    
    if (hasOpenArray) {
        CGFloat orignX = 0;
        for (G100TrAccountDomain *domain in hasOpenArray) {
            UIImageView *imageView = nil;
            if (domain.accountType == WxAccountType) {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_profile_wx"]];
            }else if (domain.accountType == QQAccountType) {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_profile_qq"]];
            }else if (domain.accountType == SinaAccountType) {
                imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_profile_sina"]];
            }else {
                
            }
            
            [self.thirdImageBaseView addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(40, 40));
                make.leading.mas_equalTo(orignX);
                make.centerY.equalTo(self.thirdImageBaseView);
            }];
            orignX += 40;
        }
        
        [self.thirdImageBaseView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.baseViewConstraintW = make.width.equalTo(@(40*hasOpenArray.count));
        }];
    }else {
        
    }
}

@end

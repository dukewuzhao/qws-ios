//
//  G100ShareCell.m
//  G100ActionSheet
//
//  Created by yuhanle on 15/10/19.
//  Copyright © 2015年 yuhanle. All rights reserved.
//

#import "G100ShareCell.h"
#import "G100ShareItem.h"
#import "G100ShareModel.h"

#define kG100ShareCellBaseTag 59999

@interface G100ShareCell ()

@property (nonatomic, strong) NSArray *shareModels;

@end

@implementation G100ShareCell
@synthesize delegate;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (!(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) return nil;
    
    self.backgroundColor             = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.scrollView = UIScrollView.new;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.alwaysBounceHorizontal = YES;
    [self.contentView addSubview:self.scrollView];
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.scrollView) self.scrollView.frame = self.contentView.bounds;
}

- (void)setModels:(NSArray *)models
{
    self.shareModels = models;
    
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    G100ShareItem *tempItem;
    
    for (int i = 0; i < models.count; i ++) {
        G100ShareModel *model = (G100ShareModel *)models[i];
        G100ShareItem *item   = G100ShareItem.new;
        item.imgName        = model.imgName;
        item.title          = model.displayName;
        item.button.enabled = model.enable;
        item.button.tag     = i+kG100ShareCellBaseTag;
        item.button.exclusiveTouch = YES;
        [item.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:item];
        
        item.frame = CGRectMake(tempItem?CGRectGetMaxX(tempItem.frame)+15:15, 10, 60, kG100ShareCellHeight-20);
        tempItem   = item;
        
        if (i == models.count-1) {
            self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(tempItem.frame)+15, CGRectGetHeight(tempItem.frame));
        }
    }
}

- (void)buttonAction:(UIButton *)button
{
    NSInteger btnTag = button.tag-kG100ShareCellBaseTag;
    if ([self.delegate respondsToSelector:@selector(selectedButton:tag:)]) {
        [self.delegate selectedButton:button tag:btnTag];
    }
}

@end
















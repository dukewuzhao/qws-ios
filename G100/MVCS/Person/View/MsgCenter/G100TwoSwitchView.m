//
//  G100TwoSwitchView.m
//  G100
//
//  Created by yuhanle on 16/3/8.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100TwoSwitchView.h"
#import "G100SelectButton.h"

#define kTwoSwitchBackgroundImageNameLeft  @"ic_my_msg_tab_left"
#define kTwoSwitchBackgroundImageNameRight @"ic_my_msg_tab_right"

@interface G100TwoSwitchView ()

@property (nonatomic, strong) UIImageView * backgroundImage;
@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, strong) NSArray * unreadCountArray;
@property (nonatomic, strong) NSMutableArray * labelArray;
@property (nonatomic, strong) NSMutableArray * buttonArray;

@property (nonatomic, strong) G100SelectButton * nowSelectedBtn;

@end

// 默认frame的大小 180x30
@implementation G100TwoSwitchView

- (instancetype)init {
    if (self = [super init]) {
        self.switchCount = 2; // 默认
        [self setupView];
    }
    return self;
}

- (instancetype)initWithTitleArray:(NSArray *)titleArray unreadCount:(NSArray *)unreadCountArray {
    if (self = [super init]) {
        self.switchCount = [titleArray count];
        [self setupView];
        [self setTitleArray:titleArray unreadCount:unreadCountArray];
        // 初始状态
        [self switchToIndex:0];
    }
    
    return self;
}

- (void)setupView {
    /*
    self.backgroundImage = [[UIImageView alloc] init];
    _backgroundImage.contentMode = UIViewContentModeScaleToFill;
    _backgroundImage.image = [[UIImage imageNamed:kTwoSwitchBackgroundImageNameRight] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self addSubview:_backgroundImage];
    */
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8.0f;
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.labelArray = [[NSMutableArray alloc] initWithCapacity:_switchCount];
    self.buttonArray = [[NSMutableArray alloc] initWithCapacity:_switchCount];
    
    UILabel * lastLabel = nil;
    G100SelectButton * lastBtn = nil;
    for (NSInteger i = 0; i< _switchCount; i++) {
        UILabel * titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        titleLabel.layer.borderWidth = 1.0f;
        [self addSubview:titleLabel];
        
        G100SelectButton * selectButton = [G100SelectButton buttonWithType:UIButtonTypeCustom];
        selectButton.tag = i;
        selectButton.backgroundColor = [UIColor clearColor];
        [selectButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:selectButton];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastLabel) {
                if (i != _switchCount - 1) {
                    make.top.bottom.equalTo(@0);
                    make.leading.equalTo(lastLabel.mas_trailing).with.offset(@-1);
                    make.height.width.equalTo(lastLabel);
                }else {
                    make.trailing.equalTo(@0);
                    make.leading.equalTo(lastLabel.mas_trailing).with.offset(@-1);
                    make.width.equalTo(lastLabel);
                    make.top.bottom.equalTo(self);
                }
            }else {
                make.leading.top.bottom.equalTo(@0);
            }
        }];
        
        [selectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastBtn) {
                if (i != _switchCount - 1) {
                    make.top.bottom.equalTo(@0);
                    make.leading.equalTo(lastBtn.mas_trailing).with.offset(@-1);
                    make.height.width.equalTo(lastBtn);
                }else {
                    make.trailing.equalTo(@0);
                    make.leading.equalTo(lastBtn.mas_trailing).with.offset(@-1);
                    make.width.equalTo(lastBtn);
                    make.top.bottom.equalTo(self);
                }
            }else {
                make.leading.top.bottom.equalTo(@0);
            }
        }];

        [_labelArray addObject:titleLabel];
        [_buttonArray addObject:selectButton];
        
        lastLabel = titleLabel;
        lastBtn = selectButton;
    }
    
    /*
    [_backgroundImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.equalTo(self);
    }];
     */
}

- (void)btnClick:(G100SelectButton *)sender {
    if (_nowSelectedBtn == sender) return;
    
    if ([self.delegate respondsToSelector:@selector(switchView:didSwitchButtonFrom:to:)]) {
        [self.delegate switchView:self didSwitchButtonFrom:self.nowSelectedBtn.tag to:sender.tag];
    }
    
    //__weak UIImageView * weakBgImageView = _backgroundImage;
    [_labelArray enumerateObjectsUsingBlock:^(UILabel * titleLabel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != sender.tag) {
            titleLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
            titleLabel.backgroundColor = [UIColor clearColor];
        }else {
            titleLabel.textColor = [UIColor colorWithHexString:@"000000"];
            titleLabel.backgroundColor = [UIColor whiteColor];
        }
    }];
    
    /*
    if (sender.tag == 0) {
        weakBgImageView.image = [[UIImage imageNamed:kTwoSwitchBackgroundImageNameLeft] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else {
        weakBgImageView.image = [[UIImage imageNamed:kTwoSwitchBackgroundImageNameRight] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
     */
    
    self.nowSelectedBtn = sender;
}

- (void)setTitle:(NSString *)title forIndex:(NSInteger)index {
    [self setTitle:title unreadCount:-1 forIndex:index];
}

- (void)setUnreadCount:(NSInteger)unreadCount forIndex:(NSInteger)index {
    [self setTitle:nil unreadCount:unreadCount forIndex:index];
}

// unreadCount = -1 的时候 只修改title的值
/* 例如:
 * 个人(99+)
 */
- (void)setTitle:(NSString *)title unreadCount:(NSInteger)unreadCount forIndex:(NSInteger)index {
    UILabel * titleLabel = _labelArray[index];
    
    if (!title) {
        NSString * tmp = titleLabel.attributedText.string;
        if (tmp.length) {
            NSRange makeRange = [tmp rangeOfString:@"（"];
            
            if (makeRange.location != NSNotFound) {
                title = [tmp substringToIndex:makeRange.location];
            }else title = tmp;
        }
    }
    
    NSMutableAttributedString * attributedString;
    NSString * unreadStatus = nil;
    
    if (unreadCount == -1) {
        NSString * tmp = titleLabel.attributedText.string;
        if (tmp.length) {
            NSRange makeRange = [tmp rangeOfString:@"（"];
            
            if (makeRange.location != NSNotFound) {
                unreadStatus = [tmp substringFromIndex:makeRange.location];
            }
        }
    }else if (unreadCount <= 0) {
        unreadStatus = @"";
    }else if (unreadCount >=1 && unreadCount <= 99) {
        unreadStatus = [NSString stringWithFormat:@"（%@）", @(unreadCount)];
    }else {
        unreadStatus = [NSString stringWithFormat:@"（%@+）", @(99)];
    }
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", title, unreadStatus]];
    
    [attributedString addAttributes:@{
                                      NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                      }
                              range:NSMakeRange(0, title.length)];
    
    [attributedString addAttributes:@{
                                      NSFontAttributeName: [UIFont systemFontOfSize:11]}
                              range:NSMakeRange(title.length, unreadStatus.length)];
    [titleLabel setAttributedText:attributedString];
}

- (void)setTitleArray:(NSArray *)titleArray {
    _titleArray = titleArray;
    _unreadCountArray = @[];
    
    NSMutableArray * tmpArray = [[NSMutableArray alloc] initWithCapacity:[titleArray count]];
    for (NSInteger i = 0; i < [titleArray count]; i++) {
        [tmpArray addObject:@(0)];
    }
    
    _unreadCountArray = [NSArray arrayWithArray:tmpArray];
    _switchCount = [titleArray count];
    
    __weak G100TwoSwitchView * wself = self;
    [_labelArray enumerateObjectsUsingBlock:^(UILabel * titleLabel, NSUInteger idx, BOOL * _Nonnull stop) {
        [wself setTitle:titleArray[idx] unreadCount:-1 forIndex:idx];
    }];
}

- (void)setTitleArray:(NSArray *)titleArray unreadCount:(NSArray *)unreadCountArray {
    _titleArray = titleArray;
    _unreadCountArray = unreadCountArray;
    _switchCount = [titleArray count];
    
    __weak G100TwoSwitchView * wself = self;
    [_labelArray enumerateObjectsUsingBlock:^(UILabel * titleLabel, NSUInteger idx, BOOL * _Nonnull stop) {
        [wself setTitle:titleArray[idx] unreadCount:[unreadCountArray[idx] integerValue] forIndex:idx];
    }];
}

- (void)switchToIndex:(NSInteger)index {
    // 点击第index btn
    [self btnClick:_buttonArray[index]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

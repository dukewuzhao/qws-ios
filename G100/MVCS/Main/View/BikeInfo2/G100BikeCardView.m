//
//  G100BikeCardView.m
//  G100
//
//  Created by sunjingjing on 16/10/26.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeCardView.h"
#import "G100CardManager.h"

@interface G100BikeCardView ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewheightBigConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewheightSmallConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowViewHeightBigConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowViewHeightSmallConstraint;
@property (assign, nonatomic) BOOL isDevice;
@property (strong, nonatomic) CAShapeLayer *bottonLayer;

@end
@implementation G100BikeCardView

+ (instancetype)showView{
    return [[[NSBundle mainBundle] loadNibNamed:@"G100BikeCardView" owner:nil options:nil] firstObject];
}

+ (CGFloat)heightForItem:(id)item width:(CGFloat)width{
    
    G100BikeDomain *bikeDomain = nil;
    if([item isKindOfClass:[G100CardModel class]]) {
        bikeDomain = ((G100CardModel *)item).bike;
    }
    if ([bikeDomain.devices count]) {
        return 110*width/197;
    }
    return 80*width/197;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    self.bikeInfoView = [G100BikeInfoView loadBikeInfoView];
    [self.topView addSubview:self.bikeInfoView];
    [self.bikeInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.battInfoView = [G100BattInfoView showView];
    [self.bottomView addSubview:self.battInfoView];
    [self.battInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}
-(void)drawRect:(CGRect)rect
{
    if (self.isDevice) {
        _bottonLayer = [CAShapeLayer layer];
        UIBezierPath *bezier = [UIBezierPath bezierPathWithRoundedRect:self.bottomView.frame cornerRadius:8.0f];
        _bottonLayer.path = bezier.CGPath;
        _bottonLayer.fillColor = [UIColor whiteColor].CGColor;
        [self.layer insertSublayer:_bottonLayer atIndex:0];
    }else
    {
        if (self.bottonLayer) {
            [self.bottonLayer removeFromSuperlayer];
            self.bottonLayer = nil;
        }
    }
   
}

- (instancetype)initViewWithDevice:(BOOL)hasDevice{
    self =[[[NSBundle mainBundle] loadNibNamed:@"G100BikeCardView" owner:nil options:nil] firstObject];
    if (self) {
        if (!hasDevice) {
            self.bikeInfoView = [G100BikeInfoView loadBikeInfoView];
            [self.topView addSubview:self.bikeInfoView];
            [self.bikeInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
            self.topViewheightBigConstraint.priority = 999;
            self.topViewheightSmallConstraint.priority = 700;
            self.lowViewHeightBigConstraint.priority = 999;
            self.lowViewHeightSmallConstraint.priority = 700;
        }else
        {
            self.bikeInfoView = [G100BikeInfoView loadBikeInfoView];
            [self.topView addSubview:self.bikeInfoView];
            [self.bikeInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
            self.battInfoView = [G100BattInfoView showView];
            [self.bottomView addSubview:self.battInfoView];
            [self.battInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(@0);
            }];
            self.topViewheightSmallConstraint.priority = 999;
            self.topViewheightBigConstraint.priority = 700;
            self.lowViewHeightSmallConstraint.priority = 999;
            self.lowViewHeightBigConstraint.priority = 700;
        }
    }
    return self;
}

- (void)updateBikeInfoViewHeightWithIsDev:(BOOL)hasDev{
    
    if (self.bottonLayer) {
        [self.bottonLayer removeFromSuperlayer];
        self.bottonLayer = nil;
    }
    _isDevice = hasDev;
    if (hasDev) {
        self.topViewheightSmallConstraint.priority = 999;
        self.topViewheightBigConstraint.priority = 700;
        self.lowViewHeightBigConstraint.priority = 999;
        self.lowViewHeightSmallConstraint.priority = 700;
        self.bottomView.hidden = NO;
    }else{
        self.topViewheightBigConstraint.priority = 999;
        self.topViewheightSmallConstraint.priority = 700;
        self.lowViewHeightSmallConstraint.priority = 999;
        self.lowViewHeightBigConstraint.priority = 700;
        self.bikeInfoView.bikeModel.setSafeMode = -1;
        [self.bikeInfoView updateSafeState];
        self.bottomView.hidden = YES;
    }
    [self.superview setNeedsLayout];
    [self.superview layoutIfNeeded];
    [self setNeedsDisplay];
}

@end

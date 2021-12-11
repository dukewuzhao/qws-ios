//
//  DevPositionPaoPaoView.m
//  G100
//
//  Created by Tilink on 15/6/30.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "DevPositionPaoPaoView.h"
#import <QuartzCore/QuartzCore.h>
#import "PositionDomain.h"

#define Arror_height 6
#define TextFont [UIFont systemFontOfSize:14.0f]

#define paopaoViewMinWidth 280
#define paopaoViewMaxWidth WIDTH - 20
#define paopaoViewDevHeight 84
#define paopaoViewUserHeight 60

#define kPadding 6
#define kNavigationButtonW 64

@interface DevPositionPaoPaoView ()

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *positionLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UIImageView *devGPSImageView;
@property (strong, nonatomic) IBOutlet UIImageView *devGSMImageView;
@property (strong, nonatomic) IBOutlet UIButton *navigationButton;

@property (nonatomic, strong) NSArray *nameColorArr;
@end

@implementation DevPositionPaoPaoView

+ (instancetype)loadXibView {
    return [[[NSBundle mainBundle] loadNibNamed:@"DevPositionPaoPaoView" owner:self options:nil] lastObject];
}

-(void)showBusInfoViewWithDomain:(PositionDomain *)domain {
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    
    self.nameLabel.text = domain.name;
    self.positionLabel.text = domain.desc;
    NSString *devGPSImageStr = @"ic_moon_0";
    NSString *devGSMImageStr = @"ic_base_0";
    if (domain.lati.floatValue == 0 && domain.longi.floatValue == 0) {
        devGPSImageStr = [NSString stringWithFormat:@"ic_moon_%@",@(domain.gpssvs)];
        devGSMImageStr = [NSString stringWithFormat:@"ic_base_%@",@(domain.bssignal)];
        self.timeLabel.text = [NSString stringWithFormat:@"%@ 来自基站定位",domain.time];
    }else{
        devGPSImageStr = [NSString stringWithFormat:@"ic_moon_%@",@(domain.gpssvs)];
        devGSMImageStr = [NSString stringWithFormat:@"ic_base_%@",@(domain.bssignal)];
        self.timeLabel.text = [NSString stringWithFormat:@"%@ 来自卫星定位",domain.time];
    }
    [self.devGPSImageView setImage:[UIImage imageNamed:devGPSImageStr]];
    [self.devGSMImageView setImage:[UIImage imageNamed:devGSMImageStr]];
    
    CGSize positionSize = [self.positionLabel.text calculateSize:CGSizeMake(WIDTH-102.5, 999) font:self.positionLabel.font];
    CGSize timeSize = [self.timeLabel.text calculateSize:CGSizeMake(WIDTH-170, 999) font:self.timeLabel.font];
    
    self.frame = CGRectMake(0, 0, 64 + MAX(positionSize.width, timeSize.width+68), 84 + (positionSize.height > 20 ? positionSize.height : 20));
    
    if (!_nameColorArr) {
        _nameColorArr = @[@"227f00",@"00afaf",@"008cff",@"d300ff",@"f43131"];
    }
   // self.nameLabel.textColor = [UIColor colorWithHexString:_nameColorArr[domain.index]];
}

- (void)drawRect:(CGRect)rect {
    
    [self drawInContext:UIGraphicsGetCurrentContext()];
    
    self.layer.shadowColor = [[UIColor grayColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
}

- (void)drawInContext:(CGContextRef)context {
    CGContextSetLineWidth(context, 2.0);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    
    [self getDrawPath:context];
    CGContextFillPath(context);
}

- (void)getDrawPath:(CGContextRef)context {
    CGRect rrect = self.bounds;
    CGFloat radius = 6.0;
    
    CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect),
    maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-Arror_height;
    CGContextMoveToPoint(context, midx+Arror_height, maxy);
    CGContextAddLineToPoint(context,midx, maxy+Arror_height);
    CGContextAddLineToPoint(context,midx-Arror_height, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

- (IBAction)clickNavigationButtonEvent:(UIButton *)button {
    if (self.navigationButtonBlock) {
        self.navigationButtonBlock();
    }
}

@end

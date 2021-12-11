//
//  G100MapChangeView.m
//  G100
//
//  Created by William on 16/8/23.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100MapChangeView.h"
#import <MAMapKit/MAMapKit.h>

#define Custom_Width        300*(WIDTH/414.0)
#define Custom_Height       100*(WIDTH/414.0)
#define Single_Width        80*(WIDTH/414.0)
#define Single_Height       74*(WIDTH/414.0)
#define Padding             12*(WIDTH/414.0)
#define Horizontal_Spacing  18*(WIDTH/414.0)
#define Vertical_Spacing    14*(WIDTH/414.0)
#define ImageBtn_Height     48*(WIDTH/414.0)
#define TitleBtn_Height     24*(WIDTH/414.0)
#define Btn_Spacing         6*(WIDTH/414.0)
#define Title_Font          14.0f*(WIDTH/414.0)

@interface G100MapChangeView ()

@property (strong, nonatomic) NSArray * mapModeArr;

@property (strong, nonatomic) UIView * backgroundView;

@property (strong, nonatomic) UIButton * closeBtn;

@property (strong, nonatomic) MAMapView * mapView;

@end

@implementation G100MapChangeView

- (NSArray *)mapModeArr {
    if (!_mapModeArr) {
        _mapModeArr = @[@"标准地图", @"卫星地图", @"3D地图"];
    }
    return _mapModeArr;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc]initWithFrame:self.superview.bounds];
        _backgroundView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
        [_backgroundView addGestureRecognizer:tap];
    }
    return _backgroundView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setFrame:CGRectMake(self.anchorPoint.x-40, self.anchorPoint.y-40, 40, 48)];
        [_closeBtn setImage:[UIImage imageNamed:@"ic_map_close"] forState:UIControlStateNormal];
        [_closeBtn setBackgroundImage:CreateImageWithColor([UIColor whiteColor]) forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.layer.masksToBounds = YES;
        _closeBtn.layer.cornerRadius = 6.0f;
        [_closeBtn setExclusiveTouch:YES];
        _closeBtn.alpha = 0;
    }
    return _closeBtn;
}

- (instancetype)initWithMapView:(MAMapView *)mapView position:(CGPoint)position {
    if (self = [super initWithFrame:CGRectMake(position.x-Custom_Width, position.y, Custom_Width, Custom_Height)]) {
        self.mapView = mapView;
        self.anchorPoint = position;
        [self setup];
        [self configView];
    }
    return self;
}

- (void)configView {
    self.backgroundColor = [UIColor whiteColor];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 8.0f;
    self.alpha = 0;
}

- (void)setup {
    for (int i = 0; i < self.mapModeArr.count; i++) {
        UIView * mapClickView = [[UIView alloc]initWithFrame:CGRectMake(Horizontal_Spacing+i*(Single_Width+Padding), Vertical_Spacing, Single_Width, Single_Height)];
        mapClickView.backgroundColor = [UIColor clearColor];
        [mapClickView setTag:i+100];
        
        [self addSubview:mapClickView];
        
        UIImageView * mapImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Single_Width, ImageBtn_Height)];
        NSString * imageStr = nil;
        switch (i) {
            case 0:
                imageStr = @"ic_map_normal";
                break;
            case 1:
                imageStr = @"ic_map_sat";
                break;
            case 2:
                imageStr = @"ic_map_3d";
                break;
            default:
                break;
        }
        mapImage.image = [UIImage imageNamed:imageStr];
        
        [mapClickView addSubview:mapImage];
        
        
        UIButton * titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleBtn setUserInteractionEnabled:NO];
        [titleBtn setFrame:CGRectMake(0, ImageBtn_Height+Btn_Spacing, Single_Width, TitleBtn_Height)];
        [titleBtn setBackgroundImage:[UIImage imageNamed:@"ic_map_unselected"] forState:UIControlStateNormal];
        [titleBtn setBackgroundImage:[UIImage imageNamed:@"ic_map_selected"] forState:UIControlStateSelected];
        
        switch (i) {
            case 0:
                [titleBtn setTitle:@"标准地图" forState:UIControlStateNormal];
                [titleBtn setTitle:@"标准地图" forState:UIControlStateSelected];
                break;
            case 1:
                [titleBtn setTitle:@"卫星地图" forState:UIControlStateNormal];
                [titleBtn setTitle:@"卫星地图" forState:UIControlStateSelected];
                break;
            case 2:
                [titleBtn setTitle:@"3D地图" forState:UIControlStateNormal];
                [titleBtn setTitle:@"3D地图" forState:UIControlStateSelected];
                break;
            default:
                break;
        }
        [titleBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:Title_Font]];
        [titleBtn setTitleColor:[UIColor colorWithHexString:@"0096ff"] forState:UIControlStateNormal];
        [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [mapClickView addSubview:titleBtn];
        
        if (i == 0) { // 初始化默认选择第一个
            titleBtn.selected = YES;
        }
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mapModeChange:)];
        [mapClickView addGestureRecognizer:tap];
    }
}

- (void)setAnchorPoint:(CGPoint)anchorPoint {
    _anchorPoint = anchorPoint;
    self.frame = CGRectMake(anchorPoint.x-Custom_Width, anchorPoint.y, Custom_Width, Custom_Height);
    [self.closeBtn setFrame:CGRectMake(self.anchorPoint.x-40, self.anchorPoint.y-40, 40, 48)];
}

- (void)mapModeChange:(UITapGestureRecognizer *)tap {
    /* 操作当前选中视图状态 */
    for (UIView * view in tap.view.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton * tmpBtn = (UIButton *)view;
            if (tmpBtn.selected == NO) {
                tmpBtn.selected = !tmpBtn.selected;
                [self changeMapModeWithTag:tap.view.tag];
                [self hide];
            }
        }
    }
    /* 操作未选中视图状态 */
    for (UIView * mapView in tap.view.superview.subviews) {
        if (mapView.tag != tap.view.tag) {
            for (UIView * tmpView in mapView.subviews) {
                if ([tmpView isKindOfClass:[UIButton class]]) {
                    UIButton * tmpBtn = (UIButton *)tmpView;
                    if (tmpBtn.selected == YES) {
                        tmpBtn.selected = NO;
                    }
                }
            }
        }
    }
    
}

- (void)changeMapModeWithTag:(NSInteger)tag {
    switch (tag) {
        case 100://标准地图
            if (self.mapView.cameraDegree > 0) {
                [self.mapView setCameraDegree:0 animated:YES duration:.6f];
            }
            [self.mapView setMapType:MAMapTypeStandard];
            break;
        case 101://卫星地图
            if (self.mapView.cameraDegree > 0) {
                [self.mapView setCameraDegree:0 animated:YES duration:.6f];
            }
            [self.mapView setMapType:MAMapTypeSatellite];
            break;
        case 102://3D地图
            [self.mapView setMapType:MAMapTypeStandard];
            [self.mapView setZoomLevel:18.0f animated:YES];
            [self.mapView setCameraDegree:50.0f animated:YES duration:.6f];
            break;
        default:
            break;
    }
}

- (void)show {
    [self.superview insertSubview:self.backgroundView belowSubview:self];
    [self.superview insertSubview:self.closeBtn aboveSubview:self.backgroundView];
    [UIView animateWithDuration:.3f animations:^{
        self.alpha = 1;
        [self.backgroundView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:.7f]];
        self.closeBtn.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hide {
    [UIView animateWithDuration:.3f animations:^{
        self.alpha = 0;
        [self.backgroundView setBackgroundColor:[[UIColor blackColor]colorWithAlphaComponent:0]];
        self.closeBtn.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        [self.closeBtn removeFromSuperview];
        if (self.viewHideCompletion) {
            self.viewHideCompletion();
        }
    }];
}

@end

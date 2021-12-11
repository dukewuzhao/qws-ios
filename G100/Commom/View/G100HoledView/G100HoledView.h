//
//  G100HoledView.h
//  HoledViewTest
//
//  Created by Colin on 15/4/7.
//  Copyright (c) 2015年 icephone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, G100HoleType)
{
    G100HoleTypeCirle,
    G100HoleTypeRect,
    G100HoleTypeRoundedRect,
    G100HoleTypeCustomRect
};


@class G100HoledView;
@protocol G100HoledViewDelegate <NSObject>

- (void)holedView:(G100HoledView *)holedView didSelectHoleAtIndex:(NSUInteger)index;

@end


@interface G100HoledView : UIView

@property (strong, nonatomic) UIColor *dimingColor;
@property (weak, nonatomic) id <G100HoledViewDelegate> holeViewDelegate;

- (NSInteger)addHoleCircleCenteredOnPosition:(CGPoint)centerPoint andDiameter:(CGFloat)diamter;
- (NSInteger)addHoleRectOnRect:(CGRect)rect;
- (NSInteger)addHoleRoundedRectOnRect:(CGRect)rect withCornerRadius:(CGFloat)cornerRadius;
- (NSInteger)addHCustomView:(UIView *)customView onRect:(CGRect)rect;

- (void)addFocusView:(UIView *)focus;

- (void)removeHoles;


@end

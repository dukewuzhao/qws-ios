//
//  G100LocaButton.h
//  G100
//
//  Created by Tilink on 15/5/13.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShortArcLine.h"

@class G100LocateButton;
@protocol G100LocateButtonDelegate <NSObject>

@end

@interface G100LocateButton : UIButton

@property (strong, nonatomic) ShortArcLine * shortline;
@property (assign, nonatomic) BOOL animating;
@property (nonatomic, weak) id<G100LocateButtonDelegate> delegate;

-(void)startAnimation;
-(void)stopAnimation;

@end

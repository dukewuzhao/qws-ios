//
//  EventEntryView.h
//  G100
//
//  Created by yuhanle on 2017/7/13.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^EventEntryViewGetEventDetailBlock)(G100EventDetailDomain *eventDetail);

@class G100EventDomain;
@interface EventEntryView : UIView

@property (strong, nonatomic) G100EventDomain *eventDomain;
@property (copy, nonatomic) EventEntryViewGetEventDetailBlock getEventDetailBlock;

- (void)showEventEntryViewWithEvent:(G100EventDomain *)domain onBaseView:(UIView *)baseView animated:(BOOL)animated;

- (void)hide:(BOOL)hide animated:(BOOL)animated;

@end

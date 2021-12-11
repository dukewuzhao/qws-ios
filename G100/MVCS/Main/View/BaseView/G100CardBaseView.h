//
//  G100CardBaseView.h
//  G100
//
//  Created by William on 16/6/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G100CardBaseView : UIView

@property (assign, nonatomic) BOOL needSingleCtrl;

/**
 *  记录indexPath
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

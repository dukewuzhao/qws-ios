//
//  G100PhotoBrowserViewController.h
//  PhotoPicker
//
//  Created by William on 16/3/23.
//  Copyright © 2016年 William. All rights reserved.
//

#import <UIKit/UIKit.h>

@class G100PhotoBrowserViewController;

@protocol PhotoBrowserDelegate <NSObject>

- (void)photoBrowserViewController:(G100PhotoBrowserViewController*)browser deletedPhoto:(NSString*)url newArray:(NSArray*)photos;
- (void)photoBrowserSetCoverImageUrl:(NSString *)url;
@end

@interface G100PhotoBrowserViewController : UIViewController

@property (nonatomic, weak) id <PhotoBrowserDelegate> delegate;

@property (nonatomic, copy) void (^deletedCompeletionBlock)(NSArray *dataArray);

@property (nonatomic, assign)BOOL isShowCoverBtn;

- (instancetype)initWithPhotos:(NSArray *)photosArray
                  currentIndex:(NSInteger)index;

- (void)hideControls;
- (void)toggleControls;

- (void)setDelBtnHidden:(BOOL)hidden;

@end

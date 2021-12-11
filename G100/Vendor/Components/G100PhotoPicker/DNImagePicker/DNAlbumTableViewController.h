//
//  DNAlbumTableViewController.h
//  ImagePicker
//
//  Created by DingXiao on 15/2/10.
//  Copyright (c) 2015年 Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DNAlbumTableViewController : UITableViewController

@property (nonatomic, assign) NSInteger pickedCount;

/** 最多允许选择的照片数量 默认为5*/
@property (nonatomic, assign) NSInteger maxSeletedNumber;

@end

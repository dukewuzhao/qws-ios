//
//  MemoryCapacityView.m
//  G100
//
//  Created by William on 15/9/1.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "MemoryCapacityView.h"

#define MC_VIEW_HEIGHT 20

#define BACKGROUND_COLOR [UIColor colorWithRed:212/255.0 green:212/255.0 blue:212/255.0 alpha:1.0f];
#define MCVIEW_COLOR [UIColor colorWithRed:66/255.0 green:157/255.0 blue:39/255.0 alpha:1.0f];

@interface MemoryCapacityView ()

@property (nonatomic, strong) UIView *usedView;
@property (nonatomic, strong) UILabel *memoryLabel;

@property (nonatomic, strong) NSString *temp;

@end

@implementation MemoryCapacityView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGSize size = CGSizeMake(frame.size.width, MC_VIEW_HEIGHT/* *frame.size.height/480.0 */);
        self.frame = CGRectMake(0, frame.size.height - size.height, size.width, size.height);
        self.backgroundColor = BACKGROUND_COLOR;
        [self initUsedViewWithFrame:frame];
    }
    return self;
}

- (void)initUsedViewWithFrame:(CGRect)frame {
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSFileManager *fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
    NSString  * str= [NSString stringWithFormat:@"已占用%0.2fG/剩余%0.2fG",([totalSpace longLongValue] - [freeSpace longLongValue])/1024.0/1024.0/1024.0,[freeSpace longLongValue]/1024.0/1024.0/1024.0];
    self.temp = [NSString stringWithFormat:@"%.2f",[freeSpace longLongValue]/1024.0/1024.0/1024.0];
    self.usedView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, (1 - (([freeSpace longLongValue]/1024.0)/([totalSpace longLongValue]/1024.0)))*frame.size.width, MC_VIEW_HEIGHT)];
    self.usedView.backgroundColor = MCVIEW_COLOR;
    [self addSubview:self.usedView];
    
    self.memoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.frame.size.width - 20, MC_VIEW_HEIGHT)];
    self.memoryLabel.text = str;
    self.memoryLabel.textColor = [UIColor whiteColor];
    self.memoryLabel.font = [UIFont systemFontOfSize:12.0f];
    self.memoryLabel.textAlignment = NSTextAlignmentLeft;
    [self.usedView addSubview:self.memoryLabel];
}

- (void)updateMCViewWithFrame:(CGRect)frame {
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
    NSFileManager *fileManager = [[NSFileManager alloc ]init];
    NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
    NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
    NSString *current = [NSString stringWithFormat:@"%.2f",[freeSpace longLongValue]/1024.0/1024.0/1024.0];
    NSLog(@"%@",current);
    if (![self.temp isEqualToString:current]) {
        [self.usedView setV_width:(1 - (([freeSpace longLongValue]/1024.0)/([totalSpace longLongValue]/1024.0)))*frame.size.width];
        NSString  * str= [NSString stringWithFormat:@"已占用%0.2fG/剩余%0.2fG",([totalSpace longLongValue] - [freeSpace longLongValue])/1024.0/1024.0/1024.0,[freeSpace longLongValue]/1024.0/1024.0/1024.0];
        self.memoryLabel.text = str;
        self.temp = current;
    }
}


@end

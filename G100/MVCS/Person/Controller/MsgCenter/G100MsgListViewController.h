//
//  G100MsgListViewController.h
//  G100
//
//  Created by yuhanle on 2018/7/10.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MsgTypeMode) {
    MsgTypeModePersonal = 0,
    MsgTypeModeSystem
};

@protocol G100MsgListViewDelegate <NSObject>
@optional
- (void)msg_needReloadFromDB;
- (void)msg_updateSelectAllStatus:(BOOL)all;
- (void)msg_deleteFinished;

@end

@class G100MsgDomain;
@interface G100MsgListViewController : UIViewController

@property (nonatomic, copy) NSString *userid;

@property (nonatomic, assign) MsgTypeMode msgTypeMode;
@property (nonatomic, strong) NSMutableArray <G100MsgDomain *> *items;

@property (nonatomic, strong) UITableView *listView;

@property (nonatomic, weak) id <G100MsgListViewDelegate> delegate;

#pragma mark - 公开函数
/**  刷新列表数据 */
- (void)reloadUIData;

/** 进入编辑模式 */
- (void)enterEditMode;
- (void)exitEditMode;

/** 删除操作 */
- (void)selectAllItems;
- (void)unSelectAllItems;
- (void)deleteItems;

@end

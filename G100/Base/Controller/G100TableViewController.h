//
//  G100TableViewController.h
//  G100
//
//  Created by Tilink on 15/2/6.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"
#import "MJRefresh.h"

@interface G100TableViewController : G100BaseVC <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray * _dataArray;
    NSMutableArray * _contentArray;
    UITableView * _tableView;
}

@property (nonatomic, strong) UITableView    * tableView;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, strong) NSMutableArray * contentArray;

@end

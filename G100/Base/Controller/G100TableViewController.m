//
//  G100TableViewController.m
//  G100
//
//  Created by Tilink on 15/2/6.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100TableViewController.h"

@interface G100TableViewController ()

@end

@implementation G100TableViewController

@synthesize tableView    = _tableView;
@synthesize dataArray    = _dataArray;
@synthesize contentArray = _contentArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createDataSuper];
    
    [self createTableViewSuper];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if ([self.tableView respondsToSelector:@selector(contentInsetAdjustmentBehavior)]) {
        [self.tableView setValue:@(2) forKey:@"contentInsetAdjustmentBehavior"];
    }
}

#pragma mark - 
#pragma mark - 创建超级TableView
- (void)createDataSuper {
    _dataArray    = [[NSMutableArray alloc]init];
    _contentArray = [[NSMutableArray alloc]init];
}

- (void)createTableViewSuper {
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.contentView.v_width, self.contentView.v_height) style:UITableViewStyleGrouped];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    if (ISIOS7) {
        _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 15, 15);
    }
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    _tableView.sectionHeaderHeight = 1;
    _tableView.sectionFooterHeight = 0;
    
    [self.contentView addSubview:_tableView];
}

#pragma mark - tableViewDataSource & delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

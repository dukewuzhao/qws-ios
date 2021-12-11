//
//  G100BikeTypePickViewController.m
//  G100
//
//  Created by William on 16/4/12.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BikeTypePickViewController.h"

@interface G100BikeTypePickViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSInteger selectedIndex;
}

@property (nonatomic, strong) UITableView *tableview;

@property (nonatomic, strong) NSArray * dataArray;

@end

@implementation G100BikeTypePickViewController

- (NSArray *)dataArray {
    if (!_dataArray) {
        if (self.bikeType ==  0) {
            _dataArray = @[@"滑板车", @"两轮电动车", @"三轮电动车", @"四轮电动车", @"电动自行车", @"其他"];
        }else if (self.bikeType == -1){
            _dataArray = @[@"滑板车", @"两轮电动车", @"三轮电动车", @"四轮电动车", @"电动自行车",@"摩托车", @"其他"];

        }
        else{
            _dataArray = @[ @"摩托车", @"其他"];
        }
    }
    return _dataArray;
}

- (UITableView *)tableview {
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    }
    return _tableview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationTitle:@"车型"];
    
    [self.contentView addSubview:self.tableview];
    [self.tableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    
    if (self.devTypeStr) {
        selectedIndex = [self.dataArray indexOfObject:self.devTypeStr];
    }else{
        selectedIndex = -1;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"devTypeCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    if (indexPath.row != selectedIndex) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }else {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndex = indexPath.row;
    [self.tableview reloadData];
    
    if (self.completePickBlock && selectedIndex >= 0) {
        NSInteger devType;
        if (self.bikeType == 0) {
            switch (selectedIndex) {
                case 0:
                    devType = G100BikeTypeScooter;
                    break;
                case 1:
                    devType = G100BikeTypeTwoWheeled;
                    break;
                case 2:
                    devType = G100BikeTypeThreeWheeled;
                    break;
                case 3:
                    devType = G100BikeTypeFourWheeled;
                    break;
                case 4:
                    devType = G100BikeTypeElectric;
                    break;
                case 5:
                    devType = G100BikeTypeOther;
                    break;
                default:
                    devType = G100BikeTypeScooter;
                    break;
            }
        }else if (self.bikeType == -1){
            switch (selectedIndex) {
                case 0:
                    devType = G100BikeTypeScooter;
                    break;
                case 1:
                    devType = G100BikeTypeTwoWheeled;
                    break;
                case 2:
                    devType = G100BikeTypeThreeWheeled;
                    break;
                case 3:
                    devType = G100BikeTypeFourWheeled;
                    break;
                case 4:
                    devType = G100BikeTypeElectric;
                    break;
                case 5:
                    devType = G100BikeTypeMotor;
                    break;
                case 6:
                    devType = G100BikeTypeOther;
                    break;
                default:
                    devType = G100BikeTypeScooter;
                    break;
            }
        }
        else{
            switch (selectedIndex) {
                case 0:
                    devType = G100BikeTypeMotor;
                    break;
                case 1:
                    devType = G100BikeTypeOther;
                    break;
                default:
                    devType = G100BikeTypeMotor;
                    break;
        }
        }

        self.completePickBlock(self.dataArray[selectedIndex], devType);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

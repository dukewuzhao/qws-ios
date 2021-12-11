//
//  G100FuncSetPromptTimeViewController.m
//  G100
//
//  Created by 天奕 on 16/1/6.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100FuncSetPromptTimeViewController.h"

@interface G100FuncSetPromptTimeViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSInteger selectedIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (strong, nonatomic) NSArray *cellDataArray;

@end

@implementation G100FuncSetPromptTimeViewController

-(NSArray *)cellDataArray {
    if (!_cellDataArray) {
        _cellDataArray = @[@"1分钟",@"3分钟",@"5分钟",@"10分钟",@"持续直至我处理报警提醒"];
    }
    return _cellDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigationTitle:@"响铃时长设置"];
    
    self.contentTableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    selectedIndex = self.selected;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cellDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = self.cellDataArray[indexPath.row];
    if (indexPath.row == selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSString *content = @"当您无操作的时候，您希望最长的响铃时长";
    CGSize contentSize = [content calculateSize:CGSizeMake(WIDTH - 55, 1000) font:[UIFont systemFontOfSize:14]];
    return contentSize.height + 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    backView.backgroundColor = [UIColor clearColor];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, backView.v_width - 35, 30)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    
    [backView addSubview:titleLabel];
    
    titleLabel.text = @"当您无操作的时候，您希望最长的响铃时长";
    
    return backView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndex = indexPath.row;
    NSInteger time = 0;
    switch (selectedIndex) {
        case 0:
            time = 60;
            break;
        case 1:
            time = 180;
            break;
        case 2:
            time = 300;
            break;
        case 3:
            time = 600;
            break;
        case 4:
            time = 0;
            break;
        default:
            break;
    }
    [[G100InfoHelper shareInstance] updateMyDevListWithUserid:self.userid bikeid:self.bikeid devid:self.devid devInfo:@{@"alarm_bell_time" : @(time)}];
    [self.contentTableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

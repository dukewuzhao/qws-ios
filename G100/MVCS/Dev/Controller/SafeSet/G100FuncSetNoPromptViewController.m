//
//  G100FuncSetNoPromptViewController.m
//  G100
//
//  Created by 温世波 on 15/12/31.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100FuncSetNoPromptViewController.h"
#import "G100DevApi.h"
#import "G100BikeApi.h"
@interface G100FuncSetNoPromptViewController () <UITableViewDataSource, UITableViewDelegate> {
    NSInteger _selectedIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation G100FuncSetNoPromptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationTitle:@"报警忽略设置"];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    self.dataArray = @[@"无", @"1分钟", @"2分钟", @"3分钟", @"4分钟", @"5分钟"];
    
    _selectedIndex = _pushIgnoreTime;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    NSString *content = @"为了您车辆的安全，我们不建议您过长时间忽略报警信息";
    CGSize contentSize = [content calculateSize:CGSizeMake(WIDTH - 55, 1000) font:[UIFont systemFontOfSize:14]];
    return contentSize.height + 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView * backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 30)];
    backView.backgroundColor = [UIColor clearColor];
    
    UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, backView.v_width - 35, 30)];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    
    [backView addSubview:titleLabel];
    
    titleLabel.text = @"为了您车辆的安全，我们不建议您过长时间忽略报警信息";
    CGSize textSize = [titleLabel.text calculateSize:CGSizeMake(titleLabel.v_width, 1000) font:titleLabel.font];
    titleLabel.v_height = textSize.height + 8;
    backView.v_height = titleLabel.v_height;
    
    return backView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identifier = @"timeremaincell";
    UITableViewCell * viewCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!viewCell) {
        viewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    viewCell.textLabel.font = [UIFont systemFontOfSize:16];
    viewCell.textLabel.text = self.dataArray[indexPath.row];
    
    if (indexPath.row != _selectedIndex) {
        [viewCell setAccessoryType:UITableViewCellAccessoryNone];
    }else {
        [viewCell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    return viewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (kNetworkNotReachability) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    if (indexPath.row == _selectedIndex) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    [[G100BikeApi sharedInstance] setSamePushIgnoreWithBikeid:self.bikeid ignoretime:indexPath.row callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if (requestSuccess) {
            _selectedIndex = indexPath.row;
            
            [self.tableView reloadData];
            
            // 更新电动车列表信息
            [[UserManager shareManager] updateDevInfoWithUserid:self.userid bikeid:self.bikeid devid:self.devid complete:nil];
        }else {
            [self showHint:response.errDesc];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

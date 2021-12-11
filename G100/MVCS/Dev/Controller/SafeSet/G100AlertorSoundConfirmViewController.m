//
//  G100AlertorSoundConfirmViewController.m
//  G100
//
//  Created by yuhanle on 16/9/7.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100AlertorSoundConfirmViewController.h"
#import "G100DevApi.h"

#import "SoundManager.h"

@interface G100AlertorSoundConfirmViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *soundMap;

@end

@implementation G100AlertorSoundConfirmViewController

#pragma mark - UITableViewDelegate && UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sound_confirm"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"sound_confirm"];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    }
    
    cell.textLabel.text = [self.soundMap objectForKey:[NSString stringWithFormat:@"%@", @(indexPath.row)]];
    
    if (indexPath.row == self.func.sound) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [[G100DevApi sharedInstance] setAlertorSoundWithBikeid:self.bikeid devid:self.devid func:self.func.func sound:indexPath.row callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [[UserManager shareManager] updateDevInfoWithUserid:self.userid bikeid:self.bikeid devid:self.devid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
                self.func.sound = indexPath.row;
                [self.tableView reloadData];
            }];
        }else {
            [self showHint:response.errDesc];
        }
    }];
    
    if (indexPath.row == 0) {
        [[SoundManager sharedManager] stopAlertSound];
    }else {
        [[SoundManager sharedManager] trialListenRingtones:[self.func soundNameWithFunc:self.func.func sound:indexPath.row] ofType:@"m4a" cycleNumber:0];
    }
}

#pragma mark - setup
- (void)setupView {
    [self setNavigationTitle:self.func.funcName];
    
    [self.contentView addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
}

- (void)setupData {
    
}

#pragma mark - Lazy Load
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 44;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    }
    return _tableView;
}
- (NSDictionary *)soundMap {
    if (!_soundMap) {
        _soundMap = @{
                      @"0" : @"无",
                      @"1" : @"舒缓音",
                      @"2" : @"普通音"
                      };
    }
    return _soundMap;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupData];
    
    [self setupView];
}

- (void)dealloc {
    [[SoundManager sharedManager] stopAlertSound];
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

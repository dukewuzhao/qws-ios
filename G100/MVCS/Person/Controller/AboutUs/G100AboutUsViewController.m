//
//  G100AboutUsViewController.m
//  G100
//
//  Created by William on 15/10/12.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100AboutUsViewController.h"
#import "WechatQRView.h"
#import "Appirater.h"
#import <JPFPSStatus.h>

@interface G100AboutUsViewController () <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) NSArray *projects;
@property (strong, nonatomic) NSArray *details;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;

@end

@implementation G100AboutUsViewController

#pragma mark - Lazy load
- (NSArray*)projects {
    if (!_projects) {
        _projects = @[@"微博",@"微信公众号",@"官网地址",@"客服电话",@"客服微信号",@"VIP QQ群"];
    }
    return _projects;
}

- (NSArray*)details {
    if (!_details) {
        _details = @[@"@骑卫士",@"骑卫士",@"www.qiweishi.com",@"400-920-2890",@"qwsqiqi",@"439986893"];
    }
    return _details;
}

#pragma mark - Private Method
- (void)updateVersionLabel {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *svn_resversion = [infoDictionary objectForKey:@"SVN-Reversion"];
    
    NSString *app_version = [NSString stringWithFormat:@"%@.%@", [infoDictionary objectForKey:@"CFBundleShortVersionString"], svn_resversion];
    NSString *app_build = [NSString stringWithFormat:@"%@-%@", app_version, [infoDictionary objectForKey:@"CFBundleVersion"]];
    self.versionLabel.text = [NSString stringWithFormat:@"版本 %@ %@", ISProduct ? app_version : app_build, [UserManager shareManager].env.length ? @"公测模式" : @""];
}

- (void)doubleTapAction:(UITapGestureRecognizer *)sender {
//    if ([[JPFPSStatus sharedInstance].fpsLabel superview]) {
//        [[JPFPSStatus sharedInstance] close];
//        return;
//    }
//
//    [[JPFPSStatus sharedInstance] open];
//    if (ISIPHONEX) {
//        [JPFPSStatus sharedInstance].fpsLabel.frame = CGRectMake(20, 0, 50, 20);
//    }
    
    [[UserManager shareManager] runTestUa];
    [self updateVersionLabel];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return 1;
    }
    return 6;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 35)];
        UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(20*(WIDTH/414.0), 0, WIDTH, 35)];
        headerLabel.font = [UIFont systemFontOfSize:14.0f];
        headerLabel.textColor = RGBColor(168, 168, 168, 1);
        headerLabel.text = @"关于我们";
        [customView addSubview:headerLabel];
        return customView;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 35;
    }
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    cell.textLabel.textColor = RGBColor(69, 69, 69, 1);
    cell.detailTextLabel.font = [UIFont systemFontOfSize:16.0f];
    cell.detailTextLabel.textColor = RGBColor(0, 168, 255, 1);
    if (0 == indexPath.section) {
        cell.textLabel.text = @"喜欢我们，打分鼓励";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.textLabel.text = self.projects[indexPath.row];
        cell.detailTextLabel.text = self.details[indexPath.row];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (0 == indexPath.section) {
        [Appirater rateApp];
    }else{
        switch (indexPath.row) {
            case 0:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://weibo.com/360qws"]];
                break;
            case 1:
            {
                /*
                if ([WXApi isWXAppInstalled]) {
                    JumpToBizProfileReq *req = [[JumpToBizProfileReq alloc] init];
                    req.profileType = WXBizProfileType_Normal;
                    req.username = @"gh_ff67146ac148";
                    [WXApi sendReq:req];
                }else {
                    WechatQRView *wechatQRView = [[[NSBundle mainBundle]loadNibNamed:@"WechatQRView" owner:self options:nil] firstObject];
                    [wechatQRView showInVc:self view:self.view animation:YES];
                }
                 */
                
                /** 
                 * 微信沟通接口失效
                if ([WXApi isWXAppInstalled]) {
                    JumpToBizWebviewReq *req = [[JumpToBizWebviewReq alloc] init];
                    req.tousrname = @"gh_ff67146ac148";
                    [WXApi sendReq:req];
                }else {
                    WechatQRView *wechatQRView = [[[NSBundle mainBundle]loadNibNamed:@"WechatQRView" owner:self options:nil] firstObject];
                    [wechatQRView showInVc:self view:self.view animation:YES];
                }
                 */
                
                WechatQRView *wechatQRView = [[[NSBundle mainBundle]loadNibNamed:@"WechatQRView" owner:self options:nil] firstObject];
                [wechatQRView showInVc:self view:self.view animation:YES];
            }
                break;
            case 2:
                [G100Router openURL:@"https://www.qiweishi.com"];
                break;
            case 3:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://400-920-2890"]];
                break;
            case 4:
            {
                [self.contentTableView becomeFirstResponder];
                UIMenuController *menu = [UIMenuController sharedMenuController];
                UIMenuItem *item = [[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(copyQwsQiQiText)];
                menu.menuItems = @[item];
                [menu setTargetRect:CGRectMake(WIDTH - 70, self.contentTableView.contentSize.height - 110, 50, 20) inView:self.contentTableView];
                [menu setMenuVisible:YES animated:YES];
            }
                break;
            case 5:
            {
                /* 友盟社会化暂不支持 QQ一键加群的功能
                 QQApiJoinGroupObject *wpaObj = [QQApiJoinGroupObject objectWithGroupInfo:@"439986893" key:@"1234"];
                 SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:wpaObj];
                 QQApiSendResultCode sent = [QQApiInterface sendReq:req];
                 */
                
                [self.contentTableView becomeFirstResponder];
                UIMenuController *menu = [UIMenuController sharedMenuController];
                UIMenuItem *item = [[UIMenuItem alloc]initWithTitle:@"复制" action:@selector(copyText)];
                menu.menuItems = @[item];
                [menu setTargetRect:CGRectMake(WIDTH - 80, self.contentTableView.contentSize.height - 70, 50, 20) inView:self.contentTableView];
                [menu setMenuVisible:YES animated:YES];
            }
                break;
            default:
                break;
        }
    }
}

#pragma mark - Copyboard
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copyText) ||
        action == @selector(copyQwsQiQiText)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)copyText {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"439986893";
    [self showHint:@"已复制至粘帖板"];
}

- (void)copyQwsQiQiText {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = @"qwsqiqi";
    [self showHint:@"已复制至粘帖板"];
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationTitle:@"关于"];
    self.contentTableView.showsVerticalScrollIndicator = NO;
    self.contentTableView.contentInset = UIEdgeInsetsMake(0, 0, kBottomPadding, 0);
    self.contentTableView.tableHeaderView = self.headerView;
    self.contentTableView.tableFooterView = self.footerView;
    
    // 版权信息
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    self.copyrightLabel.text = [NSString stringWithFormat:@"版权所有  2016-%@  qiweishi.com", @([dateComponent year])];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 3;
    self.versionLabel.userInteractionEnabled = YES;
    [self.versionLabel addGestureRecognizer:doubleTap];
    
    [self updateVersionLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

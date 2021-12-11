//
//  G100UserInfoViewController.m
//  G100
//
//  Created by sunjingjing on 16/7/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100UserInfoViewController.h"
#import "ModifyUsernameViewController.h"
#import "ModifyIDCarNumViewController.h"
#import "G100BaseArrowItem.h"
#import "G100BaseCell.h"
#import "EBKAvatarCell.h"
#import "G100PickActionSheet.h"

#import "G100AccountDomain.h"
#import "G100UserDomain.h"
#import "G100UserApi.h"

static NSString * const kBaseItemKeyAddIcon          = @"addIcon";
static NSString * const kBaseItemKeyUserNickName     = @"nick_name";
static NSString * const kBaseItemKeyUserGender       = @"gender";
static NSString * const kBaseItemKeyUserBirthday     = @"birthday";

@interface G100UserInfoViewController () <UITableViewDelegate, UITableViewDataSource,
UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) G100BaseItem *iconAddItem;
@property (nonatomic, strong) G100BaseArrowItem *nick_nameItem;
@property (nonatomic, strong) G100BaseArrowItem *birthdayItem;
@property (nonatomic, strong) G100BaseArrowItem *genderItem;

@property (strong, nonatomic) EBKAvatarCell   *iconCell;
@property (strong, nonatomic) UIButton *skipButton;
@property (strong, nonatomic) UIImage *iconCellImage;
@property (copy, nonatomic) NSString *pictureString;

@end

@implementation G100UserInfoViewController

#pragma mark - Items
-(G100BaseItem *)iconAddItem
{
    if (!_iconAddItem) {
        _iconAddItem = [[G100BaseItem alloc] init];
        _iconAddItem.title = @"添加头像";
        _iconAddItem.icon = @"ic_default_female";
        _iconAddItem.itemkey = kBaseItemKeyAddIcon;
    }
    return _iconAddItem;
}
- (G100BaseArrowItem *)nick_nameItem {
    if (!_nick_nameItem) {
        _nick_nameItem = [[G100BaseArrowItem alloc] init];
        _nick_nameItem.title = @"昵称";
        _nick_nameItem.subtitle = @"骑卫士001";
        _nick_nameItem.itemkey = kBaseItemKeyUserNickName;
    }
    return _nick_nameItem;
}
- (G100BaseArrowItem *)genderItem {
    if (!_genderItem) {
        _genderItem = [[G100BaseArrowItem alloc] init];
        _genderItem.title = @"性别";
        _genderItem.subtitle =  @"女";
        _genderItem.itemkey = kBaseItemKeyUserGender;
    }
    return _genderItem;
}
- (G100BaseArrowItem *)birthdayItem {
    if (!_birthdayItem) {
        _birthdayItem = [[G100BaseArrowItem alloc] init];
        _birthdayItem.title = @"生日";
        _birthdayItem.subtitle = @"1985-01-01";
        _birthdayItem.itemkey = kBaseItemKeyUserBirthday;
    }
    return _birthdayItem;
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSArray arrayWithObjects:self.iconAddItem, self.nick_nameItem, self.genderItem, self.birthdayItem, nil] mutableCopy];
    }
    return _dataArray;
}

#pragma mark - initData
- (void)initialData {
    if (!_userid) {
        _userid = [[G100InfoHelper shareInstance] buserid];
    }
    
    [self dataArray];
    
    self.nick_nameItem.subtitle = (self.screen_name.length ? self.screen_name : [NSString stringWithFormat:@"骑卫士%@", self.userid]);
}

#pragma - mark - setupView
- (void)setupView
{
    [self setNavigationTitle:@"基本信息"];
    [self configRightButton];
    [self setNavigationBarViewColor:[UIColor blackColor]];
    self.saveButton.layer.cornerRadius = 22.0f/3;
}
-(void)configRightButton
{
    _skipButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _skipButton.frame = CGRectMake(0, 0, 60, 30);
    _skipButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [_skipButton setTitle:@"跳过" forState:UIControlStateNormal];
    [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_skipButton addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self setRightNavgationButton:_skipButton];
}

#pragma mark - 保存用户信息
- (void)rightButtonClick
{
    __weak G100UserInfoViewController * wself = self;
    [[UserManager shareManager] updateUserInfoWithUserid:self.userid complete:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            [wself.navigationController dismissViewControllerAnimated:YES completion:^{
                if (wself.loginResult) {
                    wself.loginResult([[G100InfoHelper shareInstance] buserid], YES);
                }
            }];
        }
    }];
}
- (IBAction)saveBaseInfo:(id)sender {
    
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    __weak G100UserInfoViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSucces){
        [wself hideHud];
        if (requestSucces) {
            [wself showHint:@"保存成功"];
            [wself rightButtonClick];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    NSString *gender;
    if ([self.genderItem.subtitle isEqualToString:@"男"]) {
        gender = @"1";
    }else
    {
        gender = @"2";
    }
    if ([NSString checkNickname:self.nick_nameItem.subtitle]) {
        [self showHint:[NSString checkNickname:self.nick_nameItem.subtitle]];
        return;
    }
    [[G100UserApi sharedInstance] sv_updateUserdataWithUserinfo:@{
                                                                  @"icon" : EMPTY_IF_NIL(self.pictureString),
                                                                  @"nick_name" : EMPTY_IF_NIL(self.nick_nameItem.subtitle),
                                                                  @"gender" : EMPTY_IF_NIL(gender),
                                                                  @"birthday" : self.birthdayItem.subtitle
                                                                  } callback:callback];
}

#pragma mark - TableView Delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    G100BaseItem *item = [self.dataArray safe_objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0) {
        EBKAvatarCell *iconCell = [tableView dequeueReusableCellWithIdentifier:@"EBKAvatarCell"];
        self.iconCell = iconCell;
        if (self.iconCell && self.iconCellImage) {
            [self.iconCell.avatarImageView setImage:self.iconCellImage];
        }else {
            [self.iconCell.avatarImageView setImage:[UIImage imageNamed:item.icon]];
        }
        self.iconCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return self.iconCell;
    }else {
        G100BaseCell *viewCell= [G100BaseCell cellWithTableView:tableView item:item];
        viewCell.item = item;
        viewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return viewCell;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //头像
        __weak G100UserInfoViewController * wself = self;
        G100PickActionSheet *actionSheet = [[G100PickActionSheet alloc]initWithTitle:@"修改头像" clickedAtIndex:^(NSInteger index) {
            if (index)
                [wself configPhotoPickWithIndex:index];
        } cancelButtonTitle:@"取消" otherButtonTitles:@"相机",@"相册",nil];
        [actionSheet show];
        return;
    }
    G100BaseArrowItem *item = [self.dataArray safe_objectAtIndex:indexPath.row];
    if ([item.itemkey isEqualToString:kBaseItemKeyUserNickName]) {
        // 昵称
        ModifyUsernameViewController * modify = [[ModifyUsernameViewController alloc]init];
        modify.username = item.subtitle;
        modify.sureBlock = ^(NSString * nickname){
            item.subtitle = nickname;
            [tableView reloadData];
        };
        [self.navigationController pushViewController:modify animated:YES];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUserGender]) {
        // 性别
        G100PickActionSheet *actionSheet = [[G100PickActionSheet alloc] initWithTitle:@"性别" clickedAtIndex:^(NSInteger index) {
            if (index) {
                item.subtitle = index == 1 ? @"男" : @"女";
                self.iconAddItem.icon = index == 1 ? @"ic_default_male":@"ic_default_female";
                [self.dataArray replaceObjectAtIndex:0 withObject:self.iconAddItem];
                [tableView reloadData];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"男",@"女",nil];
        [actionSheet show];
    }else if ([item.itemkey isEqualToString:kBaseItemKeyUserBirthday]) {
        // 生日
        [G100AlertView G100DatePickerWithTitle:@"生日" current:item.subtitle alertBlock:^(NSString * selectStr) {
            item.subtitle = selectStr;
            [tableView reloadData];
        }];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row ==0) {
        return 116;
    }
    
    return 46;
}
- (void)configPhotoPickWithIndex:(NSInteger)buttonIndex {
    // 修改头像
    UIImagePickerController * pc = [[UIImagePickerController alloc]init];
    pc.allowsEditing = YES;
    pc.delegate = self;
    if (buttonIndex == 1) {
        // 设置资源类型 --》 先要检测要设置的资源类型是否可用
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [pc setSourceType:UIImagePickerControllerSourceTypeCamera];
            // 根据开发习惯，UIImagePickerController以present的形式出现
            [self presentViewController:pc animated:YES completion:nil];
            
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
            {
                if (ISIOS8ADD) {
                    [MyAlertView MyAlertWithTitle:@"允许使用相机" message:@"相机未开启，请进入系统【设置】>【隐私】>【相机】中打开开关，并允许骑卫士使用您的相机" delegate:self withMyAlertBlock:^(NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                    } cancelButtonTitle:@"取消" otherButtonTitles:@"前去允许"];
                }else{
                    [MyAlertView MyAlertWithTitle:@"允许使用相机" message:@"相机未开启，请进入系统【设置】>【隐私】>【相机】中打开开关，并允许骑卫士使用您的相机" delegate:self withMyAlertBlock:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了"];
                }
            }
        }
        else {
            UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"提示" message:@"相机不可用" delegate:self cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
            [av show];
        }
    } else if (buttonIndex == 2) {
        // 相册选择
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            pc.navigationBar.barTintColor = Color_NavigationBGColor;
            pc.navigationItem.title = @"照片";
            
            [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:20]};
            
            [pc setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:pc animated:YES completion:nil];
        }
        else {
            UIAlertView * av = [[UIAlertView alloc]initWithTitle:@"提示" message:@"相册不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            [av show];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate相关
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 选择完成 --> 判断选择完成的资源是image还是media
    NSString * str = [info objectForKey:UIImagePickerControllerMediaType];
    if ([str isEqualToString:(NSString *)kUTTypeImage]) {
        // 若果取到的资源是image --》 把image显示在——photoIv上
        UIImage * originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
        UIImage * image = [self thumbnailWithImageWithoutScale:originalImage size:CGSizeMake(100, 100)];
        
        NSData * data = UIImageJPEGRepresentation(image, 1.0f);
        if (!data) {
            data = UIImagePNGRepresentation(image);
        }
        
        self.iconCellImage = image;
        [self.tableView reloadData];
        if (kNetworkNotReachability) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self showHint:kError_Network_NotReachable];
            return;
        }
        
        self.pictureString = [GTMBase64 stringByEncodingData:data];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
}

- (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }else {
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        }else {
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return newimage;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"EBKAvatarCell" bundle:nil] forCellReuseIdentifier:@"EBKAvatarCell"];
    
    self.subStanceViewtoTopConstraint.constant = kNavigationBarHeight + 8;
    
    [self initialData];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

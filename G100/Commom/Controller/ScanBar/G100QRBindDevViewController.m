//
//  G100QRBindDevViewController.m
//  G100
//
//  Created by yuhanle on 16/6/29.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100QRBindDevViewController.h"
#import "G100BindDevViewController.h"
#import "ZBarReaderController.h"

#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVMediaFormat.h>

@interface G100QRBindDevViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, AVAudioPlayerDelegate>
{
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    BOOL _isTurnOnFlash;
    int _mode;
}

@property (nonatomic, strong) NSArray * dropMenuOptions;

@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UILabel *topHintLabel;
@property (nonatomic, strong) UIView *waitScanView;

@property (nonatomic, strong) UIImageView                *line;
@property (strong, nonatomic) AVCaptureDevice            *defaultDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *defaultDeviceInput;
@property (strong, nonatomic) AVCaptureDevice            *frontDevice;
@property (strong, nonatomic) AVCaptureDeviceInput       *frontDeviceInput;
@property (strong, nonatomic) AVCaptureMetadataOutput    *metadataOutput;
@property (strong, nonatomic) AVCaptureSession           *session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

/**
 中间扫描区域
 */
@property (strong, nonatomic) UIView *scanView;

/**
 扫描区域底部的友情提示
 */
@property (strong, nonatomic) UILabel *hintLabel;

/**
 页面底部的手动绑定入口
 */
@property (strong, nonatomic) UIView *coverBottomView;


/**
 打开手电筒 && 从相册添加
 */
@property (nonatomic, strong) UIView *toolView;

@property (nonatomic, strong) UILabel *openLightLabel;

@property (nonatomic, strong) UIButton *openLight;

@property (copy, nonatomic) void (^completionBlock) (NSString *);
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) BOOL lastResult;

@end


@implementation G100QRBindDevViewController

- (void)dealloc {
    DLog(@"扫码绑定设备页面已释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialData];
    
    [self setupView];
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        if (ISIOS8ADD) {
            [MyAlertView MyAlertWithTitle:@"允许使用相机"
                                  message:@"相机未开启，请进入系统【设置】>【隐私】>【相机】中打开开关，并允许骑卫士使用您的相机"
                                 delegate:self
                         withMyAlertBlock:^(NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
            }
                        cancelButtonTitle:@"取消"
                        otherButtonTitles:@"前去允许"];
        }else {
            [MyAlertView MyAlertWithTitle:@"允许使用相机"
                                  message:@"相机未开启，请进入系统【设置】>【隐私】>【相机】中打开开关，并允许骑卫士使用您的相机"
                                 delegate:self
                         withMyAlertBlock:nil
                        cancelButtonTitle:nil
                        otherButtonTitles:@"我知道了"];
        }
    }
}

- (void)initialData {
    if (!_userid) {
        _userid = [[G100InfoHelper shareInstance] buserid];
    }
    
    _isTurnOnFlash = NO;
    _lastResult = YES;
    
}

- (void)setupView {
    [self setNavigationTitle:@"扫码添加设备"];
   
    self.scanView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240 * (WIDTH /414.00), 240* (WIDTH /414.00))];
    if (ISIPHONE_4) {
        self.scanView.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
    }else{
           self.scanView.center = self.view.center;
    }
 
    [self.view addSubview:self.scanView];
    
    UIImageView *boxImageView = [[UIImageView alloc] init];
    boxImageView.image = [UIImage imageNamed:@"ic_bind_box"];
    boxImageView.frame = self.scanView.bounds;
    [self.scanView addSubview:boxImageView];
    
    [self setupAVComponents];
    [self configureDefaultComponents];
    [self setupUIComponentsWithCancelButtonTitle:@"取消"];
    
    [self.view.layer addSublayer:self.previewLayer];
    [self addFourClearView];
    
    [self.view bringSubviewToFront:self.navigationBarView];
    [self.view bringSubviewToFront:self.scanView];
    
    [self.view addSubview:self.topHintLabel];
    self.topHintLabel.frame = CGRectMake(0, self.scanView.v_top - 50, self.view.frame.size.width, 30);
    self.topHintLabel.hidden = YES;
    
    [self.view addSubview:self.hintLabel];
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.scanView.mas_bottom).with.offset(@10);
    }];
    
    [self.view addSubview:self.coverBottomView];
    [self.coverBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.trailing.equalTo(@0);
        make.bottom.equalTo(0);
        make.height.equalTo(60+kBottomPadding);
    }];

    [self.view addSubview:self.toolView];
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.coverBottomView.mas_top).offset(-40 * (WIDTH / 414.00));
        make.height.equalTo(100);
        make.leading.trailing.equalTo(self.view);
    }];
    
    [self.view addSubview:self.waitScanView];
    [self.waitScanView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(kNavigationBarHeight);
        make.leading.trailing.bottom.equalTo(@0);
    }];
    
    self.moreBtn.hidden = YES;
}

- (void)addFourClearView {
    CGRect rect1 = CGRectMake(0, 0, _scanView.v_left, self.view.v_height);
    CGRect rect2 = CGRectMake(_scanView.v_left, 0, _scanView.v_width, _scanView.v_top);
    CGRect rect3 = CGRectMake(_scanView.v_right, 0, _scanView.v_left, self.view.v_height);
    CGRect rect4 = CGRectMake(_scanView.v_left, _scanView.v_bottom, _scanView.v_width, self.view.v_height - _scanView.v_bottom);
    
    NSArray * rects = @[NSStringFromCGRect(rect1), NSStringFromCGRect(rect2), NSStringFromCGRect(rect3), NSStringFromCGRect(rect4)];
    for (NSString * tmp in rects) {
        CGRect rect = CGRectFromString(tmp);
        UIView * clearView = [[UIView alloc]initWithFrame:rect];
        clearView.backgroundColor = RGBColor(0, 0, 0, 0.6);
        
        [self.view addSubview:clearView];
    }
}

- (void)setupAVComponents
{
    self.defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (_defaultDevice) {
        self.defaultDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_defaultDevice error:nil];
        self.metadataOutput     = [[AVCaptureMetadataOutput alloc] init];
        // 设置扫描区域
        CGFloat x = (self.view.v_width - _scanView.v_width) / 2.0 / self.view.v_width;
        CGFloat y = _scanView.v_top / self.view.v_height;
        CGFloat w = _scanView.v_width / self.view.v_width;
        CGFloat h = _scanView.v_height / self.view.v_height;
        
        [_metadataOutput setRectOfInterest:CGRectMake(y, x, h, w)];
        
        self.session            = [[AVCaptureSession alloc] init];
        [self.session setSessionPreset:AVCaptureSessionPreset640x480];
        self.previewLayer       = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if (device.position == AVCaptureDevicePositionFront) {
                self.frontDevice = device;
            }
        }
        
        if (_frontDevice) {
            self.frontDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_frontDevice error:nil];
        }
    }
}

- (void)configureDefaultComponents
{
    [_session addOutput:_metadataOutput];
    
    if (_defaultDeviceInput) {
        [_session addInput:_defaultDeviceInput];
    }
    
    [_metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if ([[_metadataOutput availableMetadataObjectTypes] containsObject:AVMetadataObjectTypeQRCode]) {
        [_metadataOutput setMetadataObjectTypes:@[ AVMetadataObjectTypeQRCode ]];
    }
    [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_previewLayer setFrame:self.view.bounds];
}

#pragma mark - AVCaptureMetadataOutputObjects Delegate Methods
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] >0) {
        for(AVMetadataObject *current in metadataObjects) {
            if ([current isKindOfClass:[AVMetadataMachineReadableCodeObject class]]
                && [current.type isEqualToString:AVMetadataObjectTypeQRCode]) {
                NSString *scannedResult = [(AVMetadataMachineReadableCodeObject *) current stringValue];
                
                if (scannedResult) {
                    [self performSelectorOnMainThread:@selector(reportScanResult:) withObject:scannedResult waitUntilDone:NO];
                }
            }
        }
    }
}

- (void)reportScanResult:(NSString *)scannedResult
{
    [self stopScanning];
    if (!_lastResult) {
        return;
    }
    _lastResult = NO;
    
    if ([self respondsToSelector:@selector(reader:didScanResult:)]) {
        [self loadBeepSound];
        [_audioPlayer play];
        [self reader:self didScanResult:scannedResult];
    }
    
    // 以下处理了结果，继续下次扫描
    _lastResult = YES;
}

#pragma mark - QRCodeReader Delegate Methods
- (void)reader:(G100QRBindDevViewController *)reader didScanResult:(NSString *)result {
    // 处理扫描结果
    if (self.completionBlock) {
        self.completionBlock(result);
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    // 播放完成后 -> 继续其他音乐APP 播放
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

#pragma mark - Managing the Block

- (void)setCompletionWithBlock:(void (^) (NSString *resultAsString))completionBlock
{
    self.completionBlock = completionBlock;
}

#pragma mark - Initializing the AV Components

- (void)setupUIComponentsWithCancelButtonTitle:(NSString *)cancelButtonTitle
{
    upOrdown = NO;
    num =0;
    if (!_line) {
        _line = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, _scanView.frame.size.width - 20, 2)];
        _line.image = [UIImage imageNamed:@"ic_bind_line"];
        [self.scanView addSubview:_line];
    }
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _line.frame = CGRectMake(10, 10 + 2*num, _scanView.v_width - 20, 2);
        if (2*num >= _scanView.v_height - 20) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        _line.frame = CGRectMake(10, 10 + 2*num, _scanView.v_width - 20, 2);
        if (num <= 0) {
            upOrdown = NO;
        }
    }
}

#pragma mark - 开灯关灯
- (void)turnTorchOn:(BOOL)on {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            if (on) {
                _isTurnOnFlash = YES;
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];
            } else {
                _isTurnOnFlash = NO;
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

#pragma mark - Checking the Metadata Items Types
+ (BOOL)isAvailable
{
    @autoreleasepool {
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if (!captureDevice) {
            return NO;
        }
        
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        
        if (!deviceInput || error) {
            return NO;
        }
        
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        if (![output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            return NO;
        }
        
        return YES;
    }
}

#pragma mark - 扫描成功声音
-(void)loadBeepSound {
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"wav"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    NSError *error;
    
    if (!_audioPlayer) {
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
        _audioPlayer.delegate = self;
    }
    
    if (error) {
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        [_audioPlayer prepareToPlay];
    }
}

#pragma mark - Controlling Reader
- (void)startScanning {
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:.02f target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    }
    
    num = 0;
    upOrdown = NO;
    _isProcessing = NO;
    
    [timer setFireDate:[NSDate distantPast]];
    
    if (![self.session isRunning]) {
        [self.session startRunning];
        self.lastResult = YES;
    }
}

- (void)stopScanning {
    [timer setFireDate:[NSDate distantFuture]];
    _line.frame = CGRectMake(10, 10, _scanView.v_width - 20, 2);
    num = 0;
    upOrdown = NO;
    if ([self.session isRunning]) {
        [self.session stopRunning];
    }
    
    _isTurnOnFlash = NO;
}

- (void)setSaoYiSaoMode:(int)mode {
    _mode = mode;
    
    if (mode == 1) {
        self.coverBottomView.hidden = NO;
        
        [self setNavigationTitle:@"扫码添加设备"];
        self.hintLabel.text = @"请将摄像头对准说明书或者设备上的二维码，即可自动扫描";
    }else {
        self.coverBottomView.hidden = YES;
        
        [self setNavigationTitle:@"扫一扫"];
        self.hintLabel.text = @"您可以扫描设备二维码或者车辆二维码进行绑定";
    }
}

#pragma mark - Action Method
- (void)manuallyAddNewDevice {
    G100BindDevViewController *manauallyVc = [[G100BindDevViewController alloc] init];
    manauallyVc.userid = self.userid;
    manauallyVc.bikeid = self.bikeid;
    manauallyVc.devid = self.devid;
    manauallyVc.bindMode = 2;
    manauallyVc.operationMethod = self.operationMethod;
    [self.navigationController pushViewController:manauallyVc animated:YES];
}
- (void)qr_selectLocalAlbumPicturetoGetQRCode {
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    photoPicker.view.backgroundColor = [UIColor whiteColor];
    photoPicker.navigationBar.barTintColor = Color_NavigationBGColor;
    photoPicker.navigationItem.title = @"照片";
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                         NSFontAttributeName : [UIFont boldSystemFontOfSize:20]};
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage * srcImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSString *result = [self decodeQRImageWith:srcImage];
    
    _isProcessing = YES;
    [self stopScanning];
    
    if (result) {
        [self loadBeepSound];
        [_audioPlayer play];
        [self reader:self didScanResult:result];
    }else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"请确认选择的图片中包含二维码，否则将无法识别"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"确定", nil];
        alertView.tag = 1000;
        alertView.delegate = self;
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        _isProcessing = NO;
        [self startScanning];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
}

// decode
- (NSString *)decodeQRImageWith:(UIImage*)aImage {
    NSString *qrResult = nil;
    if (aImage.size.width < 641) {
        aImage = [aImage imageByScalingToSize:CGSizeMake(640, 640)];
    }
    
    ZBarReaderController* read = [ZBarReaderController new];
    CGImageRef cgImageRef = aImage.CGImage;
    ZBarSymbol* symbol = nil;
    for(symbol in [read scanImage:cgImageRef]) break;
    qrResult = symbol.data ;
    return qrResult;
}

#pragma mark - Lazzy Load
- (UILabel *)topHintLabel {
    if (!_topHintLabel) {
        _topHintLabel = [[UILabel alloc] init];
        _topHintLabel.text = @"扫描二维码绑定";
        _topHintLabel.textAlignment = NSTextAlignmentCenter;
        _topHintLabel.textColor = [UIColor whiteColor];
    }
    return _topHintLabel;
}

- (UIView *)waitScanView {
    if (!_waitScanView) {
        _waitScanView = [[UIView alloc] init];
        _waitScanView.backgroundColor = [UIColor colorWithHexString:@"000000" alpha:1.0];
        UIActivityIndicatorView *ac=  [[UIActivityIndicatorView alloc] init];
        ac.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        ac.hidesWhenStopped = YES;
        [ac startAnimating];
        [_waitScanView addSubview:ac];
        
        [ac mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_waitScanView);
        }];
    }
    return _waitScanView;
}

- (UIView *)coverBottomView {
    if (!_coverBottomView) {
        _coverBottomView = [[UIView alloc] init];
        
        UIImageView *bgImageView = [[UIImageView alloc] init];
        bgImageView.image = [UIImage imageNamed:@"ic_bind_bottom"];
        [_coverBottomView addSubview:bgImageView];
        
        UILabel *hintLabel = [[UILabel alloc] init];
        hintLabel.text = @"如无法扫描绑定，请点此";
        hintLabel.font = [UIFont systemFontOfSize:12];
        hintLabel.textColor = RGBColor(158, 158, 158, 1);
        [_coverBottomView addSubview:hintLabel];
        
        UIButton *manuallyBindBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [manuallyBindBtn setTitle:@"手动绑定" forState:UIControlStateNormal];
        [manuallyBindBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [manuallyBindBtn setBackgroundImage:[[UIImage imageNamed:@"ic_bind_btn_up"]
                                             resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)
                                             resizingMode:UIImageResizingModeStretch]
                                   forState:UIControlStateNormal];
        [manuallyBindBtn setBackgroundImage:[[UIImage imageNamed:@"ic_bind_btn_down"]
                                             resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)
                                             resizingMode:UIImageResizingModeStretch]
                                   forState:UIControlStateHighlighted];
        [manuallyBindBtn addTarget:self action:@selector(manuallyAddNewDevice) forControlEvents:UIControlEventTouchUpInside];
        [_coverBottomView addSubview:manuallyBindBtn];
        
        [bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_coverBottomView);
        }];
        [manuallyBindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(10);
            make.trailing.equalTo(@-15);
        }];
        [hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(manuallyBindBtn);
            make.trailing.equalTo(manuallyBindBtn.mas_leading).with.offset(@-10);
        }];
    }
    return _coverBottomView;
}

- (UILabel *)hintLabel {
    if (!_hintLabel) {
        _hintLabel = [[UILabel alloc] init];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
        _hintLabel.text = @"请将摄像头对准说明书或者设备上的二维码，即可自动扫描";
        _hintLabel.font = [UIFont systemFontOfSize:12];
        _hintLabel.textColor = [UIColor whiteColor];
    }
    return _hintLabel;
}

- (UIView *)toolView{
    if (!_toolView) {
        _toolView = [[UIView alloc]init];
        
        _openLight = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openLight setImage:[UIImage imageNamed:@"light-close"] forState:UIControlStateNormal];
        [_openLight addTarget:self action:@selector(openLightAction) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:_openLight];
        
        UIButton *addFromLibrary = [UIButton buttonWithType:UIButtonTypeCustom];
        [addFromLibrary setImage:[UIImage imageNamed:@"library"] forState:UIControlStateNormal];
         [addFromLibrary addTarget:self action:@selector(addFromLibraryAction) forControlEvents:UIControlEventTouchUpInside];
        [_toolView addSubview:addFromLibrary];
        
        _openLightLabel = [[UILabel alloc]init];
        _openLightLabel.text = @"打开手电筒";
        _openLightLabel.textAlignment = NSTextAlignmentCenter;
        _openLightLabel.textColor = [UIColor whiteColor];
        [_toolView addSubview:_openLightLabel];
        
        UILabel *addFromLibraryLabel = [[UILabel alloc]init];
        addFromLibraryLabel.text = @"从相册添加";
        addFromLibraryLabel.textAlignment = NSTextAlignmentCenter;
        addFromLibraryLabel.textColor = [UIColor whiteColor];
        [_toolView addSubview:addFromLibraryLabel];
        
        if (ISIPHONE_4) {
            _openLightLabel.font = [UIFont systemFontOfSize:15];
            addFromLibraryLabel.font = [UIFont systemFontOfSize:15];
            [_openLight mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(80);
                make.bottom.equalTo(_openLightLabel.mas_top).offset(-8);
                make.width.equalTo(self.toolView.mas_width).multipliedBy(0.1);
                make.height.equalTo(self.openLight.mas_width);
            }];
        }else{
            [_openLight mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(80);
                make.bottom.equalTo(_openLightLabel.mas_top).offset(-8);
                make.width.equalTo(self.toolView.mas_width).multipliedBy(0.12);
                make.height.equalTo(self.openLight.mas_width);
            }];
        }
       
        
        [addFromLibrary mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_openLight);
            make.right.equalTo(-80);
            make.width.height.equalTo(_openLight);
        }];
        
        [_openLightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_toolView.mas_bottom);
            make.centerX.equalTo(_openLight);
        }];
        
        [addFromLibraryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_openLightLabel);
            make.centerX.equalTo(addFromLibrary);
        }];
    }
    return _toolView;
}

- (void)openLightAction{
    // 打开或关闭闪光灯
    [self turnTorchOn:!_isTurnOnFlash];
    
    if ( _isTurnOnFlash) {
         _openLightLabel.text = @"关闭手电筒";
        [_openLight setImage:[[UIImage imageNamed:@"light-close"] imageWithTintColor:[UIColor colorWithRed:253.0/255.0 green:173.0/255.0 blue:10.0/255.0 alpha:1.00]] forState:UIControlStateNormal];
    }else{
         _openLightLabel.text = @"打开手电筒";
        [_openLight setImage:[UIImage imageNamed:@"light-close"] forState:UIControlStateNormal];

    }
}
- (void)addFromLibraryAction{
    // 从相册添加图片 -> 扫描
    [self qr_selectLocalAlbumPicturetoGetQRCode];
}
#pragma mark - Life Cycle
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    if (!self.hasAppear) {
        self.hasAppear = YES;
        [self startScanning];
        if ([self.waitScanView superview]) {
            [self.waitScanView removeFromSuperview];
        }
        self.moreBtn.hidden = NO;
    }else {
        if (!_isProcessing) {
            [self startScanning];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_isTurnOnFlash) {
        [self openLightAction];
    }
    [self stopScanning];
    
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
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

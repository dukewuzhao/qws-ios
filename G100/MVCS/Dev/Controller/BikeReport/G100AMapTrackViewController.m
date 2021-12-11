//
//  G100AMapTrackViewController.m
//  G100
//
//  Created by 温世波 on 15/11/25.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100AMapTrackViewController.h"
#import "G100BikeApi.h"
#import "G100DevApi.h"

#import "MAGeoCodeResult.h"
#import "G100TopHintView.h"
#import "EBOfflineMapService.h"
#import "G100AMapOfflineMapViewController.h"
#import "G100DoubleLabelView.h"
#import "G100TrackFuncView.h"
#import "G100TrackInfoView.h"
#import "G100TrackSpeedView.h"
#import "G100MapChangeView.h"

#import "G100BikeHisTrackDomain.h"
#import "G100BikeDomain.h"

#import "G100FuncSetOverSpeedViewController.h"

@interface G100AMapTrackViewController () <EBOfflineMapServiceDelegate, UIAlertViewDelegate, G100TopViewClickActionDelegate,G100TrackFuncViewDelegate>

@property (assign, nonatomic) CLLocationCoordinate2D currentCoordinate;
@property (assign, nonatomic) CLLocationCoordinate2D * commonPolylineCoords;
@property (assign, nonatomic) CLLocationCoordinate2D * animationPolylineCoords;
@property (assign, nonatomic) CLLocationCoordinate2D * manualPolylineCoords;

@property (strong, nonatomic) UILabel * timeLabel;
@property (strong, nonatomic) NSMutableArray <G100BikeHisTrackDomain *>* trackArray;
@property (strong, nonatomic) NSMutableArray <G100BikeHisTrackDomain *>* newtrackArray;
@property (assign, nonatomic) NSInteger trackCount;
@property (nonatomic, strong) G100BikeDomain *bikeDomain;

@property (strong, nonatomic) MAAnimatedAnnotation * currentAnnotation;
@property (strong, nonatomic) MAAnimatedAnnotation * startAnnotation;
@property (strong, nonatomic) MAAnimatedAnnotation * endAnnotation;

@property (strong, nonatomic) NSMutableArray * annotationsArray;
@property (strong, nonatomic) NSMutableArray * fitAnnotationsArray;

@property (assign, nonatomic) BOOL isPlay;
@property (assign, nonatomic) NSInteger startPlace;
@property (nonatomic, assign) NSInteger lastPlace;
@property (assign, nonatomic) NSUInteger playSpeed;
@property (weak, nonatomic) NSTimer * timer;

@property (assign, nonatomic) BOOL isChangePopView; // 控制是否改变popView的隐藏显示状态
@property (assign, nonatomic) BOOL isDataReady;     // 数据准备好
@property (assign, nonatomic) BOOL currentPlayStatus;   // 记录当前播放状态 1 播放    0 暂停

@property (strong, nonatomic) EBOfflineMapService *ebservice;
@property (nonatomic, copy) NSString *adcode;
@property (strong, nonatomic) G100TopHintView *hintView;
@property (nonatomic, strong) NSMutableArray *speedArr;
@property (nonatomic, strong) NSMutableArray *colorArr;
@property (nonatomic, strong) G100DoubleLabelView *dTitleLabelView;

@property (nonatomic, strong) NSString *startAddress;
@property (nonatomic, strong) NSString *endAddress;
@property (strong, nonatomic) UIButton * mapChangeBtn;
@property (nonatomic, strong) G100TrackFuncView *trackFuncView;
@property (nonatomic, strong) G100TrackInfoView *trackInfoView;
@property (nonatomic, strong) G100TrackSpeedView *trackSpeedView;
@property (strong, nonatomic) G100MapChangeView * mapChangeView;
@property (nonatomic, assign) BOOL hasChangeMapType;
@property (nonatomic, strong) NSMutableArray *allMoveAnimationsArr;

@property (nonatomic, assign) CGFloat timerInterval;
@property (nonatomic, strong) NSMutableArray *manulArr;
@property (nonatomic, assign) BOOL hasAddAnimation;
@end

static NSInteger  animationIndex = 0;
@implementation G100AMapTrackViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGNRemoteLoginMsg object:nil];
    
    _ebservice.delegate = nil;
    
    DLog(@"历史轨迹已释放");
}
- (NSMutableArray *)manulArr{
    if (!_manulArr) {
        _manulArr = [NSMutableArray array];
    }
    return _manulArr;
}
- (G100DoubleLabelView *)dTitleLabelView {
    if (!_dTitleLabelView) {
        _dTitleLabelView = [[G100DoubleLabelView alloc] init];
        _dTitleLabelView.normalMainText = YES;
        _dTitleLabelView.mainFontSize = 14;
        _dTitleLabelView.viceFontSize = 14;
        _dTitleLabelView.mainText = nil;
        _dTitleLabelView.viceText = nil;
        _dTitleLabelView.leftTextAlignment = YES;
    }
    return _dTitleLabelView;
}
- (EBOfflineMapService *)ebservice {
    if (!_ebservice) {
        _ebservice = [[EBOfflineMapService alloc] init];
        _ebservice.delegate = self;
    }
    return _ebservice;
}

-(G100TopHintView *)hintView{
    if (!_hintView) {
        _hintView = [[G100TopHintView alloc] init];
        _hintView.hintText = @"当前历史轨迹所在城市地图未下载，点击下载";
        _hintView.delegate = self;
    }
    return _hintView;
}
- (NSMutableArray *)speedArr{
    if (!_speedArr) {
        _speedArr = [NSMutableArray array];
    }
    return _speedArr;
}
- (NSMutableArray *)colorArr{
    if (!_colorArr) {
        _colorArr = [NSMutableArray array];
    }
    return _colorArr;
}

- (G100TrackFuncView *)trackFuncView{
    if (!_trackFuncView) {
        _trackFuncView = [G100TrackFuncView loadXibView];
        _trackFuncView.delegate = self;
    }
    return _trackFuncView;
}
- (G100TrackInfoView *)trackInfoView{
    if (!_trackInfoView) {
        _trackInfoView = [G100TrackInfoView loadXibView];
    }
    return _trackInfoView;
}
- (G100TrackSpeedView *)trackSpeedView{
    if (!_trackSpeedView) {
        _trackSpeedView = [[G100TrackSpeedView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 140)];
        
        _trackSpeedView.maxSpeed = self.bikeDomain.max_speed;
    }
    return _trackSpeedView;
}
- (G100MapChangeView *)mapChangeView {
    if (!_mapChangeView) {
        _mapChangeView = [[G100MapChangeView alloc] initWithMapView:self.mapView
                                                           position:CGPointMake(self.mapChangeBtn.v_right, self.mapChangeBtn.v_bottom-8)];
        [self.view addSubview:_mapChangeView];
        
        __weak typeof(self) wself = self;;
        _mapChangeView.viewHideCompletion = ^(){
            wself.mapChangeBtn.selected = NO;
        };
    }
    return _mapChangeView;
}
- (void)configData {
    self.annotationsArray  = [[NSMutableArray alloc] init];
    self.fitAnnotationsArray = [[NSMutableArray alloc] init];
    self.currentAnnotation = [[MAAnimatedAnnotation alloc] init];
    self.startAnnotation   = [[MAAnimatedAnnotation alloc] init];
    self.endAnnotation     = [[MAAnimatedAnnotation alloc] init];
    
    self.startPlace        = 0;
    self.playSpeed         = 1;

    self.isChangePopView   = YES;
    self.isDataReady       = NO;
    self.currentPlayStatus = YES;

    self.trackArray        = [[NSMutableArray alloc] init];
}

#pragma mark - G100TrackFuncViewDelegate
- (void)btnClickedWithTag:(NSInteger)tag{
    switch (tag) {
        case 1:
            [self setIsPlay:!self.isPlay];
            break;
        case 3:
            self.trackFuncView.mapTypeBtn.selected =  !self.trackFuncView.mapTypeBtn.selected ;
            if (!_hasChangeMapType) {
                [self.mapView setMapType:MAMapTypeStandard];
                [self.mapView setZoomLevel:19.0f animated:YES];
                [self.mapView setCameraDegree:50.0f animated:YES duration:.6f];
                [self.mapView setCenterCoordinate:self.currentAnnotation.coordinate animated:YES];
                _hasChangeMapType = YES;
            }else{
                if (self.mapView.cameraDegree > 0) {
                    [self.mapView setCameraDegree:0 animated:YES duration:.6f];
                }
                [self.mapView setMapType:MAMapTypeStandard];
                _hasChangeMapType = NO;
                 [self zoomMapViewToFitAnnotations];
            }
            
            break;
        case 4:
            self.trackFuncView.cureTypeBtn.selected = !self.trackFuncView.cureTypeBtn.selected;
            self.trackInfoView.hidden = !self.trackInfoView.hidden;
            self.trackSpeedView.hidden = !self.trackSpeedView.hidden;
            
            break;
        default:
            break;
    }
}
    
- (void)speedBtnClicked:(int)speed {
    [self destoryTimer];
    [self setIsPlay:NO];
    
    switch (speed) {
        case 1:
            self.timerInterval = 1.0f;
            break;
        case 2:
            self.timerInterval = 0.8f;
            break;
        case 4:
            self.timerInterval = 0.6f;
            break;
        case 8:
            self.timerInterval = 0.4f;
            break;
        case 16:
            self.timerInterval = 0.2f;
            break;
        default:
            break;
    }
    
    [self createTimer];
}
    
- (void)setIsPlay:(BOOL)isPlay {
    _isPlay = isPlay;
    
    if (isPlay) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];   // 设置播放时屏幕常亮
        // 开始轨迹回放
        if (_startPlace == 0) {
            /**
             *  1.3.8 修复 Application received signal SIGSEGV
             */
            if (self.commonPolylineCoords) {
                self.currentAnnotation.coordinate = self.commonPolylineCoords[0];
            }
        }
        
        self.trackFuncView.startBtn.selected = YES;
        [self.timer setFireDate:[NSDate distantPast]];
    }else {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];   // 设置播放时屏幕常亮
        self.trackFuncView.startBtn.selected = NO;
        [self.timer setFireDate:[NSDate distantFuture]];
        
        for(MAAnnotationMoveAnimation *animation in [self.currentAnnotation allMoveAnimations]) {
            [animation cancel];
        }
    }
}

#pragma mark - 获取行驶轨迹
- (void)getHistoryTrack:(NSString *)devid beginTime:(NSString *)beginTime endTime:(NSString *)endTime {
    if (kNetworkNotReachability) {
        [self showHint:kError_Network_NotReachable];
        return;
    }
    
    __weak G100AMapTrackViewController * wself = self;
    API_CALLBACK callback = ^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess){
        wself.trackFuncView.startBtn.enabled = NO;
        [wself hideHud];
        
        if (requestSuccess) {
            if (!NOT_NULL(response.data)) {
                [wself showHint:@"无数据"];
                return;
            }
            
            wself.trackFuncView.startBtn.enabled = YES;
            
            BOOL topSpeedOpen = wself.bikeDomain.max_speed_on;
            wself.trackInfoView.overSpeedOpen = topSpeedOpen;
            
            G100BikeHisTracksDomain *tracks = [[G100BikeHisTracksDomain alloc] initWithDictionary:response.data];
            
            wself.trackSpeedView.hisTracksDomain = tracks;
            wself.trackInfoView.summaryDomain = tracks.summary;
            wself.trackInfoView.maxSpeed = wself.bikeDomain.max_speed;
            wself.startAddress = [NSString stringWithFormat:@"起点:%@",tracks.summary.addr_b];
            wself.endAddress = [NSString stringWithFormat:@"终点:%@",tracks.summary.addr_e];
            [wself initData];
            
            NSArray *locArr = tracks.loc;
            wself.trackCount = [locArr count];
            wself.trackArray = locArr.mutableCopy;
            
            [wself.annotationsArray removeAllObjects];
            [wself.fitAnnotationsArray removeAllObjects];
            [wself.speedArr removeAllObjects];
            [wself.colorArr removeAllObjects];
            
            //地图线段 超速距离 和 颜色数组
            if (wself.bikeDomain.max_speed == 0) { //没有设置超速
                [self.colorArr addObject: [UIColor colorWithHexString:@"#1fbda8"]];
            }else{
                int indexs = 0;
                BOOL isNormal = YES;
                for (G100BikeHisTrackDomain *domain in locArr){
                    if (indexs == 0){
                        if (domain.speed > wself.bikeDomain.max_speed) {
                            isNormal = NO;
                        }else{
                            isNormal = YES;
                        }
                    }else{
                        if (isNormal) {
                            if (domain.speed > wself.bikeDomain.max_speed) {
                                [self.speedArr addObject:@(indexs-1)];
                                [self.colorArr addObject:[UIColor colorWithHexString:@"#1fbda8"]];
                                isNormal = NO;
                            }
                        }else{
                            if (domain.speed < wself.bikeDomain.max_speed) {
                                [self.speedArr addObject:@(indexs-1)];
                                [self.colorArr addObject:[UIColor colorWithHexString:@"#ffa300"]];
                                isNormal = YES;
                            }
                        }
                    }
                    indexs ++;
                }
                
                //全部同一个颜色情况 只有一个点
                if ((self.speedArr.count == 1 && [[self.speedArr safe_objectAtIndex:0] integerValue] == 0)) {
                    [self.colorArr removeAllObjects];
                }
                if (isNormal) {
                    [self.colorArr addObject:[UIColor colorWithHexString:@"#1fbda8"]];
                }else{
                    [self.colorArr addObject:[UIColor colorWithHexString:@"#ffa300"]];
                }
            }
            
            
            wself.commonPolylineCoords = (CLLocationCoordinate2D *)malloc((wself.trackCount + 1) * sizeof(CLLocationCoordinate2D));
            
            for (NSInteger i = 0; i < [locArr count]; i++) {
                G100BikeHisTrackDomain * hisTrack = [locArr safe_objectAtIndex:i];
                // 本地GPS转换
                CLLocationCoordinate2D test = CLLocationCoordinate2DMake(hisTrack.lati, hisTrack.longi);
                CLLocationCoordinate2D result = [self transformGPS2Gaode:test];
                wself.commonPolylineCoords[i] = result;
                
                if (i == 0) {
                    wself.timeLabel.text = [hisTrack.ts substringToIndex:19];
                    wself.startAnnotation.coordinate = CLLocationCoordinate2DMake(result.latitude, result.longitude);
                    [wself onClickReverseAMMapGeocode: wself.startAnnotation.coordinate];
                    [wself.annotationsArray addObject:wself.startAnnotation];
                    [wself.fitAnnotationsArray addObject:wself.startAnnotation];
                }else if (i == [locArr count] - 1) {
                    wself.endAnnotation.coordinate = CLLocationCoordinate2DMake(result.latitude, result.longitude);
                    [wself onClickReverseAMMapGeocode: wself.endAnnotation.coordinate];
                    [wself.annotationsArray addObject:wself.endAnnotation];
                    [wself.fitAnnotationsArray addObject:wself.endAnnotation];
                }else {
                    MAPointAnnotation *annotation = [[MAPointAnnotation alloc]init];
                    annotation.coordinate = CLLocationCoordinate2DMake(result.latitude, result.longitude);
                    
                    [wself.fitAnnotationsArray addObject:annotation];
                }
                
                // 数据 全部下载下来之后  开始划线
                if (i == [locArr count] - 1) {
                    wself.currentAnnotation.coordinate = wself.startAnnotation.coordinate;
                    [wself.annotationsArray addObject:wself.currentAnnotation];
                    
                    [wself makePolyline];
                }
            }
            
            // 获取轨迹所在城市
            [wself onClickReverseAMMapGeocode:wself.startAnnotation.coordinate];
        }else {
            if (response) {
                [wself showHint:response.errDesc];
            }
        }
    };
    
    wself.commonPolylineCoords = nil;
    [self showHudInView:self.view hint:@"正在查询"];
    [[G100BikeApi sharedInstance] loadDevHistoryTrackWithBikeid:self.bikeid devid:self.devid begintime:beginTime endtime:endTime callback:callback];
}

//画线
- (void)makePolyline{
    [self clearAnnotationAndOverlays];
    [self.mapView addAnnotations:self.annotationsArray];
    
    [self zoomMapViewToFitAnnotations];
    
    //如果没有超速 speedarr默认从头到尾同一个颜色
    if (self.speedArr.count == 0) {
        [self.speedArr addObject:@0];
        [self.speedArr addObject:@(self.trackCount)];
    }
    
    MAMultiPolyline *multiPolyLine = [MAMultiPolyline polylineWithCoordinates:self.commonPolylineCoords count:self.trackCount drawStyleIndexes:self.speedArr];
    [self.mapView addOverlay:multiPolyLine];
    
    _isDataReady = YES;
    
    [self createTimer];
}

- (void)zoomMapViewToFitAnnotations {
    NSInteger count = [self.fitAnnotationsArray count];
    if ( count == 0) { return; } //bail if no annotations
    
    MAMapPoint points[count]; //C array of MKMapPoint struct
    for( int i = 0; i < count; i++ ) //load points C array by converting coordinates to points
    {
        CLLocationCoordinate2D coordinate = [(id <MAAnnotation>)[self.fitAnnotationsArray safe_objectAtIndex:i] coordinate];
        points[i] = MAMapPointForCoordinate(coordinate);
    }
    //create MKMapRect from array of MKMapPoint
    MAMapRect mapRect = [[MAPolygon polygonWithPoints:points count:count] boundingMapRect];
    [self.mapView setVisibleMapRect:mapRect edgePadding:UIEdgeInsetsMake(100, 100, 100, 100) animated:YES];
}

#pragma mark - 自定义标注
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    static NSString *trackingReuseIndetifier = @"annotationReuseIndetifier";
    MAAnnotationView *annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:trackingReuseIndetifier];
    
    annotationView.canShowCallout = NO;
    if (annotation == self.startAnnotation) {
        annotationView.v_size = CGSizeMake(10, 10);
        annotationView.zIndex = 1;
        annotationView.image = [UIImage imageNamed:@"start"];
    }else if (annotation == self.endAnnotation) {
        annotationView.v_size = CGSizeMake(10, 10);
        annotationView.zIndex = 2;
        annotationView.image = [UIImage imageNamed:@"end"];
    }else if (annotation == self.currentAnnotation) {
        //设置中⼼心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -0);
        annotationView.zIndex = 999;
        annotationView.image = [UIImage imageNamed:@"ic_history_car"];
    }else if ([annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        // 自定义定位样式的图片
        annotationView.image = [[UIImage alloc] init];
    }else {
        annotationView.backgroundColor = [UIColor clearColor];
        annotationView.image = [[UIImage alloc]init];
    }
    
    return annotationView;
}

- (void)clearAnnotationAndOverlays {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    if ([overlay isKindOfClass:[MAMultiPolyline class]])
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:(MAMultiPolyline *)overlay];
        
        polylineRenderer.lineWidth = 4.0f;
        polylineRenderer.strokeColors = self.colorArr;
        polylineRenderer.gradient = NO;
        
        return polylineRenderer;
    }
    return nil;
}

- (void)mapViewDidFinishLoadingMap:(MAMapView *)mapView {
    // 解决在暂停播放的情况下 缩放地图导致地图位置重置的问题
    //[self zoomMapViewToFitAnnotations:self.mapView animated:YES];
}

#pragma mark - 高德逆地址编码
- (void)onClickReverseAMMapGeocode:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest * request = [[AMapReGeocodeSearchRequest alloc]init];
    request.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    request.requireExtension = YES;
    
    if (self.search == nil) {
        self.search = [[AMapSearchAPI alloc]init];
    }
    
    self.search.delegate = self;
    [self.search AMapReGoecodeSearch:request];
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    MAGeoCodeResult *geo = [MAGeoCodeResult instance];
    
    if (response) {
//        if (request.location.latitude == self.startAnnotation.coordinate.latitude &&request.location.longitude == self.startAnnotation.coordinate.longitude) {
//            self.startAddress =  [NSString stringWithFormat:@"起点:%@%@%@",response.regeocode.addressComponent.township,response.regeocode.addressComponent.streetNumber.street,response.regeocode.addressComponent.streetNumber.number];
//            [self initData];
//        }else if (request.location.latitude == self.endAnnotation.coordinate.latitude
//                  &&request.location.longitude == self.endAnnotation.coordinate.longitude){
//            self.endAddress = [NSString stringWithFormat:@"终点:%@%@%@",response.regeocode.addressComponent.township,response.regeocode.addressComponent.streetNumber.street,response.regeocode.addressComponent.streetNumber.number];
//            [self initData];
//        }
        
        geo.result = response;
        NSString * adcode = response.regeocode.addressComponent.adcode;
        
        self.adcode = adcode;
        
//        if (![EBOfflineMapTool sharedManager].hasShowedNotice) {
//            
//            
//            if ([[EBOfflineMapTool sharedManager] needRemainderUserWithAdcode:adcode]) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"地图下载"
//                                                                    message:@"检测到当前历史轨迹所在城市地图未下载，是否需要前往下载？"
//                                                                   delegate:self
//                                                          cancelButtonTitle:nil
//                                                          otherButtonTitles:@"取消", @"立即下载", @"连接WiFi时自动下载", nil];
//                alertView.tag = 2001;
//                [alertView show];
//                NSUserDefaults *p = [NSUserDefaults standardUserDefaults];
//                [p setBool:YES forKey:EBOfflineMapToolHasShowNoticeKey];
//                [p synchronize];
//            } else {
//                [self setIsPlay:YES];
//            }
//        }else{
//            if ([[EBOfflineMapTool sharedManager] needRemainderUserWithAdcode:adcode]) {
//                [self updateTopHintUI];
//            }else{
//                [self removeHintViewUI];
//            }
//        }
    }
}

#pragma mark - UIAlertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2001) {
        if (buttonIndex == 1) {
            [[EBOfflineMapTool sharedManager] downloadOfflineMapWithAdcode:self.adcode downloadType:EBOfflineItemDownloadTypeWWAN];
            [self setIsPlay:NO];
        }else if (buttonIndex == 2){
            [[EBOfflineMapTool sharedManager] downloadOfflineMapWithAdcode:self.adcode downloadType:EBOfflineItemDownloadTypeWIFI];
            [self setIsPlay:YES];
        }else{
            [self setIsPlay:YES];
        }
    }
}

- (void)updateTopHintUI{
    if (![self.hintView superview]) {
        [self.view addSubview:self.hintView];
        CGFloat topViewHeight =  [self.hintView getHeightOfTopHintView];
        [self.hintView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(@0);
            make.top.equalTo(self.navigationBarView.mas_bottom);
            make.trailing.equalTo(0);
            make.height.equalTo(topViewHeight);
        }];
        [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.navigationBarView.mas_bottom).offset(topViewHeight +4);
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.height.equalTo(@24);
        }];
    }
}

- (void)removeHintViewUI{
    if ([self.hintView superview]) {
        [self.hintView removeFromSuperview];
        self.hintView = nil;
        [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.navigationBarView.mas_bottom);
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.height.equalTo(@24);
        }];
    }
}
#pragma mark - G100TopViewClickActionDelegate

-(void)topViewClicked{
    G100AMapOfflineMapViewController *viewController = [[G100AMapOfflineMapViewController alloc]init];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - EBOfflineMapServiceDelegate
- (void)mapTool:(EBOfflineMapTool *)tool didFinishedItem:(MAOfflineItem *)downloadItem {
    [self.mapView reloadMap];
    [self removeHintViewUI];
}

#pragma mark - 轨迹回放
- (void)locationInCoordinate:(CLLocationCoordinate2D)coordinate {
    CGPoint point = [self.mapView convertCoordinate:coordinate toPointToView:self.mapView];
    
    if (point.x < 20 || (point.x > self.mapView.frame.size.width - 30 && point.x < 1000)
        || point.y < 100 || (point.y > self.mapView.frame.size.height - 120 && point.y < 2000))
    {
        if (coordinate.latitude != 0 && coordinate.longitude!= 0 ) {
            [self.mapView setCenterCoordinate:coordinate animated:YES];
        }
    }
}

- (void)drawHistoryTrack:(BOOL)isManual {
    if (!isManual) {
        CLLocationCoordinate2D startPolylineCoords = self.commonPolylineCoords[_startPlace];
        CLLocationCoordinate2D endPolylineCoords = self.commonPolylineCoords[_startPlace + 1];
        self.animationPolylineCoords = (CLLocationCoordinate2D *)malloc((2) * sizeof(CLLocationCoordinate2D));
        self.animationPolylineCoords[0] = startPolylineCoords;
        self.animationPolylineCoords[1] = endPolylineCoords;
        
        [self.currentAnnotation addMoveAnimationWithKeyCoordinates:self.animationPolylineCoords count:2 withDuration:self.timerInterval withName:nil completeCallback:^(BOOL isFinished) {
            
        }];
    }
    else {
        //手动拖拽时跳点
        if ([self.mapView.annotations containsObject:_currentAnnotation]) {
            [self.mapView removeAnnotation:_currentAnnotation];
        }
        
        //
        self.currentCoordinate = self.commonPolylineCoords[_startPlace];
        self.currentAnnotation.coordinate = self.currentCoordinate;
        G100BikeHisTrackDomain *hisTrackDomain =  [self.trackArray safe_objectAtIndex:_startPlace];
        self.currentAnnotation.movingDirection = hisTrackDomain.heading;
        // 添加新的
        [self.mapView addAnnotation:self.currentAnnotation];
    }
    
    [self locationInCoordinate:self.currentAnnotation.coordinate];
    [self.trackSpeedView moveLineWithPoint:CGPointMake(((WIDTH -40)  * 1.00000/(self.trackArray.count - 1)) * _startPlace + 20, 20)];
    
    // 判断当前位置
    if (_startPlace == ([self.trackArray count] - 1)) {
        // 播放完毕 停止播放
        _startPlace = 0;
        [self setIsPlay:NO];
    }else if (_startPlace + _playSpeed > [self.trackArray count] - 1) {
        _startPlace = [self.trackArray count] - 1;
    }else if (_startPlace + _playSpeed < [self.trackArray count] - 1){
        _startPlace += _playSpeed;
    }else if (_startPlace + _playSpeed == [self.trackArray count] - 1) {
        _startPlace += _playSpeed;
    }
}

#pragma mark - 创建定时器
- (void)createTimer {
    if (![UserManager shareManager].remoteLogin) {
        if (!_timer) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timerInterval target:self selector:@selector(timerChange) userInfo:nil repeats:YES];
            [_timer setFireDate:[NSDate distantFuture]];
        }
        
        // 如果有轨迹    开始播放
        if (_isDataReady /*&& _currentPlayStatus*/) {
            [self setIsPlay:YES];
        }   // 数据准备好且当前为播放状态
    }
}

- (void)destoryTimer {
    if ([_timer isValid]) {
        [_timer setFireDate:[NSDate distantFuture]];
        
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)timerChange{
    [self drawHistoryTrack:NO];
}

#pragma mark - Private method
- (BOOL)currentPlayStatus {
    return _isPlay;
}

- (void)enterBackground {
    _currentPlayStatus = _isPlay;   // 记录当前播放状态
    
    if (_isPlay) {
        [self setIsPlay:NO];
    }
}

- (void)activeForeground {
    if (_currentPlayStatus) {
        [self setIsPlay:YES];
    }
}

- (void)remoteLoginHandle {
    // 异地登录处理
    _currentPlayStatus = _isPlay;   // 记录当前状态
    if (_isPlay) {
        [self setIsPlay:NO];
    }
    
    [self destoryTimer];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];   // 设置播放时屏幕常亮
}
#pragma mark - 退出页面
- (void)backBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 地图模式切换
- (void)mapModeChangeAction:(UIButton *)button {
    button.selected = !button.selected;
    if (button.selected) {
        [self.mapChangeView show];
    }else{
        [self.mapChangeView hide];
    }
}

- (void)initData {
    self.dTitleLabelView.mainText = self.startAddress;
    self.dTitleLabelView.viceText = self.endAddress;
}

- (void)setUpView {
    [self.navigationBarView setBackgroundColor:[UIColor clearColor]];
    [self.navigationBarView setHidden:YES];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(kNavigationBarHeight-44);
        make.leading.trailing.bottom.equalTo(@0);
    }];
    
    // 返回按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"ic_gps_back"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:CreateImageWithColor([UIColor colorWithHexString:@"000000" alpha:0.7f]) forState:UIControlStateNormal];
    
    backBtn.layer.masksToBounds = YES;
    backBtn.layer.cornerRadius = 6.0f;
    
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.top.equalTo(@42);
        make.size.equalTo(CGSizeMake(40, 48));
    }];
    
    //地图模式切换
    self.mapChangeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.mapChangeBtn setImage:[UIImage imageNamed:@"ic_map_open"] forState:UIControlStateNormal];
    [self.mapChangeBtn setBackgroundImage:CreateImageWithColor([UIColor colorWithHexString:@"000000" alpha:0.7f]) forState:UIControlStateNormal];
    [self.mapChangeBtn addTarget:self action:@selector(mapModeChangeAction:) forControlEvents:UIControlEventTouchUpInside];
    self.mapChangeBtn.layer.masksToBounds = YES;
    self.mapChangeBtn.layer.cornerRadius = 6.0f;
    [self.mapChangeBtn setExclusiveTouch:YES];
    [self.view addSubview:self.mapChangeBtn];
    
    [self.mapChangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(@-20);
        make.top.equalTo(@42);
        make.size.equalTo(CGSizeMake(40, 48));
    }];
    
    // 标题栏视图
    [self.view addSubview:self.dTitleLabelView];
    [self.dTitleLabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(backBtn.mas_trailing).with.offset(@20);
        make.height.and.centerY.equalTo(backBtn);
        make.trailing.equalTo(self.mapChangeBtn.mas_leading).offset(-20);
    }];
    
    [self.view addSubview:self.trackFuncView];
    [self.view addSubview:self.trackSpeedView];
    [self.view addSubview:self.trackInfoView];
    [self.trackFuncView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(@20);
        make.trailing.equalTo(@-20);
        make.height.equalTo(@48);
        make.bottom.equalTo(self.trackSpeedView.mas_top).with.offset(-8);
    }];
    
    [self.trackSpeedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(@0);
        make.bottom.equalTo(0);
        make.height.equalTo(140+kBottomPadding);
    }];
    self.trackSpeedView.maxSpeed = _bikeDomain.max_speed;
    self.trackSpeedView.hidden = YES;
    
    [self.trackInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(@0);
        make.bottom.equalTo(0);
        make.height.equalTo(140+kBottomPadding);
    }];
    __weak typeof(self) wself = self;
    self.trackInfoView.maxSpeedBtnClicked = ^(){
        G100FuncSetOverSpeedViewController *funcSetOverSpeedVC = [[G100FuncSetOverSpeedViewController alloc]init];
        funcSetOverSpeedVC.userid = wself.userid;
        funcSetOverSpeedVC.bikeid = wself.bikeid;
        funcSetOverSpeedVC.devid = wself.devid;
        [wself.navigationController pushViewController:funcSetOverSpeedVC animated:YES];
    };
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(@0);
        make.bottom.equalTo(self.trackSpeedView.mas_top).offset(@0);
    }];
}
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 添加进入后台的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteLoginHandle) name:kGNRemoteLoginMsg object:nil];
    
    [self setNavigationTitle:@"历史轨迹"];
    
    _bikeDomain = [[G100InfoHelper shareInstance]findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    
    [self setUpView];
    // 隐藏罗盘
    [self.mapView setShowsCompass:YES];
    [self.mapView setCompassOrigin:CGPointMake(20, 100)];
    
    [self configData];
    [self ebservice];
    
    __weak G100AMapTrackViewController * weakSelf = self;
    self.trackSpeedView.lineChart.valueChanged = ^(NSInteger index){
        // 先暂停定时器
        weakSelf.isPlay = NO;
        weakSelf.startPlace = index;
        NSLog(@"%ld", index);
        [weakSelf drawHistoryTrack:YES];
        
    };
    
    self.trackSpeedView.lineChart.draggingComplete = ^(){
        [weakSelf setIsPlay:YES];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.bikeDomain = [[G100InfoHelper shareInstance] findMyBikeWithUserid:self.userid bikeid:self.bikeid];
    
    if (_begintime.length && _endtime.length) {
        [self getHistoryTrack:_devid beginTime:self.begintime endTime:self.endtime];
    } else {
        DLog(@"获取行驶轨迹参数缺失");
    }
    
    [self startLocationService];
    self.timerInterval = 1.0f;

    animationIndex =  0;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    animationIndex =  0;
    _currentPlayStatus = _isPlay;
    
    if (_isPlay) {
        [self setIsPlay:NO];
    }
    
    [self destoryTimer];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

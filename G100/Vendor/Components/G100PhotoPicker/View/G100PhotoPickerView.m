//
//  G100PhotoPickerView.m
//  PhotoPicker
//
//  Created by William on 16/3/22.
//  Copyright © 2016年 William. All rights reserved.
//

#import "G100PhotoPickerView.h"
#import "G100PhotoPickerCell.h"
#import "G100PhotoShowCell.h"
#import "G100PhotoShowModel.h"
#import "DNImagePickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "DNAsset.h"
#import <ImageIO/ImageIO.h>
#import "PhotoAlbumManager.h"
#import "G100PhotoBrowserViewController.h"

#define kMaxPhotoNumber 5

@interface G100PhotoPickerView () <UICollectionViewDataSource, UICollectionViewDelegate, PhotoPickerCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DNImagePickerControllerDelegate, PhotoBrowserDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@end

@implementation G100PhotoPickerView

#pragma mark  ===== 懒加载 =====

- (NSArray *)imageAsset {
    if (_imageAsset == nil) {
        _imageAsset = [[NSArray alloc]init];
    }
    return _imageAsset;
}

-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (ALAssetsLibrary *)assetsLibrary{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (id)initWithPoint:(CGPoint)point {
    if (self) {
        self = [super init];
        self.backgroundColor = [UIColor clearColor];
        self.maxSeletedNumber = kMaxPhotoNumber;
        self.frame = CGRectMake(point.x, point.y, WIDTH-point.x*2, (WIDTH-point.x*2-12*3)/4);
        [self collectionView];
    }
    return self;
}

- (void)setPickerData:(NSArray*)array {
    [self.dataArray addObjectsFromArray:array];
    [self.collectionView reloadData];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 12;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.v_width, self.v_height) collectionViewLayout:layout];
        
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.clipsToBounds = NO;
        [_collectionView registerNib:[UINib nibWithNibName:@"G100PhotoPickerCell" bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier:kPickCellIdentifier];
        [_collectionView registerNib:[UINib nibWithNibName:@"G100PhotoShowCell" bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier:kPhotoCellIdentifier];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.clipsToBounds = YES;
        [self addSubview:_collectionView];
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.v_height, self.v_height);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataArray.count < self.maxSeletedNumber) {
        return self.dataArray.count+1;
    }
    return self.maxSeletedNumber;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.dataArray.count < self.maxSeletedNumber) {
        if (indexPath.row < self.dataArray.count) {
            G100PhotoShowCell *cell = [[G100PhotoShowCell alloc]init];
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
            G100PhotoShowModel *model = self.dataArray[indexPath.row];
            [cell setImageViewWithModel:model];
            return cell;
        }else{
            G100PhotoPickerCell *cell = [[G100PhotoPickerCell alloc]init];
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPickCellIdentifier forIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
    }else if (self.dataArray.count >= self.maxSeletedNumber) {
        G100PhotoShowCell *cell = [[G100PhotoShowCell alloc]init];
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];
        G100PhotoShowModel *model = self.dataArray[indexPath.row];
        [cell setImageViewWithModel:model];
        return cell;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    G100PhotoBrowserViewController *viewController = [[G100PhotoBrowserViewController alloc] initWithPhotos:self.dataArray currentIndex:indexPath.row];
    viewController.delegate = self;
    viewController.isShowCoverBtn = self.isShowCoverBtn;
    [viewController setDelBtnHidden:!self.isAllowEdit];
    viewController.deletedCompeletionBlock = ^(NSArray *dataArray){
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:dataArray];
        [self.collectionView reloadData];
    };
    viewController.hidesBottomBarWhenPushed = YES;
    if ([CURRENTVIEWCONTROLLER isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController*)CURRENTVIEWCONTROLLER pushViewController:viewController animated:YES];
    }else{
        [CURRENTVIEWCONTROLLER.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - PhotoBrowserDelegate
- (void)photoBrowserViewController:(G100PhotoBrowserViewController*)browser deletedPhoto:(NSString*)url newArray:(NSArray*)photos {
    if (url) {
        if ([self.delegate respondsToSelector:@selector(pickerView:hasDeletedPhotoName:)]) {
            [self.delegate pickerView:self hasDeletedPhotoName:url];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(pickerView:hasChangedPhotos:)]) {
        [self.delegate pickerView:self hasChangedPhotos:photos];
    }
  
}

- (void)photoBrowserSetCoverImageUrl:(NSString *)url
{
    if ([self.delegate respondsToSelector:@selector(pickerView: coverUrl:)]) {
        [self.delegate pickerView:self coverUrl:url];
    }
}
#pragma mark - PhotoPickerCellDelegate
- (void)actionWithButtonIndex:(NSInteger)index {
    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
    picker.allowsEditing = NO;
    picker.delegate = self;
    if (index == 1) {
        // 设置资源类型 --》 先要检测要设置的资源类型是否可用
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [CURRENTVIEWCONTROLLER presentViewController:picker animated:YES completion:nil];
            
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                
                if (ISIOS8ADD) {
                    [MyAlertView MyAlertWithTitle:@"允许使用相机" message:@"相机未开启，请进入系统【设置】>【隐私】>【相机】中打开开关，并允许骑卫士使用您的相机"
                                         delegate:self
                                 withMyAlertBlock:^(NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                    } cancelButtonTitle:@"取消" otherButtonTitles:@"前去允许"];
                }else{
                    [MyAlertView MyAlertWithTitle:@"允许使用相机" message:@"相机未开启，请进入系统【设置】>【隐私】>【相机】中打开开关，并允许骑卫士使用您的相机"
                                         delegate:self
                                 withMyAlertBlock:nil
                                cancelButtonTitle:nil
                                otherButtonTitles:@"我知道了"];
                }
            }
        }else {
            [MyAlertView MyAlertWithTitle:@"提示"
                                  message:@"相机不可用"
                                 delegate:self
                         withMyAlertBlock:nil
                        cancelButtonTitle:@"我知道了"
                        otherButtonTitles:nil];
        }
    }else if (index == 2) {
        // 相册选择
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            DNImagePickerController *imagePicker = [[DNImagePickerController alloc] init];
            imagePicker.imagePickerDelegate = self;
            imagePicker.pickedCount = self.dataArray.count;
            imagePicker.maxSeletedNumber = self.maxSeletedNumber;
            [CURRENTVIEWCONTROLLER presentViewController:imagePicker animated:YES completion:nil];
        }else{
            [MyAlertView MyAlertWithTitle:@"提示"
                                  message:@"相机不可用"
                                 delegate:self
                         withMyAlertBlock:nil
                        cancelButtonTitle:@"我知道了"
                        otherButtonTitles:nil];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    //关闭相册界面
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        if ([type isEqualToString:@"public.image"]) {
            //先把图片转成NSData
            UIImage* originalImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            [self.assetsLibrary writeImageToSavedPhotosAlbum:[originalImage CGImage] orientation:(ALAssetOrientation)[originalImage imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){
                if (error) {
                    // TODO: error handling
                }else{
                    [self.assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        
                        UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
                        //NSLog(@"%lld",asset.defaultRepresentation.size/1024);
                        NSData *compressedData = [self resetSizeOfImageData:image maxSize:300];
                        UIImage * compressedImage = [UIImage imageWithData:compressedData];
                        //UIImage *image = [self thumbnailForAsset:asset maxPixelSize:1000];
                        //NSData *data = UIImageJPEGRepresentation(compressedImage, 1);
                        //NSData *data = UIImagePNGRepresentation(image);
                        G100PhotoShowModel *model = [G100PhotoShowModel new];
                        model.image = compressedImage;
                        model.data = compressedData;
                        model.photoName = [[asset defaultRepresentation] filename];
                        
                        [self.dataArray insertObject:model atIndex:self.dataArray.count];
                        
                        if ([self.delegate respondsToSelector:@selector(pickerView:hasChangedPhotos:)]) {
                            [self.delegate pickerView:self hasChangedPhotos:self.dataArray.copy];
                        }
                        
                        [self.collectionView reloadData];
                        //[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                        
                    } failureBlock:^(NSError *error) {
                        
                    }];
                }
            }];
        }
     
        /*
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        //当选择的类型是图片
        if ([type isEqualToString:@"public.image"]) {
            //先把图片转成NSData
            UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            
            G100PhotoShowModel *model = [G100PhotoShowModel new];
            model.image = image;
            model.data = imageData;
            [self.dataArray insertObject:model atIndex:self.dataArray.count];
            //[self.collectionView reloadData];
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
            [self.collectionView reloadData];
        }
         */
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }];
}

- (void)setImageViewWithImage:(UIImage *)image index:(int)index{
    if (!image) {
        return;
    }
    //NSLog(@"%lld",asset.defaultRepresentation.size/1024);
    NSData *compressedData = [self resetSizeOfImageData:image maxSize:300];
    UIImage * compressedImage = [UIImage imageWithData:compressedData];
    
    G100PhotoShowModel *model = [G100PhotoShowModel new];
    model.image = compressedImage;
    model.data = compressedData;
    // model.photoName = [[asset defaultRepresentation] filename];
    [self.dataArray addObject:model];
    [self.collectionView reloadData];
    
   // if (self.imageAsset.count == index+1) {
        if ([self.delegate respondsToSelector:@selector(pickerView:hasChangedPhotos:)]) {
            [self.delegate pickerView:self hasChangedPhotos:self.dataArray.copy];
        }
   // }
    
}


#pragma mark - DNImagePickerControllerDelegate(不用了)
- (void)dnImagePickerController:(DNImagePickerController *)imagePicker
                     sendImages:(NSArray *)imageAssets
                    isFullImage:(BOOL)fullImage {
    [self loadImageWithImageAssets:imageAssets];
    self.imageAsset = imageAssets;
}

#pragma mark  加载相册图片(不用了)
- (void)loadImageWithImageAssets:(NSArray *)imageAssets{
    //转换图片格式
    for ( int i = 0; i<imageAssets.count; i++) {
        DNAsset *dnasset = imageAssets[i];
        ALAssetsLibrary *lib = [ALAssetsLibrary new];
        __weak typeof(self) weakSelf = self;
        [lib assetForURL:dnasset.url resultBlock:^(ALAsset *asset){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (asset) {
                [strongSelf setImageViewWithasset:asset index:i];
            } else {
                [lib enumerateGroupsWithTypes:ALAssetsGroupPhotoStream
                                   usingBlock:^(ALAssetsGroup *group, BOOL *stop)
                 {
                     [group enumerateAssetsWithOptions:NSEnumerationReverse
                                            usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                                
                                                if([[result valueForProperty:ALAssetPropertyAssetURL] isEqual:dnasset.url])
                                                {
                                                    [strongSelf setImageViewWithasset:result index:i];
                                                    *stop = YES;
                                                }
                                            }];
                 }
                                 failureBlock:^(NSError *error)
                 {
                     [strongSelf setImageViewWithasset:nil index:i];
                 }];
            }
            
        } failureBlock:^(NSError *error){
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf setImageViewWithasset:nil index:i];
        }];
    }
}

- (NSData *)resetSizeOfImageData:(UIImage *)source_image maxSize:(NSInteger)maxSize {
    //先调整分辨率
    CGSize newSize = CGSizeMake(source_image.size.width, source_image.size.height);
    CGFloat tempHeight = newSize.height / 1024;
    CGFloat tempWidth = newSize.width / 1024;
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(source_image.size.width / tempWidth, source_image.size.height / tempWidth);
    }else if (tempHeight > 1.0 && tempWidth < tempHeight){
        newSize = CGSizeMake(source_image.size.width / tempHeight, source_image.size.height / tempHeight);
    }
    UIGraphicsBeginImageContext(newSize);
    [source_image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //调整大小
    NSData *imageData = UIImageJPEGRepresentation(newImage,1.0);
    NSUInteger sizeOrigin = [imageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    if (sizeOriginKB > maxSize) {
        NSData *finallImageData = UIImageJPEGRepresentation(newImage,0.75);
        return finallImageData;
    }
    return imageData;
}

//设置图片(不用了)
- (void)setImageViewWithasset:(ALAsset *)asset index:(int)index{
    if (!asset) {
        return;
    }
    
    UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    //NSLog(@"%lld",asset.defaultRepresentation.size/1024);
    NSData *compressedData = [self resetSizeOfImageData:image maxSize:300];
    UIImage * compressedImage = [UIImage imageWithData:compressedData];
    //UIImage *image = [self thumbnailForAsset:asset maxPixelSize:1000];
    //NSData *data = UIImageJPEGRepresentation(compressedImage, 1);
    //NSData *data = UIImagePNGRepresentation(image);
    G100PhotoShowModel *model = [G100PhotoShowModel new];
    model.image = compressedImage;
    model.data = compressedData;
    model.photoName = [[asset defaultRepresentation] filename];
    [self.dataArray addObject:model];
    [self.collectionView reloadData];
    
    if (self.imageAsset.count == index+1) {
        if ([self.delegate respondsToSelector:@selector(pickerView:hasChangedPhotos:)]) {
            [self.delegate pickerView:self hasChangedPhotos:self.dataArray.copy];
        }
    }
    
}

static size_t getAssetBytesCallback(void *info, void *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
    }
    
    return countRead;
}

static void releaseAssetCallback(void *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

//压缩图片
- (UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size
{
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks =
    {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void *)CFBridgingRetain(rep), [rep size], &callbacks);
    
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef)
                                                              @{   (NSString *)kCGImageSourceCreateThumbnailFromImageAlways: @YES,
                                                                   (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithInteger:size],
                                                                   (NSString *)kCGImageSourceCreateThumbnailWithTransform :@YES,
                                                                   });
    
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}

- (void)dnImagePickerControllerDidCancel:(DNImagePickerController *)imagePicker {
    [imagePicker dismissViewControllerAnimated:YES completion:^{
    }];
}


@end

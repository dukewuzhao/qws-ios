//
//  G100CityPickViewController.m
//  G100
//
//  Created by 天奕 on 15/12/25.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100CityPickViewController.h"
#import "G100InUseCityCollectionViewCell.h"

#import "G100ServiceCityDataDomain.h"

static NSString *cellIdentifier = @"cell";

@interface G100CityPickViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *contentCollectionView;

- (IBAction)back:(UIButton *)sender;

@end

@implementation G100CityPickViewController

- (NSArray *)dataArray {
    if (!_dataArray) {
        self.dataArray = [[NSArray alloc] init];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBarView.hidden = YES;
    
    UINib *nib = [UINib nibWithNibName:@"G100InUseCityCollectionViewCell" bundle:[NSBundle mainBundle]];
    [self.contentCollectionView registerNib:nib forCellWithReuseIdentifier:cellIdentifier];
    [self.contentCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    [self.contentCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
    self.contentCollectionView.alwaysBounceVertical = YES;
    UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout *)_contentCollectionView.collectionViewLayout;
    collectionViewLayout.headerReferenceSize = CGSizeMake(WIDTH, 30);
    collectionViewLayout.footerReferenceSize = CGSizeMake(WIDTH, 40);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    G100InUseCityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    G100ServiceCityDomain * serviceCity = self.dataArray[indexPath.row];
    [cell setCityDomain:serviceCity];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];

        UILabel *inUseCityLabel = [[UILabel alloc]init];
        inUseCityLabel.font = [UIFont systemFontOfSize:14.0f];
        inUseCityLabel.textColor = [UIColor grayColor];
        inUseCityLabel.text = @"服务城市";
        [headerView addSubview:inUseCityLabel];
        
        [inUseCityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(@0);
            make.leading.equalTo(WidthInSmallest(12.0));
            make.width.equalTo(WIDTH - WidthInSmallest(12.0));
        }];
        reusableview = headerView;
    }

    if (kind == UICollectionElementKindSectionFooter) {
    UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        UILabel *expectLabel = [[UILabel alloc]init];
        expectLabel.textAlignment = NSTextAlignmentCenter;
        expectLabel.font = [UIFont systemFontOfSize:17.0f];
        expectLabel.textColor = [UIColor grayColor];
        expectLabel.text = @"更多城市，即将上线";
        [footerview addSubview:expectLabel];
        
        [expectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(@0);
            make.leading.and.trailing.equalTo(@0);
        }];
        
        reusableview = footerview;
    }
    reusableview.backgroundColor = [UIColor clearColor];
    return reusableview;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    G100ServiceCityDomain * serviceCity = self.dataArray[indexPath.row];
    
    if (serviceCity.serviceflag == 0) {
        [self showHint:@"该城市未开通"];
    }else if (serviceCity.serviceflag == 1) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (_pickCityComplete) {
                self.pickCityComplete(serviceCity, indexPath);
            }
        }];
    }else if (serviceCity.serviceflag == 2) {
        [self showHint:@"该城市即将开通"];
    }else {
        [self showHint:@"敬请期待"];
    }
}

#pragma mark --UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((WIDTH-32)/3, 45);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 12.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 4.0f;
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 8, 12, 8);
}

@end

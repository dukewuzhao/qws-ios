//
//  G100FindViewController.m
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100FindViewController.h"
#import "G100DiscoveryViewController.h"

#import "G100FindButton.h"

@interface G100FindViewController ()

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *hintString;
@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation G100FindViewController

- (void)dealloc {
    DLog(@"发现界面已释放");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationTitle:@"发现"];
    
    [self setupInitialData];
    
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor clearColor];
    
    [self.contentView addSubview:_scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.and.left.and.right.equalTo(@0);
    }];
    
    CGFloat kPadding = 20;
    CGFloat buttonX = 20;
    CGFloat buttonY = 20;
    
    CGFloat buttonW = (WIDTH - kPadding*3)/2.0f;
    
    for (NSInteger index = 0; index < _dataArray.count; index++) {
        
        buttonX = (buttonW + kPadding)*(index%2) + kPadding;
        buttonY = (buttonW + kPadding)*(index/2) + kPadding;
        
        NSString *imageName = _dataArray[index];
        
        G100FindButton *findButton = [[[NSBundle mainBundle] loadNibNamed:@"G100FindButton" owner:self options:nil] lastObject];
        findButton.tag = 100 + index;
        [findButton addTarget:self action:@selector(findButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        findButton.backImageView.image = [UIImage imageNamed:imageName];
        findButton.hintTitleLabel.text = [self.hintString substringWithRange:NSMakeRange(index, 1)];
        findButton.layer.masksToBounds = YES;
        findButton.layer.cornerRadius = buttonW/2.0f;
        
        [self.scrollView addSubview:findButton];
        
        [findButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(buttonY);
            make.left.equalTo(buttonX);
            make.width.and.height.equalTo(buttonW);
        }];        
        
    }
}

- (void)setupInitialData
{
    _hintString = @"行业地图";
    _dataArray = @[ @"demo_iv_1",
                    @"demo_iv_2",
                    @"demo_iv_3",
                    @"demo_iv_4"].mutableCopy;
}

- (void)findButtonClick:(UIButton *)button {
    // 附近
    G100DiscoveryViewController *discoveryController = [[G100DiscoveryViewController alloc]initWithNibName:@"G100DiscoveryViewController" bundle:nil];
    [self.navigationController pushViewController:discoveryController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setLeftBarButtonHidden:YES];
}

@end

//
//  G100BikeInfoNavigationView.m
//  G100
//
//  Created by 曹晓雨 on 2017/6/2.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "G100BikeInfoNavigationView.h"
#import "G100BikeDomain.h"

@interface G100BikeInfoNavigationView()

@property (weak, nonatomic) IBOutlet UILabel *bikeNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isMasterImage;

@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIButton *rightButtonImage;

@end

@implementation G100BikeInfoNavigationView

+ (instancetype)loadXibView{
    G100BikeInfoNavigationView *xibView = [[[NSBundle mainBundle] loadNibNamed:@"G100BikeInfoNavigationView" owner:self options:nil] lastObject];
    [xibView setBikeDoamin:nil];
    return xibView;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftButtonClick)];
    [self.leftView addGestureRecognizer:tap];
}

- (IBAction)leftButtonClicked:(id)sender {
    self.tapAction(1);
}

- (void)leftButtonClick {
    self.tapAction(1);
}

- (IBAction)rightButtonClicked:(id)sender {
    self.tapAction(2);
}

- (void)setNavigationTitle:(NSString *)navigationTitle {
    _navigationTitle = navigationTitle;
    
    self.bikeNameLabel.text = navigationTitle;
}

- (void)setBikeDoamin:(G100BikeDomain *)bikeDoamin {
    _bikeDoamin = bikeDoamin;
    
    self.bikeNameLabel.text = bikeDoamin.name;
    self.isMasterImage.hidden = !_bikeDoamin.isMaster;
}

@end

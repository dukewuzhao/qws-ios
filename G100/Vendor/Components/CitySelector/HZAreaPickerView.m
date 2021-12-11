//
//  HZAreaPickerView.m
//  areapicker
//
//  Created by Cloud Dai on 12-9-9.
//  Copyright (c) 2012年 clouddai.com. All rights reserved.
//

#import "HZAreaPickerView.h"
#import <QuartzCore/QuartzCore.h>

@interface HZAreaPickerView ()

@property (strong, nonatomic) NSArray * provinces;
@property (strong, nonatomic) NSArray * cities;
@property (strong, nonatomic) NSArray * areas;

@end

@implementation HZAreaPickerView

@synthesize delegate=_delegate;
@synthesize pickerStyle=_pickerStyle;
@synthesize locate=_locate;
@synthesize locatePicker = _locatePicker;

- (void)dealloc
{
    [_locate release];
    [_locatePicker release];
    [_provinces release];
    [super dealloc];
}

-(HZLocation *)locate
{
    if (_locate == nil) {
        _locate = [[HZLocation alloc] init];
    }
    
    return _locate;
}

- (id)initWithFrame:(CGRect)frame Style:(HZAreaPickerStyle)pickerStyle delegate:(id<HZAreaPickerDelegate>)delegate
{
    if (self = [super initWithFrame:frame]) {
        self = [[[[NSBundle mainBundle] loadNibNamed:@"HZAreaPickerView" owner:self options:nil] objectAtIndex:0] retain];
        self.delegate = delegate;
        self.pickerStyle = pickerStyle;
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
        self.frame = frame;
        self.locatePicker.frame = self.bounds;
        
        //加载数据
        //加载数据
        if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
            self.provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"area.plist" ofType:nil]];
            self.cities = [[self.provinces objectAtIndex:0] objectForKey:@"cities"];
            
            self.locate.state = [[_provinces objectAtIndex:0] objectForKey:@"state"];
            self.locate.city = [[_cities objectAtIndex:0] objectForKey:@"city"];
            
            self.areas = [[_cities objectAtIndex:0] objectForKey:@"areas"];
            if (_areas.count > 0) {
                self.locate.district = [_areas objectAtIndex:0];
            } else{
                self.locate.district = @"";
            }
            
        } else{
            self.provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"city.plist" ofType:nil]];
            self.cities = [[self.provinces objectAtIndex:0] objectForKey:@"cities"];
        }
    }
    
    return self;
}
#pragma mark - PickerView lifecycle
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
        return 3;
    } else{
        return 2;
    }
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat w = self.frame.size.width;
    if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
        if(component == 0)
            return 3 * w / 16;
        if (component == 1)
            return 5 * w / 16;
        return 8 * w / 16;
    }else {
        if(component == 0)
            return w / 2;
        if (component == 1)
            return w / 2;
    }
    
    return 10;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *myView = nil;
    myView = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.locatePicker.frame.size.width / 3, 50)] autorelease];
    myView.textAlignment = NSTextAlignmentCenter;
    myView.font = [UIFont systemFontOfSize:20];
    myView.backgroundColor = [UIColor clearColor];
    CGFloat w = self.frame.size.width;
    if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
        switch (component) {
            case 0:
                myView.v_width = 3 * w / 16;
                myView.text = [[_provinces objectAtIndex:row] objectForKey:@"state"];
                break;
            case 1:
                myView.v_width = 5 * w / 16;
                myView.text = [[_cities objectAtIndex:row] objectForKey:@"city"];
                break;
            case 2:
                myView.v_width = 8 * w / 16;
                if ([_areas count] > 0) {
                    myView.text = [_areas objectAtIndex:row];
                }else {
                    self.locate.district = @"";
                }
                break;
            default:
                
                break;
        }
    }else {
        switch (component) {
            case 0:
                myView.v_width = w / 2;
                myView.text = [[_provinces objectAtIndex:row] objectForKey:@"state"];
                break;
            case 1:
                myView.v_width = w / 2;
                myView.text = [_cities objectAtIndex:row];
                break;
            default:
                
                break;
        }
    }
    
    return myView;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [_provinces count];
            break;
        case 1:
            return [_cities count];
            break;
        case 2:
            if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
                return [_areas count];
                break;
            }
        default:
            return 0;
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.pickerStyle == HZAreaPickerWithStateAndCityAndDistrict) {
        switch (component) {
            case 0:
            {
                _cities = [[_provinces objectAtIndex:row] objectForKey:@"cities"];
                [self.locatePicker selectRow:0 inComponent:1 animated:YES];
                [self.locatePicker reloadComponent:1];
                
                _areas = [[_cities objectAtIndex:0] objectForKey:@"areas"];
                [self.locatePicker selectRow:0 inComponent:2 animated:YES];
                [self.locatePicker reloadComponent:2];
                
                self.locate.state = [[_provinces objectAtIndex:row] objectForKey:@"state"];
                self.locate.city = [[_cities objectAtIndex:0] objectForKey:@"city"];
                if ([_areas count] > 0) {
                    self.locate.district = [_areas objectAtIndex:0];
                }else {
                    self.locate.district = @"";
                }
            }
                break;
            case 1:
            {
                _areas = [[_cities objectAtIndex:row] objectForKey:@"areas"];
                [self.locatePicker selectRow:0 inComponent:2 animated:YES];
                [self.locatePicker reloadComponent:2];
                
                self.locate.city = [[_cities objectAtIndex:row] objectForKey:@"city"];
                if ([_areas count] > 0) {
                    self.locate.district = [_areas objectAtIndex:0];
                }else {
                    self.locate.district = @"";
                }
            }
                break;
            case 2:
            {
                if ([_areas count] > 0) {
                    self.locate.district = [_areas objectAtIndex:row];
                }else {
                    self.locate.district = @"";
                }
                break;
            }
            default:
                break;
        }
    }else {
        switch (component) {
            case 0:
                _cities = [[_provinces objectAtIndex:row] objectForKey:@"cities"];
                [self.locatePicker selectRow:0 inComponent:1 animated:YES];
                [self.locatePicker reloadComponent:1];
                
                self.locate.state = [[_provinces objectAtIndex:row] objectForKey:@"state"];
                self.locate.city = [_cities objectAtIndex:0];
                break;
            case 1:
                self.locate.city = [_cities objectAtIndex:row];
                break;
            default:
                break;
        }
    }
    
    if([self.delegate respondsToSelector:@selector(pickerDidChaneStatus:)]) {
        [self.delegate pickerDidChaneStatus:self];
    }
}

-(void)setDefaultArea:(NSString *)defaultArea {
    if (!defaultArea.length) {
        defaultArea = @"上海 闵行";
    }
    
    if (![defaultArea hasContainString:@" "]) {
        defaultArea = [NSString stringWithFormat:@"%@ 无", defaultArea];
    }
    
    NSArray * areaArray  =[defaultArea componentsSeparatedByString:@" "];
    
    _provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"city.plist" ofType:nil]];
    
    NSInteger a = [self findIndexFor:areaArray[0] in:_provinces key:@"state"];
    [self.locatePicker selectRow:a inComponent:0 animated:YES];
    [self.locatePicker reloadComponent:1];
    
    _cities = [[_provinces objectAtIndex:a] objectForKey:@"cities"];
    NSInteger b = [self findIndexFor:areaArray[1] in:_cities];
    [self.locatePicker selectRow:b inComponent:1 animated:YES];
    
    self.locate.state = [[_provinces objectAtIndex:a] objectForKey:@"state"];
    self.locate.city = [_cities objectAtIndex:b];
}

-(NSInteger)findIndexFor:(NSString *)str in:(NSArray *)strArray key:(NSString *)key {
    for (NSInteger i = 0; i < strArray.count; i++) {
        if ([str isEqualToString:[strArray[i] objectForKey:key]]) {
            return i;
        }
    }
    
    return 0;
}

-(NSInteger)findIndexFor:(NSString *)str in:(NSArray *)strArray {
    for (NSInteger i = 0; i < strArray.count; i++) {
        if ([str isEqualToString:strArray[i]]) {
            return i;
        }
    }
    
    return 0;
}

@end

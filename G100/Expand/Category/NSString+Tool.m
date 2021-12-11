//
//  NSString+Tool.m
//  YanYi
//
//  Created by 王清健 on 14-11-14.
//  Copyright (c) 2014年 王清健. All rights reserved.
//

#import "NSString+Tool.h"
#import "ExtString.h"

@implementation NSString (Tool)

/** 邮箱验证 */
-(BOOL)isValidateEmail
{
    //不是字符串
    if (!self) {
        return NO;
    }
    //如果长度为0 那不是邮箱
    if ([self length] == 0) {
        return NO;
    }

    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

/** 手机号码验证 */
- (BOOL)isValidateMobile{
    //不是字符串
    if (!self) {
        return NO;
    }
    //如果长度为0 那不是电话号
    if ([self length] == 0) {
        return NO;
    }
    
    NSString * phoneRegex = @"^1[0-9]*$";
    NSPredicate *phoneTemp = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    
    return [phoneTemp evaluateWithObject:self];
}

-(BOOL)isValidateQQ {
    //不是字符串
    if (!self) {
        return NO;
    }
    //如果长度为0 那不是QQ号
    if ([self length] == 0) {
        return NO;
    }
    
    NSString *qq = @"^[1-9][0-9]{4,}";
    NSPredicate *qqTemp = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",qq];
    
    return [qqTemp evaluateWithObject:self];
}
//密码
+ (BOOL)validatePassword:(NSString *)passWord
{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,16}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}

//身份证号
+ (BOOL)validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}

+ (BOOL)validateUrl:(NSString *)url {
    BOOL flag;
    if (url.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^http[s]{0,1}://([\\w-]+\\.)+[\\w-]+(/[\\w-./?%&=]*)?$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:url];
}

/** 得到身份证的生日****这个方法中不做身份证校验，请确保传入的是正确身份证 */
+ (NSString *)getIDCardBirthday:(NSString *)card {
    card = [card stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([card length] != 18) {
        return nil;
    }
    NSString *birthady = [NSString stringWithFormat:@"%@-%@-%@",[card substringWithRange:NSMakeRange(6,4)], [card substringWithRange:NSMakeRange(10,2)], [card substringWithRange:NSMakeRange(12,2)]];
    return birthady;
}

/** 得到身份证的性别（1男2女）****这个方法中不做身份证校验，请确保传入的是正确身份证 */
+ (NSInteger)getIDCardSex:(NSString *)card {
    card = [card stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger defaultValue = 2;
    if ([card length] != 18) {
        return defaultValue;
    }
    NSInteger number = [[card substringWithRange:NSMakeRange(16,1)] integerValue];
    if (number % 2 == 0) {  //偶数为女
        return 2;
    } else {
        return 1;
    }
}

+(NSString *)shieldImportantInfo:(NSString *)info {
    if (info.length < 11) {
        return info;
    }
    
    NSString * result = nil;
    NSMutableString * tmp = info.mutableCopy;
    NSMutableString *xing = [NSMutableString new];
    for (NSInteger i = 0; i < info.length - 7; i++) {
        [xing appendString:@"*"];
    }
    [tmp replaceCharactersInRange:NSMakeRange(3, info.length - 7) withString:xing];
    
    result = tmp.copy;
    
    return result;
}

-(BOOL)hasContainString:(NSString *)subString {
    NSString *version = [UIDevice currentDevice].systemVersion;
    if ([version floatValue]>=8.0) {
        return [self containsString:subString];
    }else {
        NSRange range = [self rangeOfString:subString];
        
        if (range.location != NSNotFound) {
            return YES;
        }
    }
    
    return NO;
}

- (CGSize)calculateSize:(CGSize)size font:(UIFont *)font {
    CGSize expectedLabelSize = CGSizeZero;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        expectedLabelSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:attributes
                                               context:nil].size;
    }/*
    else {
        expectedLabelSize = [self sizeWithFont:font
                             constrainedToSize:size
                                 lineBreakMode:NSLineBreakByWordWrapping];
    }
    */
    return CGSizeMake(ceil(expectedLabelSize.width), ceil(expectedLabelSize.height));
}

+(NSString *)arabictoHanzi:(NSString *)arabicStr {
    NSInteger a = [arabicStr integerValue];
    NSString * s = [[NSString alloc]init];
    
    switch (a) {
        case 0:
            s = @"零";
            break;
        case 1:
            s = @"一";
            break;
        case 2:
            s = @"二";
            break;
        case 3:
            s = @"三";
            break;
        case 4:
            s = @"四";
            break;
        case 5:
            s = @"五";
            break;
        case 6:
            s = @"六";
            break;
        case 7:
            s = @"七";
            break;
        case 8:
            s = @"八";
            break;
        case 9:
            s = @"九";
            break;
        case 10:
            s = @"十";
            break;
        case 11:
            s = @"十一";
            break;
        case 12:
            s = @"十二";
            break;
        default:
            break;
    }
    
    return s;
}

+(BOOL)isEmpty:(NSString *)str {
    if (!str) {
        return true;
    } else {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}
+(NSInteger)hasWhiteSpace:(NSString *)str {
    NSInteger count = 0;
    for (int i=0; i<str.length; i++) {
        NSRange range = NSMakeRange(i,1);
        NSString *aStr = [str substringWithRange:range];
        if ([aStr isEqualToString:@" "]) {
            count++;
        }
    }

    return count;
}

+(BOOL)isDigitsOnly:(NSString *)string {
    NSString * tmp = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    return tmp.length > 0 ? NO : YES;
}

-(NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

+ (BOOL)isVersion:(NSString*)versionA biggerThanVersion:(NSString*)versionB
{
    NSArray *arrayNow = [versionB componentsSeparatedByString:@"."];
    NSArray *arrayNew = [versionA componentsSeparatedByString:@"."];
    BOOL isBigger = NO;
    NSInteger i = arrayNew.count > arrayNow.count? arrayNow.count : arrayNew.count;
    NSInteger j = 0;
    BOOL hasResult = NO;
    for (j = 0; j < i; j ++) {
        NSString* strNew = [arrayNew objectAtIndex:j];
        NSString* strNow = [arrayNow objectAtIndex:j];
        if ([strNew integerValue] > [strNow integerValue]) {
            hasResult = YES;
            isBigger = YES;
            break;
        }
        if ([strNew integerValue] < [strNow integerValue]) {
            hasResult = YES;
            isBigger = NO;
            break;
        }
    }
    if (!hasResult) {
        if (arrayNew.count > arrayNow.count) {
            NSInteger nTmp = 0;
            NSInteger k = 0;
            for (k = arrayNow.count; k < arrayNew.count; k++) { 
                nTmp += [[arrayNew objectAtIndex:k]integerValue]; 
            } 
            if (nTmp > 0) { 
                isBigger = YES; 
            } 
        } 
    } 
    return isBigger; 
}

- (NSString *)appendUrlWithParamter:(NSString *)para {
    if ([self hasContainString:@"?"]) {
        return [self stringByAppendingString:[NSString stringWithFormat:@"&%@",para]];
    }else{
        return [self stringByAppendingString:[NSString stringWithFormat:@"?%@",para]];
    }
}

+ (NSString *)getSessionidWithStr:(NSString *)picvcurl {
    NSArray *array = [picvcurl componentsSeparatedByString:@"?"];
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    if (array.count == 2) {
        NSString *result = array[1];
        NSArray *paramsArray = [result componentsSeparatedByString:@"&"];
        for (NSString *param in paramsArray) {
            NSArray *tmp = [param componentsSeparatedByString:@"="];
            if (tmp.count == 2) {
                [paramsDict setObject:tmp[1] forKey:tmp[0]];
            }
        }
    }
    if ([[paramsDict allKeys] containsObject:@"sessionid"]) {
        return [paramsDict objectForKey:@"sessionid"];
    }
    return nil;
}

+ (NSString *)getPicNameWithPicvcurl:(NSString *)picvcurl {
    NSArray *firstArray = [picvcurl componentsSeparatedByString:@"?"];
    if (firstArray.count>0) {
        NSArray *secondArray = [[firstArray firstObject] componentsSeparatedByString:@"/"];
        if (secondArray.count>0) {
            NSArray *thirdArray = [[secondArray lastObject] componentsSeparatedByString:@"."];
            return [thirdArray firstObject];
        }
    }
    return nil;
}

+ (NSInteger)unicodeLengthOfString:(NSString*)strtemp {
    NSInteger strlength = 0;
    for (NSInteger i = 0; i < [strtemp length]; i++){
        int a = [strtemp characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff){
            strlength += 2;
        }else{
            strlength += 1;
        }
    }
    // 返回的是中文字符的个数
    return (strlength/2)+(strlength%2);
}

- (BOOL)is360qwsHost {
    NSDictionary *dict = [self paramsFromURL];
    NSString *host = dict[HOST];
    if ([host hasContainString:@"360qws.com"] ||
        [host hasContainString:@"360qws.cn"] ||
        [host hasContainString:@"qiweishi.com"]) {
        return YES;
    }
    return NO;
}

- (BOOL)stringContainsEmoji
{
    // 过滤所有表情。returnValue为NO表示不含有表情，YES表示含有表情
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    returnValue = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                returnValue = YES;
            }
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff) {
                returnValue = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                returnValue = YES;
            }
        }
    }];
    return returnValue;
}

- (NSInteger)countForEmoji {
    __block NSInteger count = 0;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    count++;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                count++;
            }
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff) {
                count++;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                count++;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                count++;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                count++;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                count++;
            }
        }
    }];
    
    return count;
}

- (NSString *)subEmojiStringToIndex:(NSUInteger)to {
    NSString *result = self;
    if (result.length > to) {
        NSRange rangeIndex = [result rangeOfComposedCharacterSequenceAtIndex:to];
        result = [result substringToIndex:(rangeIndex.location)];
    }
    
    return result;
}

- (NSString *)subStringWith:(NSString *)string ToIndex:(NSInteger)index {
    NSString *result = string;
    if (result.length > index) {
        NSRange rangeIndex = [result rangeOfComposedCharacterSequenceAtIndex:index];
        result = [result substringToIndex:(rangeIndex.location)];
    }
    
    return result;
}

+ (NSString *)getTotalTimeWithStartTime:(NSString *)startTime endTime:(NSString *)endTime{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *localTimeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:localTimeZone];
    
    NSDate *startDate = [dateFormatter dateFromString:startTime];
    NSDate *endDate = [dateFormatter dateFromString:endTime];
    
    NSTimeInterval start = [startDate timeIntervalSince1970]*1;
    NSTimeInterval end = [endDate timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    
    NSString *str = [NSString stringWithFormat:@"%d分", (int)value / 60 % 60];
    return str;
}

@end

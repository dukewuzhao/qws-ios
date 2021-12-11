//
//  AFRequest.h
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AFRequestBlock)(id responseObj,BOOL isErrorData,BOOL isResponseCountZero);
typedef void (^AFRequestFailBlock)(id error);
typedef void (^AFRequestDictBlock)(id dict);

@interface AFRequest : NSObject

@property (nonatomic,copy) AFRequestBlock afRequestBlock;
@property (nonatomic,copy) AFRequestFailBlock afRequestFailBlock;
@property (nonatomic,copy) AFRequestDictBlock afRequestDictBlock;

/** 
 * 用于 其他
 */
+ (void)requestWithNet:(NSString *)net withKeyArr:(NSArray *)keyArr withObjArr:(NSArray *)objArr withBlock:(AFRequestBlock)block withFailBlock:(AFRequestFailBlock)failBlock;
/**
 * 用于 登录
 */
+ (void)requestWithNet:(NSString *)net withKeyArr:(NSArray *)keyArr withObjArr:(NSArray *)objArr withToken:(BOOL )isExisterToken withBlock:(AFRequestBlock)block withFailBlock:(AFRequestFailBlock)failBlock withDictBlock:(AFRequestDictBlock) dictBlok;

/** 
 * 用于上传图片
 */
+ (void)requestLoadImageWithNet:(NSString *)net withKeyArr:(NSArray *)keyArr withObjArr:(NSArray *)objArr withToken:(BOOL )isExisterToken withServicerImageFileName:(NSString *)canfileName withFileName:(NSString *)fileName withImageType:(NSString *)imageType withImageData:(NSData*)imageData withBlock:(AFRequestBlock)block withFailBlock:(AFRequestFailBlock)failBlock withDictBlock:(AFRequestDictBlock) dictBlok;

@end

//
//  AFRequest.m
//  G100
//
//  Created by Tilink on 15/2/5.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "AFRequest.h"
#import "AFNetworking.h"

@implementation AFRequest

+(AFRequest *)Manager{
    AFRequest * request = [[AFRequest alloc]init];
    return request;
}

// 用于 其他
+ (void)requestWithNet:(NSString *)net withKeyArr:(NSArray *)keyArr withObjArr:(NSArray *)objArr  withBlock:(AFRequestBlock)block withFailBlock:(AFRequestFailBlock)failBlock{
    [AFRequest requestWithNet:net withKeyArr:keyArr withObjArr:objArr withToken:YES  withBlock:block withFailBlock:failBlock withDictBlock:nil];
}
// 用于登录
+ (void)requestWithNet:(NSString *)net withKeyArr:(NSArray *)keyArr withObjArr:(NSArray *)objArr withToken:(BOOL )isExisterToken withBlock:(AFRequestBlock)block withFailBlock:(AFRequestFailBlock)failBlock withDictBlock:(AFRequestDictBlock) dictBlok{
    
    AFRequest * request = [AFRequest Manager];
    request.afRequestFailBlock = failBlock;
    request.afRequestBlock = block;
    request.afRequestDictBlock = dictBlok;
    
    AFHTTPSessionManager * sessionManager = [AFHTTPSessionManager manager];
    sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 10;

    NSDictionary * dict = [request sort:keyArr withObjArr:objArr withToken:isExisterToken];
    
    if (request.afRequestDictBlock) {
        request.afRequestDictBlock(dict);
    }
    [sessionManager POST:net parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id  responseObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        BOOL isErrorData = NO;
        BOOL isResponseCountZero = NO;
        
        if (responseObj == nil || ![[responseObj objectForKey:@"state"] isEqualToString:@"00"] || [responseObj isKindOfClass:[NSNull class]]) {
            
            isErrorData = YES;
        }else{
            
            isResponseCountZero = [request isResponseNull:[responseObj objectForKey:@"data"]];
        }
        
        if (request.afRequestBlock) {
            request.afRequestBlock(responseObj,isErrorData,isResponseCountZero);
        }
        
        [task cancel];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (request.afRequestFailBlock) {
            request.afRequestFailBlock(error.localizedDescription);
        }
        
        [task cancel];
    }];
}

- (NSDictionary * )sort:(NSArray *)keyArr withObjArr:(NSArray *)objArr withToken:(BOOL)isExisterToken{
    
    NSMutableArray * keyArrM = keyArr.mutableCopy;
    NSMutableArray * objArrM = objArr.mutableCopy;
    for (int i = 0; i<keyArr.count; i++) {
        for (int j = i+1; j<keyArr.count; j++) {
            
            if([keyArrM[i] compare:keyArrM[j] options:NSLiteralSearch]== NSOrderedDescending){
                [keyArrM exchangeObjectAtIndex:i withObjectAtIndex:j];
                [objArrM exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
            
        }
    }
    
    if(isExisterToken){
        NSString * token = [[G100InfoHelper shareInstance] token];
        if ((![token isKindOfClass:[NSNull class]]) && token) {// [NSNull null] 数组 或者 字典的 数据 元素是否是空
            [keyArrM addObject:@"token"];
            [objArrM addObject:token];
        }
    }
    
    return [[NSDictionary alloc]initWithObjects:objArrM forKeys:keyArrM];
}

- (BOOL)isResponseNull:(id)obj{
    if ([obj isKindOfClass:[NSDictionary class]] ) {
        if ([(NSDictionary *)obj count]==0) {
            return YES;
        }
    }else if([obj isKindOfClass:[NSArray class]]){
      
        if ([(NSArray *)obj count]==0) {
            return YES;
        }
    }else if([obj isKindOfClass:[NSString class]]){
        
        if ([(NSString *)obj length]==0) {
            return YES;
        }
    }
    
    return NO;
}

// 用于上传图片
+ (void)requestLoadImageWithNet:(NSString *)net withKeyArr:(NSArray *)keyArr withObjArr:(NSArray *)objArr withToken:(BOOL )isExisterToken withServicerImageFileName:(NSString *)canfileName withFileName:(NSString *)fileName withImageType:(NSString *)imageType withImageData:(NSData*)imageData withBlock:(AFRequestBlock)block withFailBlock:(AFRequestFailBlock)failBlock withDictBlock:(AFRequestDictBlock) dictBlok{
    
    AFRequest * request = [AFRequest Manager];
    request.afRequestFailBlock = failBlock;
    request.afRequestBlock = block;
    request.afRequestDictBlock = dictBlok;
    
    AFHTTPSessionManager * sessionManager = [AFHTTPSessionManager manager];
    sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    sessionManager.requestSerializer.timeoutInterval = 10;
    
    NSDictionary * dict = [request sort:keyArr withObjArr:objArr withToken:isExisterToken];
    
    if (request.afRequestDictBlock) {
        request.afRequestDictBlock(dict);
    }
    
    [sessionManager POST:net parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:canfileName fileName:fileName mimeType:imageType];//@"image/jpeg"
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id  responseObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        BOOL isErrorData = NO;
        BOOL isResponseCountZero = NO;
        if (responseObj == nil || ![[responseObj objectForKey:@"errCode"] isEqualToString:@"00"] || [responseObj isKindOfClass:[NSNull class]]) {
            isErrorData = YES;
        }else{
            
            isResponseCountZero = [request  isResponseNull:[responseObj objectForKey:@"data"]];
        }
        
        if (request.afRequestBlock) {
            request.afRequestBlock(responseObj,isErrorData,isResponseCountZero);
        }
        
        [task cancel];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (request.afRequestFailBlock) {
            request.afRequestFailBlock(error.localizedDescription);
        }
        
        [task cancel];
        
    }];
}

@end

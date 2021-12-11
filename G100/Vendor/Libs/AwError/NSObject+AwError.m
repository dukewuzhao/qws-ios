//
//  NSObject+AwError.m
//  G100
//
//  Created by yuhanle on 2017/7/31.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "NSObject+AwError.h"
#import <objc/runtime.h>

#define ALERT_VIEW(Title, Message, Controller) {UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:Title message:Message preferredStyle:UIAlertControllerStyleAlert];        [alertVc addAction:action];[Controller presentViewController:alertVc animated:YES completion:nil];}

#import "AppDelegate.h"

static NSString *_errorFunctionName;
void dynamicMethodIMP(id self,SEL _cmd) {
#ifdef DEBUG
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *currentRootViewController = delegate.window.rootViewController;
    NSString *error = [NSString stringWithFormat:@"ErrorClass->:%@\n errorFuction->%@\n ErrorReason->UnRecognized Selector", NSStringFromClass([self class]), _errorFunctionName];
    ALERT_VIEW(@"程序异常", error, currentRootViewController);
#else
    //upload error
    
#endif
}

static inline void change_method(Class _originalClass ,SEL _originalSel,Class _newClass ,SEL _newSel){
    Method methodOriginal = class_getInstanceMethod(_originalClass, _originalSel);
    Method methodNew = class_getInstanceMethod(_newClass, _newSel);
    method_exchangeImplementations(methodOriginal, methodNew);
}

@implementation NSObject (AwError)

+ (void)load {
    change_method([self class], @selector(methodSignatureForSelector:), [self class], @selector(aw_methodSignatureForSelector:));
    change_method([self class], @selector(forwardInvocation:), [self class], @selector(aw_forwardInvocation:));
}

- (NSMethodSignature *)aw_methodSignatureForSelector:(SEL)aSelector {
    if (![self respondsToSelector:aSelector]) {
        _errorFunctionName = NSStringFromSelector(aSelector);
        NSMethodSignature *methodSignature = [self aw_methodSignatureForSelector:aSelector];
        if (class_addMethod([self class], aSelector, (IMP)dynamicMethodIMP, "v@:")) {
            NSLog(@"临时方法添加成功！");
        }
        if (!methodSignature) {
            methodSignature = [self aw_methodSignatureForSelector:aSelector];
        }
        
        return methodSignature;
        
    }else {
        return [self aw_methodSignatureForSelector:aSelector];
    }
}

- (void)aw_forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = [anInvocation selector];
    if ([self respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self];
    }else {
        [self aw_forwardInvocation:anInvocation];
    }
}

@end

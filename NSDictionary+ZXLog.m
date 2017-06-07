//
//  NSDictionary+ZXLog.m
//  ZX-UnicodeConversion
//
//  Created by shawn on 09/01/2017.
//  Copyright © 2017 shawn. All rights reserved.
//

#ifndef ZX_TARGET_NEED_UNICODE_CONVERSION
    #ifdef DEBUG
    #define ZX_TARGET_NEED_UNICODE_CONVERSION 1
    #else
    #define ZX_TARGET_NEED_UNICODE_CONVERSION 0
    #endif
#endif

#if ZX_TARGET_NEED_UNICODE_CONVERSION
#import <objc/runtime.h>
#endif
#import "NSDictionary+ZXLog.h"

@implementation NSDictionary (ZXLog)

#if ZX_TARGET_NEED_UNICODE_CONVERSION
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        zx_swizzleSelector([self class], @selector(descriptionWithLocale:indent:), @selector(zx_descriptionWithLocale:indent:));
    });
}

static inline void zx_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector)
{
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(theClass,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(theClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (NSString *)zx_descriptionWithLocale:(id)locale indent:(NSUInteger)level
{
    return [self stringByReplaceUnicode:[self zx_descriptionWithLocale:locale indent:level]];
}
#endif

- (NSString *)stringByReplaceUnicode:(NSString *)unicodeString
{
    NSMutableString *convertedString = [unicodeString mutableCopy];
    [convertedString replaceOccurrencesOfString:@"\\U" withString:@"\\u" options:0 range:NSMakeRange(0, convertedString.length)];
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    
    return convertedString;
}

@end


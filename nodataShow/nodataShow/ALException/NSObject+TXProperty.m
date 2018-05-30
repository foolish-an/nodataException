//
//  NSObject+TXProperty.m
//  eBigTime
//
//  Created by an on 2017/1/10.
//  Copyright © 2017年 TianXing. All rights reserved.
//

#import "NSObject+TXProperty.h"
#import <objc/runtime.h>
@implementation NSObject (TXProperty)


+ (NSArray *)tx_subClasses
{
    NSMutableArray *subCls = [NSMutableArray array];
    
    int index;
    Class *classes = NULL;
    index = objc_getClassList(NULL,0);
    if (index) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * index);
        index = objc_getClassList(classes, index);
        kRecursiveClass(classes, index, subCls, self);
        free(classes);
    }
    return subCls;
}

static void kRecursiveClass(Class *classes, int number, NSMutableArray *subClses,__unsafe_unretained Class class)
{
    for (int i = 0; i < number; i++) {
        Class subCls = classes[i];
        Class cls = class_getSuperclass(subCls);
        if (cls == [class class] && ![subClses containsObject:NSStringFromClass(classes[i])]) {
            [subClses addObject:NSStringFromClass(subCls)];
            kRecursiveClass(classes, number, subClses, subCls);
        }
    }
}


+ (NSArray *)tx_properties
{
    return kRecursiveModelForKeys([self class]);
}

- (NSDictionary *)tx_keyValues
{
    return kRecursiveModelToKeyValues(self);;
}

static NSDictionary * kRecursiveModelToKeyValues(NSObject *model) {
    if (!model)                                           return nil;
    if ([model isKindOfClass:[NSString class]])           return nil;
    if ([model isKindOfClass:[NSNumber class]])           return nil;
    if ([model isKindOfClass:[NSDictionary class]])       return nil;
    if ([model isKindOfClass:[NSSet class]])              return nil;
    if ([model isKindOfClass:[NSArray class]])            return nil;
    if ([model isKindOfClass:[NSURL class]])              return nil;
    if ([model isKindOfClass:[NSAttributedString class]]) return nil;
    if ([model isKindOfClass:[NSDate class]])             return nil;
    if ([model isKindOfClass:[NSData class]])             return nil;
    NSMutableDictionary *keyValues = [NSMutableDictionary dictionary];
    NSArray *propertyNames = kRecursiveModelForKeys([model class]);
    for (NSString *propertyName in propertyNames) {
        id value = [model valueForKey:propertyName];
        if (value) {
            [keyValues setObject:value forKey:propertyName];
        }
    }
    return keyValues;
}

static NSArray * kRecursiveModelForKeys(Class class){
    u_int count;
    objc_property_t *properties = class_copyPropertyList(class, &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(properties[i]);
        [propertiesArray addObject:[NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    Class cls = [class superclass];
    if (![NSStringFromClass(cls) isEqualToString:NSStringFromClass([NSObject class])]) {
        [propertiesArray addObjectsFromArray:kRecursiveModelForKeys(cls)];
    }
    return propertiesArray;
}

- (void)tx_printPropertyDescription
{
#ifdef DEBUG
    if (![self isKindOfClass:[NSDictionary class]]) return;
    NSMutableString *description = [NSMutableString string];
    [(NSDictionary *)self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *detail = nil;
        if ([obj isKindOfClass:NSClassFromString(@"__NSDictionaryI")] || [obj isKindOfClass:NSClassFromString(@"__NSDictionary0")] || [obj isKindOfClass:NSClassFromString(@"__NSDictionaryM")]) {
            detail = [NSString stringWithFormat:@"\n/*** %@ **/ \n@property (nonatomic, strong) NSDictionary *%@;\n",key,key];
        } else if ([obj isKindOfClass:NSClassFromString(@"__NSArrayI")] || [obj isKindOfClass:NSClassFromString(@"__NSArray0")] || [obj isKindOfClass:NSClassFromString(@"__NSArrayM")]) {
            detail = [NSString stringWithFormat:@"\n/*** %@ **/ \n@property (nonatomic, strong) NSArray *%@;\n",key,key];
        } else if ([obj isKindOfClass:NSClassFromString(@"__NSCFNumber")]) {
            const char *objCtype = [((NSNumber *)obj) objCType];
            if (strcmp(objCtype, @encode(int))  == 0) {
                detail = [NSString stringWithFormat:@"\n/*** %@ **/ \n@property (nonatomic, assign) int %@;\n",key,key];
            } else if (strcmp(objCtype, @encode(float)) == 0) {
                detail = [NSString stringWithFormat:@"\n/*** %@ **/ \n@property (nonatomic, assign) float %@;\n",key,key];
            } else if (strcmp(objCtype, @encode(double)) == 0) {
                detail = [NSString stringWithFormat:@"\n/*** %@ **/ \n@property (nonatomic, assign) double %@;\n",key,key];
            } else if (strcmp(objCtype, @encode(long)) == 0) {
                detail = [NSString stringWithFormat:@"\n/*** %@ **/ \n@property (nonatomic, assign) long %@;\n",key,key];
            } else if (strcmp(objCtype, @encode(long long)) == 0) {
                detail = [NSString stringWithFormat:@"\n/*** %@ **/ \n@property (nonatomic, assign) long long %@;\n",key,key];
            } else {
                detail = [NSString stringWithFormat:@"\n/*** %@ **/ \n@property (nonatomic, strong) NSNumber *%@;\n",key,key];
            }
        } else if ([obj isKindOfClass:NSClassFromString(@"__NSCFString")] || [obj isKindOfClass:NSClassFromString(@"NSTaggedPointerString")]) {
            detail = [NSString stringWithFormat:@"\n/*** %@ **/ \n@property (nonatomic, copy) NSString *%@;\n",key,key];
        } else if ([obj isKindOfClass:[NSNull class]]) {
            detail = [NSString stringWithFormat:@"\n/*** %@ 不确定数据类型，该值为null **/ \n@property (nonatomic, <#name#>) <#class#> *%@;\n",key,key];
        } else if ([obj isKindOfClass:NSClassFromString(@"__NSCFBoolean")]) {
            detail = [NSString stringWithFormat:@"\n/*** %@ **/ \n@property (nonatomic, assign) BOOL %@;\n",key,key];
        }
        NSString *assert = [NSString stringWithFormat:@"没有处理这种类型------>[%@]",[obj class]];
        NSAssert(detail, assert);
        [description appendString:detail];
    }];
#endif
}

+ (void)tx_exchangeClassOriginalMethod:(SEL)originalSel otherMethod:(SEL)otherSel
{
    tx_swizzleClassSelector(self, originalSel,otherSel);
}


+ (void)tx_exchangeOriginalMethod:(SEL)originalSel otherMethod:(SEL)otherSel
{
    Method swizzledMethod = class_getInstanceMethod(self, otherSel);
    Method originalMethod = class_getInstanceMethod(self, originalSel);
    tx_addMethod(self, originalSel, swizzledMethod) ? tx_replaceMethod(self, otherSel, originalMethod) : tx_swizzleSelector(self, originalSel,otherSel);
}

static inline void tx_swizzleClassSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getClassMethod(theClass, originalSelector);
    Method swizzledMethod = class_getClassMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

static inline void tx_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

static inline BOOL tx_addMethod(Class theClass, SEL selector, Method method) {
    return class_addMethod(theClass, selector,  method_getImplementation(method),  method_getTypeEncoding(method));
}

static inline void tx_replaceMethod(Class theClass, SEL swizzledSel, Method originalMethod)
{
    class_replaceMethod(theClass, swizzledSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
}

@end

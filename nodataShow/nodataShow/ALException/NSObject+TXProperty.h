//
//  NSObject+TXProperty.h
//  eBigTime
//
//  Created by an on 2017/1/10.
//  Copyright © 2017年 TianXing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (TXProperty)

+ (NSArray *)tx_subClasses;


/*** 返回对象所有属性数组 **/
+ (NSArray *)tx_properties;

/*** 模型转换成字典 **/
- (NSDictionary *)tx_keyValues;

/*** 字典打印模型属性列表 仅调试使用 **/
- (void)tx_printPropertyDescription;

/*** 运行时更换对象方法 **/
+ (void)tx_exchangeOriginalMethod:(SEL)originalSel otherMethod:(SEL)otherSel;

/*** 运行时更换类方法 **/
+ (void)tx_exchangeClassOriginalMethod:(SEL)originalSel otherMethod:(SEL)otherSel;

@end

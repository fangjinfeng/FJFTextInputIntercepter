//
//  NSString+FJFTextInputStringType.h
//  FJTextInputIntercepterDemo
//
//  Created by fjf on 2018/7/4.
//  Copyright © 2018年 fjf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,FJFTextInputStringType) {
    FJFTextInputStringTypeNumber,         //数字
    FJFTextInputStringTypeLetter,         //字母
    FJFTextInputStringTypeChinese,        //汉字
    FJFTextInputStringTypeEmoji,          //表情
};

@interface NSString (FJFTextInputStringType)

/**
 某个字符串是不是数字、字母、汉字。
 */
-(BOOL)fjf_isCertainStringType:(FJFTextInputStringType)stringType;


/**
 字符串是不是特殊字符，此时的特殊字符就是：出数字、字母、汉字以外的。
 */
-(BOOL)fjf_isSpecialLetter;
@end

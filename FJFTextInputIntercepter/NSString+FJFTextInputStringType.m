//
//  NSString+FJFTextInputStringType.m
//  FJTextInputIntercepterDemo
//
//  Created by fjf on 2018/7/4.
//  Copyright © 2018年 fjf. All rights reserved.
//


#import "NSString+FJFTextInputStringType.h"

@implementation NSString (FJFTextInputStringType)

- (BOOL)fjf_isContainStringType:(FJFTextInputStringType)stringType {
    return [self fjf_matchRegularWith:stringType];
}


- (BOOL)fjf_isContainEmoji {
    if ([self fjf_isContainStringType:FJFTextInputStringTypeEmoji]) {
        return YES;
    }
    if ([NSString fjf_stringContainsEmoji:self]) {
        return YES;
    }
    return NO;
}


#pragma mark - Private Methods

- (BOOL)fjf_matchRegularWith:(FJFTextInputStringType)type {
    NSString *regularStr = @"";
    switch (type) {
        case FJFTextInputStringTypeNumber:      //数字
            regularStr = @"^[0-9]*$";
            break;
        case FJFTextInputStringTypeLetter:      //字母
            regularStr = @"^[A-Za-z]+$";
            break;
        case FJFTextInputStringTypeChinese:     //汉字
            regularStr = @"^[\u4e00-\u9fa5]{0,}$";
            break;
        case FJFTextInputStringTypeEmoji:       //表情
            regularStr = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
            break;
        default:
            break;
    }
    NSPredicate *regextestA = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regularStr];
    
    if ([regextestA evaluateWithObject:self] == YES){
        return YES;
    }
    return NO;
}

// 是否 包含 表情
+ (BOOL)fjf_stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    if (string.length > 0) {
        [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
         ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
             const unichar hs = [substring characterAtIndex:0];
             // surrogate pair
             if (0xd800 <= hs && hs <= 0xdbff){
                 if (substring.length > 1){
                     const unichar ls = [substring characterAtIndex:1];
                     const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                     if (0x1d000 <= uc && uc <= 0x1f77f){
                         returnValue = YES;
                     }
                 }
             }
             else if (substring.length > 1){
                 const unichar ls = [substring characterAtIndex:1];
                 if (ls == 0x20e3 || ls == 0xfe0f){
                     returnValue = YES;
                 }
             }else{
                 // non surrogate
                 if (0x2100 <= hs && hs <= 0x27ff){
                     returnValue = YES;
                 }else if (0x2B05 <= hs && hs <= 0x2b07){
                     returnValue = YES;
                 }else if (0x2934 <= hs && hs <= 0x2935){
                     returnValue = YES;
                 }else if (0x3297 <= hs && hs <= 0x3299){
                     returnValue = YES;
                 }
                 else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50){
                     returnValue = YES;
                 }
             }
         }];
    }
    return returnValue;
}
@end

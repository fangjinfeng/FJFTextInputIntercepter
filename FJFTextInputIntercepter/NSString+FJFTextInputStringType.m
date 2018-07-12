//
//  NSString+FJFTextInputStringType.m
//  FJTextInputIntercepterDemo
//
//  Created by fjf on 2018/7/4.
//  Copyright © 2018年 fjf. All rights reserved.
//

#import "NSString+FJFTextInputStringType.h"

@implementation NSString (FJFTextInputStringType)

- (BOOL)fjf_isCertainStringType:(FJFTextInputStringType)stringType {
    return [self fjf_matchRegularWith:stringType];
}


- (BOOL)fjf_isSpecialLetter {
    if ([self fjf_isCertainStringType:FJFTextInputStringTypeNumber] || [self fjf_isCertainStringType:FJFTextInputStringTypeLetter] || [self fjf_isCertainStringType:FJFTextInputStringTypeChinese]) {
        return NO;
    }
    return YES;
}
#pragma mark --- 用正则判断条件
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

@end

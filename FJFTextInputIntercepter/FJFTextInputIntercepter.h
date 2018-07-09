//
//  YBInputViewIntercepter.h
//  FJTextInputIntercepterDemo
//
//  Created by fjf on 2018/7/4.
//  Copyright © 2018年 fjf. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MOATextInputIntercepter;

typedef void(^MOATextInputIntercepterBlock) (MOATextInputIntercepter *textInputIntercepter, NSString *string);

typedef NS_ENUM(NSUInteger, MOATextInputIntercepterNumberType) {
    MOATextInputIntercepterNumberTypeNone = 0,
    // 只允许 数字
    MOATextInputIntercepterNumberTypeNumberOnly,
    // 小数 (默认 两位 小数)
    MOATextInputIntercepterNumberTypeDecimal,
};


@interface MOATextInputIntercepter : NSObject <UITextFieldDelegate, UITextViewDelegate>

// maxCharacterNum 限制 最大 字符
@property (nonatomic, assign) NSUInteger maxCharacterNum;

// decimalPlaces 小数 位数 (当intercepterNumberType 为MOATextInputIntercepterNumberTypeDecimal 有用)
@property (nonatomic, assign) NSUInteger decimalPlaces;

// beyoudLimitBlock
@property (nonatomic, copy) MOATextInputIntercepterBlock beyoudLimitBlock;

// emojiAdmitted 是否 允许 表情
@property (nonatomic, assign, getter=isEmojiAdmitted)   BOOL emojiAdmitted;

// intercepterNumberType 数字 类型
@property (nonatomic, assign) MOATextInputIntercepterNumberType  intercepterNumberType;

// 不允许 输入表情 一个汉字是否代表两个字节 default YES
// 允许 输入表情 一个汉字代表3个字节 表情 代表 4个字节
@property (nonatomic, assign, getter=isDoubleBytePerChineseCharacter) BOOL doubleBytePerChineseCharacter;

- (void)textInputView:(UIView *)textInputView;

+ (MOATextInputIntercepter *)textInputView:(UIView *)textInputView beyoudLimitBlock:(MOATextInputIntercepterBlock)beyoudLimitBlock;

+ (void)textInputView:(UIView *)textInputView setInputIntercepter:(MOATextInputIntercepter *)intercepter;
@end

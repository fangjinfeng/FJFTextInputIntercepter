
//
//  FJFTextInputIntercepter.m
//  FJTextInputIntercepterDemo
//
//  Created by fjf on 2018/7/4.
//  Copyright © 2018年 fjf. All rights reserved.
//

#import "FJFTextInputIntercepter.h"
#import <objc/runtime.h>
// category
#import "NSString+FJFTextInputStringType.h"



//UITextField

@interface UITextField (FJFTextInputIntercepter)

@property (nonatomic, strong) FJFTextInputIntercepter *yb_textInputIntercepter;

@end


@implementation UITextField (FJFTextInputIntercepter)

- (void)setYb_textInputIntercepter:(FJFTextInputIntercepter *)yb_textInputIntercepter {
    objc_setAssociatedObject(self, @selector(yb_textInputIntercepter), yb_textInputIntercepter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FJFTextInputIntercepter *)yb_textInputIntercepter {
    return objc_getAssociatedObject(self, @selector(yb_textInputIntercepter));
}

@end



//UITextView

@interface UITextView (FJFTextInputIntercepter)

@property (nonatomic, strong) FJFTextInputIntercepter *yb_textInputIntercepter;

@end


@implementation UITextView (FJFTextInputIntercepter)

- (void)setYb_textInputIntercepter:(FJFTextInputIntercepter *)yb_textInputIntercepter {
    
    objc_setAssociatedObject(self, @selector(yb_textInputIntercepter), yb_textInputIntercepter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FJFTextInputIntercepter *)yb_textInputIntercepter {
    
    return objc_getAssociatedObject(self, @selector(yb_textInputIntercepter));
}

@end


@interface FJFTextInputIntercepter()
// previousText
@property (nonatomic, strong) NSString *previousText;
@end


//FJFTextInputIntercepter
@implementation FJFTextInputIntercepter

#pragma mark - Life  Circle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _emojiAdmitted = NO;
        _maxCharacterNum = UINT_MAX;
        _doubleBytePerChineseCharacter = NO;
        _intercepterNumberType = FJFTextInputIntercepterNumberTypeNone;
    }
    return self;
}


#pragma mark - Public  Methods

+ (FJFTextInputIntercepter *)textInputView:(UIView <UITextInput>*)textInputView beyoudLimitBlock:(FJFTextInputIntercepterBlock)beyoudLimitBlock {
    FJFTextInputIntercepter *tmpInputIntercepter = [[FJFTextInputIntercepter alloc] init];
    tmpInputIntercepter.beyoudLimitBlock = [beyoudLimitBlock copy];
    [self textInputView:textInputView setInputIntercepter:tmpInputIntercepter];
    return tmpInputIntercepter;
    
}


- (void)updateTextWithInputView:(UIView <UITextInput>*)inputView {
    if ([inputView isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)inputView;
        _previousText = textField.text;
        [self updateTextFieldWithTextField:textField];
        
    } else if ([inputView isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)inputView;
        _previousText = textView.text;
        [self updateTextViewWithTextView:textView];
    }
}


- (void)textInputView:(UIView <UITextInput>*)textInputView {
    [FJFTextInputIntercepter textInputView:textInputView setInputIntercepter:self];
}


+ (void)textInputView:(UIView <UITextInput>*)textInputView setInputIntercepter:(FJFTextInputIntercepter *)intercepter {
    if ([textInputView isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)textInputView;
        textField.yb_textInputIntercepter = intercepter;
        [[NSNotificationCenter defaultCenter] addObserver:intercepter
                                                 selector:@selector(textInputDidChangeWithNotification:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:textInputView];
        
    } else if ([textInputView isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)textInputView;
        textView.yb_textInputIntercepter = intercepter;
        [[NSNotificationCenter defaultCenter] addObserver:intercepter
                                                 selector:@selector(textInputDidChangeWithNotification:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:textInputView];
    }
}


- (void)updateTextViewWithTextView:(UITextView *)textView {
    NSString *inputText = textView.text;
    NSString *primaryLanguage = [textView.textInputMode primaryLanguage];

    NSInteger corsorStartPos = [textView offsetFromPosition:textView.beginningOfDocument toPosition:textView.selectedTextRange.start];
    
    // 如果 之前 文本 超出 字符限制
    if ([self isBeyondLimtWithInputText:self.previousText]) {
        textView.text = [self handleInputTextWithInputText:inputText];
        self.previousText = textView.text;
    }
    
    
    // 如果 当前字符串 小于 之前字符串(可能删除，也可能是特殊...造成)
    if (inputText.length < self.previousText.length) {
        if ([self isSpecialDotWithInputText:inputText previousText:self.previousText]) {
            NSInteger replaceTextLength =  self.previousText.length - inputText.length;
            textView.text = self.previousText;
            [FJFTextInputIntercepter cursorLocation:textView index:corsorStartPos + replaceTextLength];
        }
    }
    // 不允许 输入
    else if ([self isAllowedInputWithInputText:inputText previousText:self.previousText primaryLanguage:primaryLanguage] == false) {
        NSInteger replaceTextLength = inputText.length - self.previousText.length;
        textView.text = self.previousText;
        [FJFTextInputIntercepter cursorLocation:textView index:corsorStartPos - replaceTextLength];
    }

    
    self.previousText = textView.text;
    
    if (self.inputBlock) {
        self.inputBlock(self, textView.text);
    }
}


// 释放 是特殊的点点符号
- (BOOL)isSpecialDotWithInputText:(NSString *)inputText
                     previousText:(NSString *)previousText {
    // 如果 当前字符串 小于 之前输入字符串
    if (inputText.length < previousText.length) {
        NSString *replaceText = [self differentTextWithInputText:previousText previousText:inputText];
        if (replaceText.length > 1) {
            if (self.intercepterNumberType == FJFTextInputIntercepterNumberTypeDecimal ||
                self.intercepterNumberType == FJFTextInputIntercepterNumberTypeNumberOnly) {
                if ([inputText containsString:@"…"]) {
                    return true;
                }
            } else {
                __block BOOL isSpecialDot = true;
                [replaceText enumerateSubstringsInRange:NSMakeRange(0, replaceText.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                    if ([substring isEqualToString:@"."] == false) {
                        isSpecialDot = false;
                        *stop = true;
                    }
                }];
                return isSpecialDot;
            }
        }
    }
    return false;
}


// 更新 textField
- (void)updateTextFieldWithTextField:(UITextField *)textField {
    NSString *inputText = textField.text;

    NSInteger corsorStartPos = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    NSString *primaryLanguage = [textField.textInputMode primaryLanguage];

    // 如果 之前 文本 超出 字符限制
    if ([self isBeyondLimtWithInputText:self.previousText]) {
        textField.text = [self handleInputTextWithInputText:inputText];
        self.previousText = textField.text;
    }
    
    // 如果 当前字符串 小于 之前字符串(可能删除，也可能是特殊...造成)
    if (inputText.length < self.previousText.length) {
        if ([self isSpecialDotWithInputText:inputText previousText:self.previousText]) {
            NSInteger replaceTextLength =  self.previousText.length - inputText.length;
            textField.text = self.previousText;
            [FJFTextInputIntercepter cursorLocation:textField index:corsorStartPos + replaceTextLength];
        }
    }
    // 不允许 输入
    else if ([self isAllowedInputWithInputText:inputText previousText:self.previousText primaryLanguage:primaryLanguage] == false) {
        NSInteger replaceTextLength = inputText.length - self.previousText.length;
        textField.text = self.previousText;
        [FJFTextInputIntercepter cursorLocation:textField index:corsorStartPos - replaceTextLength];
    }
    
    self.previousText = textField.text;

    if (self.inputBlock) {
        self.inputBlock(self, textField.text);
    }
}

#pragma mark - Noti  Methods
- (void)textInputDidChangeWithNotification:(NSNotification *)noti {
    if (![((UIView *)noti.object) isFirstResponder]) {
        return;
    }
    
    BOOL textFieldTextDidChange = [noti.name isEqualToString:UITextFieldTextDidChangeNotification] &&
    [noti.object isKindOfClass:[UITextField class]];
    BOOL textViewTextDidChange = [noti.name isEqualToString:UITextViewTextDidChangeNotification] &&
    [noti.object isKindOfClass:[UITextView class]];
    if (!textFieldTextDidChange && !textViewTextDidChange) {
        return;
    }
    
    if ([noti.name isEqualToString:UITextFieldTextDidChangeNotification]) {
        [self textFieldTextDidChangeWithNotification:noti];
    } else if ([noti.name isEqualToString:UITextViewTextDidChangeNotification]) {
        [self textViewTextDidChangeWithNotification:noti];
    }
}

#pragma mark - Private  Methods

- (void)textFieldTextDidChangeWithNotification:(NSNotification *)noti {
    UITextField *textField = (UITextField *)noti.object;
    [self updateTextFieldWithTextField:textField];
}



- (void)textViewTextDidChangeWithNotification:(NSNotification *)noti {
    UITextView *textView = (UITextView *)noti.object;
    [self updateTextViewWithTextView:textView];
}


- (BOOL)isAllowedInputWithInputText:(NSString *)inputText
                       previousText:(NSString *)previousText
                    primaryLanguage:(NSString *)primaryLanguage {
    
    // 如果是删除 直接返回true
    if (inputText.length < previousText.length) {
        return true;
    }
    
    NSString *replaceText = [self differentTextWithInputText:inputText previousText:self.previousText];
    if ([self isAllowedInputWithReplaceText:replaceText previousText:previousText primaryLanguage:primaryLanguage] == false) {
        return false;
    }
    
    if ([self isBeyondLimtWithInputText:inputText]) {
        return false;
    }
    return true;
}


// 处理字符串
- (NSString *)handleInputTextWithInputText:(NSString *)inputText {
    // 允许 输入 表情 (UTF8编码 英文一个字节 汉字三个字节 表情4-6个字节
    if (self.emojiAdmitted) {
        // 调用 UTF8 编码处理 一个字符一个字节 一个汉字3个字节 一个表情4个字节
        NSUInteger textBytesLength = [inputText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        if (textBytesLength > self.maxCharacterNum) {
            NSRange range;
            NSUInteger byteLength = 0;
            NSString *text = inputText;
            for(int i = 0; i < inputText.length && byteLength <= self.maxCharacterNum; i += range.length) {
                range = [inputText rangeOfComposedCharacterSequenceAtIndex:i];
                byteLength += strlen([[text substringWithRange:range] UTF8String]);
                if (byteLength > self.maxCharacterNum) {
                    NSString* newText = [text substringWithRange:NSMakeRange(0, range.location)];
                    inputText = newText;
                }
            }
            return inputText;
        }
    }
    // 汉字两个字节(kCFStringEncodingGB_18030_2000)编码
    else if(self.isDoubleBytePerChineseCharacter) {
        // 一个字符一个字节 一个汉字2个字节
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData *data = [inputText dataUsingEncoding:encoding];
        NSInteger length = [data length];
        if (length > self.maxCharacterNum) {
            NSData *subdata = [data subdataWithRange:NSMakeRange(0, self.maxCharacterNum)];
            NSString *content = [[NSString alloc] initWithData:subdata encoding:encoding];//注意：当截取CharacterCount长度字符时把中文字符截断返回的content会是nil
            if (!content || content.length == 0) {
                subdata = [data subdataWithRange:NSMakeRange(0, self.maxCharacterNum - 1)];
                content =  [[NSString alloc] initWithData:subdata encoding:encoding];
            }
            return content;
        }
    }
    else {
        // 正常 字符 比较
        if (inputText.length > self.maxCharacterNum) {
            NSRange rangeIndex = [inputText rangeOfComposedCharacterSequenceAtIndex:self.maxCharacterNum];
            if (rangeIndex.length == 1) {
                inputText = [inputText substringToIndex:self.maxCharacterNum];
            } else {
                NSRange rangeRange = [inputText rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.maxCharacterNum)];
                inputText = [inputText substringWithRange:rangeRange];
            }
            return inputText;
        }
    }
    return inputText;
}

// 释放 超出 字符 限制
- (BOOL)isBeyondLimtWithInputText:(NSString *)inputText {
    // 允许 输入 表情 (UTF8编码 英文一个字节 汉字三个字节 表情4-6个字节
    if (self.emojiAdmitted) {
        // 调用 UTF8 编码处理 一个字符一个字节 一个汉字3个字节 一个表情4个字节
        NSUInteger textBytesLength = [inputText lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        if (textBytesLength > self.maxCharacterNum) {
            return true;
        }
    }
    // 汉字两个字节(kCFStringEncodingGB_18030_2000)编码
    else if(self.isDoubleBytePerChineseCharacter) {
        // 一个字符一个字节 一个汉字2个字节
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSData *data = [inputText dataUsingEncoding:encoding];
        NSInteger length = [data length];
        if (length > self.maxCharacterNum) {
            return true;
        }
    }
    else {
        // 正常 字符 比较
        if (inputText.length > self.maxCharacterNum) {
            return true;
        }
    }
    return false;
}



// 是否 允许 输入
- (BOOL)isAllowedInputWithReplaceText:(NSString *)replaceText
                         previousText:(NSString *)previousText
                       primaryLanguage:(NSString *)primaryLanguage {
    
    if (!replaceText.length) {
        return true;
    }
    
    // 只允许 输入 数字
    if (self.intercepterNumberType == FJFTextInputIntercepterNumberTypeNumberOnly) {
        return [replaceText fjf_isContainStringType:FJFTextInputStringTypeNumber];
    }
    // 输入 小数
    else if(self.intercepterNumberType == FJFTextInputIntercepterNumberTypeDecimal){
        NSRange tmpRange = NSMakeRange(previousText.length, 0);
        return [self inputText:previousText shouldChangeCharactersInRange:tmpRange replacementString:replaceText];

    }
    // 不允许 输入 表情 并且 不包含表情
    else if (!self.isEmojiAdmitted) {
        return ![self isContainEmojiWithReplacementText:replaceText primaryLanguage:primaryLanguage];
    }
    return true;
}

// 新添加的字符
- (NSString *)differentTextWithInputText:(NSString *)inputText
                            previousText:(NSString *)previousText {

    // 如果是删除 直接返回true
    if (inputText.length < previousText.length) {
        return @"";
    }
    
    NSString *differentText = nil;
    
    NSMutableArray <NSValue *> *inputSubMarray = [NSMutableArray array];
    NSMutableArray <NSValue *> *preSubMarray = [NSMutableArray array];

    [inputText enumerateSubstringsInRange:NSMakeRange(0, inputText.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        [inputSubMarray addObject:[NSValue valueWithRange:substringRange]];
    }];
    
    [previousText enumerateSubstringsInRange:NSMakeRange(0, previousText.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        [preSubMarray addObject:[NSValue valueWithRange:substringRange]];
    }];
    
    __block NSValue *startValue = nil;
    [inputSubMarray enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange subTextRange = [obj rangeValue];
        NSString *subText = [inputText substringWithRange:subTextRange];
        if (idx < preSubMarray.count) {
            NSRange preSubTextRange = [preSubMarray[idx] rangeValue];
            NSString *preSubText =  [previousText substringWithRange:preSubTextRange];
            if ([subText isEqualToString:preSubText] == false) {
                startValue = obj;
                *stop = true;
            }
        } else {
            startValue = obj;
            *stop = true;
        }
    }];
    
    NSRange startRange = [startValue rangeValue];
    if (startRange.location + startRange.length == inputText.length) {
        differentText = [inputText substringWithRange:startRange];
    } else {
        __block NSValue *endValue = nil;
        NSArray <NSValue *> *inputReverseSubArray = [[inputSubMarray reverseObjectEnumerator] allObjects];
        NSArray <NSValue *> *preReverseSubArray = [[preSubMarray reverseObjectEnumerator] allObjects];
        [preReverseSubArray enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange preTextRange = [obj rangeValue];
            NSString *preSubText = [previousText substringWithRange:preTextRange];
            NSValue *inputValue = inputReverseSubArray[idx];
            
            if (preTextRange.location >= startRange.location) {
                NSRange inputTextRange = [inputValue rangeValue];
                NSString *inputSubText =  [inputText substringWithRange:inputTextRange];
                if ([preSubText isEqualToString:inputSubText] == false) {
                    endValue = inputValue;
                    *stop = true;
                }
            } else {
                endValue = inputValue;
                *stop = true;
            }
        }];
        NSRange endRange = [endValue rangeValue];
        NSInteger differLength = endRange.location + endRange.length - startRange.location;
        NSRange differRange = NSMakeRange(startRange.location, differLength);
        differentText = [inputText substringWithRange:differRange];
    }
    
    return differentText;
}


+ (void)cursorLocation:(UIView <UITextInput>* )textInput index:(NSInteger)index {
    NSRange range = NSMakeRange(index, 0);
    
    UITextPosition *start = [textInput positionFromPosition:[textInput beginningOfDocument] offset:range.location];
    
    UITextPosition *end = [textInput positionFromPosition:start offset:range.length];
    
    [textInput setSelectedTextRange:[textInput textRangeFromPosition:start toPosition:end]];
}


// 是否 包含 表情
- (BOOL)isContainEmojiWithReplacementText:(NSString *)replaceText
                          primaryLanguage:(NSString *)primaryLanguage {
    if ([replaceText fjf_isContainEmoji]) {
        return YES;
    }
    if ([primaryLanguage isEqualToString:@"emoji"] ||
        primaryLanguage.length == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)inputText:(NSString *)inputText shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //    限制只能输入数字
    BOOL isHaveDian = YES;
    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    if ([inputText rangeOfString:@"."].location == NSNotFound) {
        isHaveDian = NO;
    }
    if ([string length] > 0) {
        
        unichar single = [string characterAtIndex:0];//当前输入的字符
        if ((single >= '0' && single <= '9') || single == '.') {//数据格式正确
            if(inputText.length == 0){
                if(single == '.') {
                    return NO;
                }
            }
            //输入的字符是否是小数点
            if (single == '.') {
                if(!isHaveDian)//text中还没有小数点
                {
                    isHaveDian = YES;
                    return YES;
                    
                }else{
                    return NO;
                }
            }else{
                if (isHaveDian) {//存在小数点
                    
                    //判断小数点的位数
                    NSRange ran = [inputText rangeOfString:@"."];
                    if (range.location - ran.location <= _decimalPlaces) {
                        return YES;
                    }else{
                        return NO;
                    }
                }else{
                    return YES;
                }
            }
        }else{//输入的数据格式不正确
            return NO;
        }
    }
    return YES;
}

#pragma mark -------------------------- Setter / Getter
- (void)setIntercepterNumberType:(FJFTextInputIntercepterNumberType)intercepterNumberType {
    _intercepterNumberType = intercepterNumberType;
    // 小数
    if (_intercepterNumberType == FJFTextInputIntercepterNumberTypeDecimal && (_decimalPlaces == 0)) {
        _decimalPlaces = 2;
    }
    
    if (_intercepterNumberType != FJFTextInputIntercepterNumberTypeNone) {
        _doubleBytePerChineseCharacter = NO;
    }
}
@end


# FJFTextInputIntercepter

### 简书链接:[iOS 输入框拦截器:FJFTextInputIntercepter](https://www.jianshu.com/p/e8dcaa98e6ba)

# 一. 前言

我们在项目开发中很经常会碰到各种对`输入框`的限制需求，比如`姓名`最多只能`10字符`，`密码`最多只能`16个字符`，`金额`最多`9位数`且`小数点`只能保留`两位小数`，且`不能`包含`表情`，更有甚者，可能会要求`姓名`，`中文`最多`6个字符`，`英文`最多`12个`字符。面对着各种错综复杂`输入限制`以及`不同种类`的`第三方键盘`，处理起来很经常需要写`一定量`的代码，且`处理逻辑`相对复杂。基于这样的情况，于是编写了这样一个`输入框拦截器`:[FJFTextInputIntercepter](https://github.com/fangjinfeng/FJFTextInputIntercepter)。

`FJFTextInputIntercepter拦截器`的作用就类似于你请的`家政服务`，原本你需要自己来`打扫家里`，但是现在你只需把你的`需求`告诉`家政人员`，他们会`按照`你的`需求`来进行`打扫`，最后将`打扫结果`告知你。`输入框拦截器`就类似这样的效果，你只需告诉它`输入的限制条件`，然后他就会将依据你的`限制条件`进行处理，并将`处理结果`回调给你。

这个`输入框拦截器:FJFTextInputIntercepter`使用简单，只需设置`限制条件`，然后传入需要限制的`输入框`，其他的就交给`拦截器`进行处理。


# 二.使用介绍

- **使用方法**
```
/**
设置 需要 拦截的输入框

@param textInputView 输入框
*/
- (void)textInputView:(UIView *)textInputView;


/**
设置 拦截器和拦截的输入框

@param textInputView 输入框
@param intercepter 拦截器
*/
+ (void)textInputView:(UIView *)textInputView setInputIntercepter:(FJFTextInputIntercepter *)intercepter;

/**
生成 输入框 拦截器

@param textInputView 需要限制的输入框
@param beyoudLimitBlock 超过限制 回调
@return 生成 输入框 拦截器
*/
+ (FJFTextInputIntercepter *)textInputView:(UIView *)textInputView beyoudLimitBlock:(FJFTextInputIntercepterBlock)beyoudLimitBlock;
```

**举个例子:**

`金额`输入限制:最多`9位`数，最多保留`2位`小数。

```
// moneyTextFieldView
- (FJTextFieldView *)moneyTextFieldView {
if (!_moneyTextFieldView) {
_moneyTextFieldView = [[FJTextFieldView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.cardTextFieldView.frame) + 20, [UIScreen mainScreen].bounds.size.width - 80 - 20, 44)];
_moneyTextFieldView.tipLabel.text = @"金额:";
_moneyTextFieldView.textField.placeholder = @"请输入金额(最多9位数，保留2位小数)";
FJFTextInputIntercepter *intercepter = [[FJFTextInputIntercepter alloc] init];
// 最多输入9位数
intercepter.maxCharacterNum = 9;
// 保留两位小数
intercepter.decimalPlaces = 2;
// 分数类型
intercepter.intercepterNumberType = FJFTextInputIntercepterNumberTypeDecimal;
intercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
NSLog(@"最多只能输入9位数字");
};
[intercepter textInputView:_moneyTextFieldView.textField];
}
return  _moneyTextFieldView;
}

```
**如上我们可以看到:**

我们生成了一个`FJFTextInputIntercepter拦截器实例`，然后给`实例`的属性分别添加`限制`要求，最后将`限制的输入框`传入`拦截器`，表示对此`输入框`依据`限制要求`进行`输入拦截`。

- **集成方法:**

```
静态：手动将FJFTextInputIntercepter文件夹拖入到工程中。
动态：CocoaPods：pod 'FJFTextInputIntercepter'
```

- **`github 链接`**

> **Demo地址: https://github.com/fangjinfeng/FJFTextInputIntercepter**

- **效果展示:**


![FJFTextInputIntercepter.gif](https://upload-images.jianshu.io/upload_images/2252551-fd4c48375b8eb21c.gif?imageMogr2/auto-orient/strip)


# 三. 原理分析

### 1. 原理简介

**`FJFTextInputIntercepter`只有一种调用方法就是:**

- 首先生成`拦截器实例 `:

```
FJFTextInputIntercepter *intercepter = [[FJFTextInputIntercepter alloc] init];
```

- 然后给`拦截器实例`相关属性设置`限制要求`:

```
intercepter.maxCharacterNum = 10;
intercepter.emojiAdmitted = NO;
intercepter.doubleBytePerChineseCharacter = NO;
intercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
NSLog(@"最多只能输入汉字5个字，英文10个字母");
};
```

- 最后设置`拦截对象`即需要进行`输入限制`的`输入框`:

```
[intercepter textInputView:_nameTextFieldView.textField];
```

### 2. 代码分析:

#### **属性分析:**

```
// maxCharacterNum 限制 最大 字符
@property (nonatomic, assign) NSUInteger maxCharacterNum;

// decimalPlaces 小数 位数
// (当intercepterNumberType 为FJFTextInputIntercepterNumberTypeDecimal 有用)
@property (nonatomic, assign) NSUInteger decimalPlaces;

// beyoudLimitBlock 超过限制 最大 字符数 回调
@property (nonatomic, copy) FJFTextInputIntercepterBlock beyoudLimitBlock;

// emojiAdmitted 是否 允许 输入 表情
@property (nonatomic, assign, getter=isEmojiAdmitted)   BOOL emojiAdmitted;

// intercepterNumberType 数字 类型
// FJFTextInputIntercepterNumberTypeNone 默认
// FJFTextInputIntercepterNumberTypeNumberOnly 只允许 输入 数字，emojiAdmitted，decimalPlaces 不起作用
// FJFTextInputIntercepterNumberTypeDecimal 分数 emojiAdmitted 不起作用 decimalPlaces 小数 位数
@property (nonatomic, assign) FJFTextInputIntercepterNumberType  intercepterNumberType;

/**
doubleBytePerChineseCharacter 为 NO
字母、数字、汉字都是1个字节 表情是两个字节
doubleBytePerChineseCharacter 为 YES
不允许 输入表情 一个汉字是否代表两个字节 default YES
允许 输入表情 一个汉字代表3个字节 表情 代表 4个字节
*/
@property (nonatomic, assign, getter=isDoubleBytePerChineseCharacter) BOOL doubleBytePerChineseCharacter;
```
`属性功能`如`注释`所示，`拦截器`默认设置如下`属性`:
```
_emojiAdmitted = NO;
_maxCharacterNum = UINT_MAX;
_doubleBytePerChineseCharacter = NO;
_intercepterNumberType = FJFTextInputIntercepterNumberTypeNone;
```
默认`不允许输入表情`、`不限制最大输入字符数`、`汉字`和`字符`同样`一个字节`、`表情两个字节`、`不设置数字类型`。

#### **限制逻辑分析:**

- A. **调用公共方法:**

```
#pragma mark -------------------------- Public  Methods

- (void)textInputView:(UIView *)textInputView {
[FJFTextInputIntercepter textInputView:textInputView setInputIntercepter:self];
}


+ (FJFTextInputIntercepter *)textInputView:(UIView *)textInputView beyoudLimitBlock:(FJFTextInputIntercepterBlock)beyoudLimitBlock {
FJFTextInputIntercepter *tmpInputIntercepter = [[FJFTextInputIntercepter alloc] init];
tmpInputIntercepter.beyoudLimitBlock = [beyoudLimitBlock copy];
[self textInputView:textInputView setInputIntercepter:tmpInputIntercepter];
return tmpInputIntercepter;

}


+ (void)textInputView:(UIView *)textInputView setInputIntercepter:(FJFTextInputIntercepter *)intercepter {

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
```

从代码中我们可以看出最后都会走:
```
+ (void)textInputView:(UIView *)textInputView setInputIntercepter:(FJFTextInputIntercepter *)intercepter
```
类方法，这里对`输入框类型`进行了判断，并设置将`拦截器`和`输入框`关联在一起，保证`拦截器`的`生命周期`和`输入框`一致，同时`注册`了`文本改变`的`通知`。

- B. **文本改变通知:**
```
#pragma mark -------------------------- Noti  Methods
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
```
该函数主要对是否为`当前第一响应者`和`通知名称`是否匹配进行判断，然后`调用输入框类型`对应的`通知处理方法`。

- **C. 输入框类型通知处理方法**:

```
#pragma mark -------------------------- Private  Methods

- (void)textFieldTextDidChangeWithNotification:(NSNotification *)noti {

UITextField *textField = (UITextField *)noti.object;
NSString *inputText = textField.text;
NSString *primaryLanguage = [textField.textInputMode primaryLanguage];
//获取高亮部分
UITextRange *selectedRange = [textField markedTextRange];
UITextPosition *textPosition = [textField positionFromPosition:selectedRange.start
offset:0];

inputText = [self handleWithInputText:inputText];

NSString *finalText = [self finalTextAfterProcessingWithInput:inputText
maxCharacterNum:self.maxCharacterNum
primaryLanguage:primaryLanguage
textPosition:textPosition
isDoubleBytePerChineseCharacter:self.isDoubleBytePerChineseCharacter];
if (finalText.length > 0) {
textField.text = finalText;
}
else if(self.intercepterNumberType == FJFTextInputIntercepterNumberTypeNumberOnly ||
self.intercepterNumberType == FJFTextInputIntercepterNumberTypeDecimal ||
self.isEmojiAdmitted == NO){
textField.text = inputText;
}
_previousText = textField.text;
}

- (void)textViewTextDidChangeWithNotification:(NSNotification *)noti {

UITextView *textView = (UITextView *)noti.object;
NSString *inputText = textView.text;
NSString *primaryLanguage = [textView.textInputMode primaryLanguage];
//获取高亮部分
UITextRange *selectedRange = [textView markedTextRange];
UITextPosition *textPosition = [textView positionFromPosition:selectedRange.start
offset:0];

inputText = [self handleWithInputText:inputText];

NSString *finalText = [self finalTextAfterProcessingWithInput:inputText
maxCharacterNum:self.maxCharacterNum
primaryLanguage:primaryLanguage
textPosition:textPosition
isDoubleBytePerChineseCharacter:self.isDoubleBytePerChineseCharacter];

if (finalText.length > 0) {
textView.text = finalText;
}

_previousText = textView.text;
}
```
`通知处理方法`内部分别获取`当前语言类型`、和`高亮部分`，然后调用`输入文本的处理方法:handleWithInputText`和`最大输入字符的截取方法:finalTextAfterProcessingWithInput`。

- **D. 在`输入文本的处理方法:handleWithInputText`中分别对`只能输入数字`、`输入分数`和`是否允许输入表情`进行处理.**

```
// 处理 输入 字符串
- (NSString *)handleWithInputText:(NSString *)inputText {
if (_previousText.length >= inputText.length) {
return inputText;
}

NSString *tmpReplacementString = [inputText substringWithRange:NSMakeRange(_previousText.length, (inputText.length - _previousText.length))];
// 只允许 输入 数字
if (self.intercepterNumberType == FJFTextInputIntercepterNumberTypeNumberOnly) {
if ([tmpReplacementString fjf_isCertainStringType:FJFTextInputStringTypeNumber] == NO) {
inputText = _previousText;
}
}
// 输入 小数
else if(self.intercepterNumberType == FJFTextInputIntercepterNumberTypeDecimal){
NSRange tmpRange = NSMakeRange(_previousText.length, 0);
BOOL isCorrect = [self inputText:_previousText shouldChangeCharactersInRange:tmpRange replacementString:tmpReplacementString];
if (isCorrect == YES) {
if (inputText.length == self.maxCharacterNum && [tmpReplacementString isEqualToString:@"."]) {
inputText = _previousText;
}
}
else {
inputText = _previousText;
}
}
// 不允许 输入 表情
else if (!self.isEmojiAdmitted && [tmpReplacementString fjf_isSpecialLetter]) {
inputText =  _previousText;
}

return inputText;
}
```

- **F. 在`finalTextAfterProcessingWithInput`函数中依据是否为`中文输入法`来分别进行处理**
```
// 核心代码
- (NSString *)finalTextAfterProcessingWithInput:(NSString *)inputText
maxCharacterNum:(NSUInteger)maxCharacterNum
primaryLanguage:(NSString *)primaryLanguage
textPosition:(UITextPosition *)textPosition
isDoubleBytePerChineseCharacter:(BOOL)isDoubleBytePerChineseCharacter {



NSString *finalText = nil;
if ([primaryLanguage isEqualToString:@"zh-Hans"] ||
[primaryLanguage isEqualToString:@"zh-Hant"]) { // 简繁体中文输入
// 没有高亮选择的字，则对已输入的文字进行字数统计和限制
if (!textPosition) {
finalText = [self processingTextWithInput:inputText
maxCharacterNum:maxCharacterNum
isDoubleBytePerChineseCharacter:isDoubleBytePerChineseCharacter];
}

} else { // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
finalText = [self processingTextWithInput:inputText
maxCharacterNum:maxCharacterNum
isDoubleBytePerChineseCharacter:isDoubleBytePerChineseCharacter];
}

return finalText;
}
```
这段代码里面判断了是否为`简繁体中文输入`，如果`不是简繁体中文输入`，直接调用`processingTextWithInput方法`对`已输入的文字`进行`字数`和`统计`的限制，如果是`简繁体中文输入`，判断是否为`高亮选择`的字，`如果不是高亮选择`的字，对`已输入的文字`进行`字数`和`统计的限制`。

- **G. `processingTextWithInput` 依据是否`一个汉字对应两个字节`来分别进行处理**
```
- (NSString *)processingTextWithInput:(NSString *)inputText
maxCharacterNum:(NSUInteger)maxCharacterNum
isDoubleBytePerChineseCharacter:(BOOL)isDoubleBytePerChineseCharacter {

NSString *processingText = nil;

if (isDoubleBytePerChineseCharacter) { //如果一个汉字是双字节
processingText = [self doubleBytePerChineseCharacterSubString:inputText
maxCharacterNum:maxCharacterNum];
} else {
if (inputText.length > maxCharacterNum) {
NSRange rangeIndex = [inputText rangeOfComposedCharacterSequenceAtIndex:maxCharacterNum];
if (rangeIndex.length == 1) {
processingText = [inputText substringToIndex:maxCharacterNum];
} else {
NSRange rangeRange = [inputText rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxCharacterNum)];
processingText = [inputText substringWithRange:rangeRange];
}
if (self.beyoudLimitBlock) {
self.beyoudLimitBlock(self, processingText);
}
}
}
return processingText;
}
```

该函数判断如果`一个汉字`是`双字节`，就调用`doubleBytePerChineseCharacterSubString`依据`是否允许输入表情`，调用不同的`编码方式`进行处理。如果`一个汉字是一个字节`，直接进行`最大字符截取`。

# 四. 总结

综上所述就是`FJFTextInputIntercepter`这个`输入框`的一个`设计思路`，`核心代码量差不多400行左右，能应对大部分的`输入框要求`，使用简单。


![image.png](https://upload-images.jianshu.io/upload_images/2252551-941fb2ac8066c86e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


**如果你觉得你觉得这思路或是代码有什么问题，欢迎留言大家讨论下！如果觉得不错，麻烦给个喜欢或star,谢谢！**


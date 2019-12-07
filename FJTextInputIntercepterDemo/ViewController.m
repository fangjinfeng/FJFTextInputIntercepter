//
//  ViewController.m
//  FJTextInputIntercepterDemo
//
//  Created by fjf on 2018/7/4.
//  Copyright © 2018年 fjf. All rights reserved.
//

// tool
#import "FJFTextInputIntercepter.h"
// view
#import "FJTextFieldView.h"
// vc
#import "ViewController.h"
// tool
#import "FJFTextView.h"
#import "FJFKeyboardHelper.h"

@interface ViewController ()

// nameTextFieldView
@property (nonatomic, strong) FJTextFieldView *nameTextFieldView;
// cardTextFieldView
@property (nonatomic, strong) FJTextFieldView *cardTextFieldView;
// moneyTextFieldView
@property (nonatomic, strong) FJTextFieldView *moneyTextFieldView;
// accountTextField
@property (nonatomic, strong) FJTextFieldView *accountTextFieldView;
// passwordTextField
@property (nonatomic, strong) FJTextFieldView *passwordTextFieldView;
// introductionTextView
@property (nonatomic, strong) FJFTextView *introductionTextView;
@end

@implementation ViewController

#pragma mark -------------------------- Life  Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewControls];
}


#pragma mark -------------------------- Private Methods
- (void)setupViewControls {
    [self.view addSubview:self.nameTextFieldView];
    [self.view addSubview:self.cardTextFieldView];
    [self.view addSubview:self.moneyTextFieldView];
    [self.view addSubview:self.accountTextFieldView];
    [self.view addSubview:self.passwordTextFieldView];
    [self.view addSubview:self.introductionTextView];
    [FJFKeyboardHelper handleKeyboardWithContainerView:self.view];
}


#pragma mark -------------------------- Setter  /  Getter

// cardTextFieldView
- (FJTextFieldView *)nameTextFieldView {
    if (!_nameTextFieldView) {
        _nameTextFieldView = [[FJTextFieldView alloc] initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width - 80 - 20, 44)];
        _nameTextFieldView.tipLabel.text = @"姓名:";
        _nameTextFieldView.textField.placeholder = @"请输入姓名(汉字5个字，英文10个字母)";
        FJFTextInputIntercepter *intercepter = [[FJFTextInputIntercepter alloc] init];
        intercepter.maxCharacterNum = 10;
        intercepter.emojiAdmitted = NO;
        intercepter.doubleBytePerChineseCharacter = YES;
        intercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
            NSLog(@"最多只能输入汉字5个字，英文10个字母");
        };
        [intercepter textInputView:_nameTextFieldView.textField];
    }
    return  _nameTextFieldView;
}


// cardTextFieldView
- (FJTextFieldView *)cardTextFieldView {
    if (!_cardTextFieldView) {
        _cardTextFieldView = [[FJTextFieldView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.nameTextFieldView.frame) + 20, [UIScreen mainScreen].bounds.size.width - 80 - 20, 44)];
        _cardTextFieldView.tipLabel.text = @"卡号:";
        _cardTextFieldView.textField.placeholder = @"请输入卡号(只限数字)";
        FJFTextInputIntercepter *intercepter = [[FJFTextInputIntercepter alloc] init];
        intercepter.maxCharacterNum = 16;
        intercepter.intercepterNumberType = FJFTextInputIntercepterNumberTypeNumberOnly;
        intercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
            NSLog(@"最多只能输入16位卡号");
        };
        [intercepter textInputView:_cardTextFieldView.textField];
    }
    return  _cardTextFieldView;
}



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


// accountTextFieldView
- (FJTextFieldView *)accountTextFieldView {
    if (!_accountTextFieldView) {
        _accountTextFieldView = [[FJTextFieldView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.moneyTextFieldView.frame) + 20, [UIScreen mainScreen].bounds.size.width - 80 - 20, 44)];
        _accountTextFieldView.textField.placeholder = @"请输入您的账号";
        FJFTextInputIntercepter *intercepter = [[FJFTextInputIntercepter alloc] init];
        intercepter.maxCharacterNum = 16.0f;
        intercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
            NSLog(@"最多只能输入16位账号");
        };
         [intercepter textInputView:_accountTextFieldView.textField];
    }
    return  _accountTextFieldView;
}


// passwordTextField
- (FJTextFieldView *)passwordTextFieldView {
    if (!_passwordTextFieldView) {
        _passwordTextFieldView = [[FJTextFieldView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.accountTextFieldView.frame) + 20, [UIScreen mainScreen].bounds.size.width - 80 - 20, 44)];
        _passwordTextFieldView.tipLabel.text = @"密码:";
        _passwordTextFieldView.textField.placeholder = @"请输入您的密码";
        _passwordTextFieldView.textField.secureTextEntry = YES;
        FJFTextInputIntercepter *intercepter = [[FJFTextInputIntercepter alloc] init];
        intercepter.maxCharacterNum = 16;
        intercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
            NSLog(@"最多只能输入16位密码");
        };
       [FJFTextInputIntercepter textInputView:_passwordTextFieldView.textField setInputIntercepter:intercepter];
    }
    return  _passwordTextFieldView;
}

// introductionTextView 个人简介
- (FJFTextView *)introductionTextView {
    if (!_introductionTextView) {
        _introductionTextView = [[FJFTextView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.passwordTextFieldView.frame) + 20, [UIScreen mainScreen].bounds.size.width - 40, 120)];
        _introductionTextView.placeholder = @"请输入100字以内的个人简介";
        _introductionTextView.font = [UIFont systemFontOfSize:14.0f];;
        _introductionTextView.textColor = [UIColor colorWithRed:30/255.0f green:30/255.0f blue:30/255.0f alpha:1.0f];;
        _introductionTextView.tintColor = [UIColor colorWithRed:255/255.0f green:107/255.0f blue:0/255.0f alpha:1.0f];;
        _introductionTextView.textContainer.lineFragmentPadding = 0.0;
        FJFTextInputIntercepter *textInputIntercepter = [[FJFTextInputIntercepter alloc] init];
        textInputIntercepter.maxCharacterNum = 100;
        textInputIntercepter.emojiAdmitted = NO;
        textInputIntercepter.doubleBytePerChineseCharacter = YES;
        textInputIntercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
            NSLog(@"中文50个字符，英文或字母100个字符");
        };
        [textInputIntercepter textInputView:_introductionTextView];
    }

    return _introductionTextView;
}
@end

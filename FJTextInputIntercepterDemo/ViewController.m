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
        intercepter.doubleBytePerChineseCharacter = NO;
        intercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
            NSLog(@"最多只能输入汉字5个字，英文10个字母");
        };
        [FJFTextInputIntercepter textInputView:_nameTextFieldView.textField setInputIntercepter:intercepter];
    }
    return  _nameTextFieldView;
}


// cardTextFieldView
- (FJTextFieldView *)cardTextFieldView {
    if (!_cardTextFieldView) {
        _cardTextFieldView = [[FJTextFieldView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.nameTextFieldView.frame) + 20, [UIScreen mainScreen].bounds.size.width - 80 - 20, 44)];
        _cardTextFieldView.tipLabel.text = @"卡号:";
        _cardTextFieldView.textField.placeholder = @"请输入卡号";
        FJFTextInputIntercepter *intercepter = [[FJFTextInputIntercepter alloc] init];
        intercepter.maxCharacterNum = 16;
        intercepter.intercepterNumberType = FJFTextInputIntercepterNumberTypeNumberOnly;
        intercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
            NSLog(@"最多只能输入16位卡号");
        };
        [FJFTextInputIntercepter textInputView:_cardTextFieldView.textField setInputIntercepter:intercepter];
    }
    return  _cardTextFieldView;
}



// moneyTextFieldView
- (FJTextFieldView *)moneyTextFieldView {
    if (!_moneyTextFieldView) {
        _moneyTextFieldView = [[FJTextFieldView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.cardTextFieldView.frame) + 20, [UIScreen mainScreen].bounds.size.width - 80 - 20, 44)];
        _moneyTextFieldView.tipLabel.text = @"金额:";
        _moneyTextFieldView.textField.placeholder = @"请输入金额";
        FJFTextInputIntercepter *intercepter = [[FJFTextInputIntercepter alloc] init];
        intercepter.maxCharacterNum = 9;
        intercepter.decimalPlaces = 3;
        intercepter.intercepterNumberType = FJFTextInputIntercepterNumberTypeDecimal;
        intercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
            NSLog(@"最多只能输入9位数字");
        };
        [FJFTextInputIntercepter textInputView:_moneyTextFieldView.textField setInputIntercepter:intercepter];
    }
    return  _moneyTextFieldView;
}


// accountTextFieldView
- (FJTextFieldView *)accountTextFieldView {
    if (!_accountTextFieldView) {
        _accountTextFieldView = [[FJTextFieldView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.moneyTextFieldView.frame) + 20, [UIScreen mainScreen].bounds.size.width - 80 - 20, 44)];
        _accountTextFieldView.textField.placeholder = @"请输入您的账号";
        FJFTextInputIntercepter *intercepter = [[FJFTextInputIntercepter alloc] init];
        intercepter.emojiAdmitted = NO;
        intercepter.maxCharacterNum = 16.0f;
        intercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
            NSLog(@"最多只能输入16位账号");
        };
        [FJFTextInputIntercepter textInputView:_accountTextFieldView.textField setInputIntercepter:intercepter];
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
        intercepter.maxCharacterNum = 16.0f;
        intercepter.beyoudLimitBlock = ^(FJFTextInputIntercepter *textInputIntercepter, NSString *string) {
            NSLog(@"最多只能输入16位密码");
        };
       [FJFTextInputIntercepter textInputView:_passwordTextFieldView.textField setInputIntercepter:intercepter];
    }
    return  _passwordTextFieldView;
}
@end

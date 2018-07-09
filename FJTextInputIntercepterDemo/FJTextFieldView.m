


//
//  FJTextFieldView.m
//  FJTextInputIntercepterDemo
//
//  Created by fjf on 2018/7/5.
//  Copyright © 2018年 fjf. All rights reserved.
//

#import "FJTextFieldView.h"

@implementation FJTextFieldView

#pragma mark -------------------------- Life  Circle

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupViewControls];
        [self layoutViewControls];
    }
    return self;
}

#pragma mark -------------------------- Private Methods

- (void)setupViewControls {
    [self addSubview:self.tipLabel];
    [self addSubview:self.textField];
}

- (void)layoutViewControls {
    
}

#pragma mark -------------------------- Setter / Getter
// tipLabel
- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, CGRectGetMinY(self.textField.frame), 50, 44)];
        _tipLabel.textAlignment = NSTextAlignmentLeft;
        _tipLabel.text = @"账号:";
    }
    return  _tipLabel;
}


// textField
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(60, 0, [UIScreen mainScreen].bounds.size.width - 80 - 20, 44)];
    }
    return  _textField;
}

@end

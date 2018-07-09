//
//  NSString+YBEmoji.h
//  FJTextInputIntercepterDemo
//
//  Created by fjf on 2018/7/4.
//  Copyright © 2018年 fjf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FJFTextInputEmoji)

+ (BOOL)moa_textInputStringContainsEmoji:(NSString *)string;
+ (NSString *)moa_textInputFilterEmoji:(NSString *)string;
@end

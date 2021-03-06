
//
//  MOAKeyboardManager.m
//  FJDesignDemo
//
//  Created by fjf on 2018/6/1.
//  Copyright © 2018年 sangfor. All rights reserved.
//

#import "FJFKeyboardHelper.h"
#import "UIView+FJFKeyboardHelper.h"
#import "UIResponder+FJFKeyboardFirstResponder.h"
#import "UIViewController+FJFKeyboardCurrentViewController.h"

static CGFloat kContentOffsetPaddingY = 5.0f;

@interface FJFKeyboardHelper()
// containerView
@property (nonatomic, weak) UIView *containerView;
// scrollView
@property (nonatomic, weak) UIScrollView *scrollView;
// oldContainerViewFrame
@property (nonatomic, assign) CGRect oldContainerViewFrame;
// contentOffsetPaddingY
@property (nonatomic, assign) CGFloat  contentOffsetPaddingY;
// currentContainerViewFrame
@property (nonatomic, assign) CGRect  currentContainerViewFrame;
// associatedView
@property (nonatomic, strong) UIView *associatedView;
// keyboardShowBlock
@property (nonatomic, copy) FJFKeyboardManagerBlock keyboardShowBlock;
// keyboardHideBlock
@property (nonatomic, copy) FJFKeyboardManagerBlock keyboardHideBlock;
// tapGestureRecognizer
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation FJFKeyboardHelper

#pragma mark -------------------------- Life Circle
- (void)dealloc {
    [self removeKeyboardNotiObserver];
}

- (instancetype)init {
    if (self = [super init]) {
        _responseTapGesture = YES;
        _oldContainerViewFrame = CGRectZero;
        _currentContainerViewFrame = CGRectZero;
        _contentOffsetPaddingY = kContentOffsetPaddingY;
        [self addKeyboardNotiObserver];
    }
    return self;
}

#pragma mark -------------------------- Public Methods

// 移除 键盘 管理器
- (void)removeKeyboardHelper {
    [self.associatedView fjf_removeKeyboardHelper];
}

// 更新 键盘 和 响应者 间距
- (void)updateKeyboardTofirstResponderSpacing:(CGFloat)spacing {
    self.contentOffsetPaddingY = spacing;
}

+ (FJFKeyboardHelper *)handleKeyboardWithContainerView:(UIView *)containerView {
    FJFKeyboardHelper *helper = [[FJFKeyboardHelper alloc] init];
    [helper handleKeyboardWithContainerView:containerView];
    [containerView fjf_setKeyboardHelper:helper];
    helper.associatedView = containerView;
    return helper;
}

+ (FJFKeyboardHelper *)handleKeyboardWithScrollView:(UIScrollView *)scrollView {
    FJFKeyboardHelper *helper = [[FJFKeyboardHelper alloc] init];
    [helper handleKeyboardWithScrollView:scrollView];
    [scrollView fjf_setKeyboardHelper:helper];
    helper.associatedView = scrollView;
    return helper;
}


+ (FJFKeyboardHelper *)handleKeyboardWithShowBlock:(FJFKeyboardManagerBlock)showBlock hideBlock:(FJFKeyboardManagerBlock)hideBlock {
    FJFKeyboardHelper *helper = [[FJFKeyboardHelper alloc] init];
    [helper handleKeyboardWithShowBlock:showBlock hideBlock:hideBlock];
    [[UIViewController fjf_keyboardCurrentViewController].view fjf_setKeyboardHelper:helper];
    helper.associatedView = [UIViewController fjf_keyboardCurrentViewController].view;
    return helper;
}

#pragma mark -------------------------- Private Methods

- (void)addKeyboardNotiObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

// 移除 键盘 通知 监听
- (void)removeKeyboardNotiObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleKeyboardWithShowBlock:(FJFKeyboardManagerBlock)showBlock hideBlock:(FJFKeyboardManagerBlock)hideBlock {
    _keyboardShowBlock = [showBlock copy];
    _keyboardHideBlock = [hideBlock copy];
}


- (void)handleKeyboardWithScrollView:(UIScrollView *)scrollView {
    if ([scrollView isKindOfClass:[UIScrollView class]]) {
        _scrollView = scrollView;
    }
    
    NSAssert([scrollView isKindOfClass:[UIScrollView class]], @"scrollView 必现是 UIScrollView类型");
}


- (void)handleKeyboardWithContainerView:(UIView *)containerView {
    if ([containerView isKindOfClass:[UIView class]]) {
        _containerView = containerView;
    }
    
    NSAssert([containerView isKindOfClass:[UIView class]], @"containerView 必现是 UIView类型");
}


#pragma mark --------------- Noti Methods
//  键盘 显示
- (void)keyBoardWillShow:(NSNotification *)noti {
    if ([noti.name isEqualToString:UIKeyboardWillShowNotification]) {

        NSDictionary *keyBordInfo = [noti userInfo];
        
        NSValue *value = [keyBordInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        
        CGRect keyBoardRect = [value CGRectValue];
        
        CGRect beginRect = [[keyBordInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        
        CGRect endRect = [[keyBordInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        if (CGRectEqualToRect(_oldContainerViewFrame, CGRectZero)) {
            _oldContainerViewFrame = _containerView.frame;
        }
         _currentContainerViewFrame = _containerView.frame;
        
        // 第三方键盘回调三次问题，监听仅执行最后一次
        if(endRect.size.height > 0 && (beginRect.origin.y - endRect.origin.y > 0)){
           
            // 有回调
            if (self.keyboardShowBlock) {
                self.keyboardShowBlock(noti.name, noti.userInfo, keyBoardRect);
            }
            // 无回调
            else {
                UIView *tmpView = [UIResponder fjf_keyboardCurrentFirstResponder];
                if ([tmpView isKindOfClass:[UIView class]]) {
                    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
                    CGRect rect = [tmpView convertRect:tmpView.bounds toView:window];
                    CGFloat viewBottomHeight =  [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(rect);
                    if (viewBottomHeight < 0) {
                        viewBottomHeight = 0;
                    }
                    CGFloat viewBottomOffset = keyBoardRect.size.height - viewBottomHeight;
                    NSString *durationValue = [keyBordInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
                    if (viewBottomOffset > 0 ) {
                       
                        // 列表
                        if (_scrollView) {
                            CGFloat contentOffsetY = self.scrollView.contentOffset.y +  viewBottomOffset + _contentOffsetPaddingY;
                            [UIView animateWithDuration:durationValue.floatValue animations:^{
                                self.scrollView.contentOffset = CGPointMake(0, contentOffsetY);
                            }];
                        }
                        // 非列表
                        else if(_containerView){
                            CGFloat contentOffsetY = _currentContainerViewFrame.origin.y - viewBottomOffset - _contentOffsetPaddingY;
                            [UIView animateWithDuration:durationValue.floatValue animations:^{
                                self.containerView.frame  = CGRectMake(self.currentContainerViewFrame.origin.x, contentOffsetY, self.currentContainerViewFrame.size.width, self.currentContainerViewFrame.size.height);
                            }];
                        }
                    }
                }
            }
        }
        [self addTapGustureRecognizer];
    }
}


// 键盘 隐藏
- (void)keyBoardWillHide:(NSNotification *)noti {
    if ([noti.name isEqualToString:UIKeyboardWillHideNotification]) {
        NSDictionary *keyBordInfo = [noti userInfo];
        
        NSValue *value = [keyBordInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        
        CGRect keyBoardRect = [value CGRectValue];
        // 有回调
        if (self.keyboardHideBlock) {
            self.keyboardHideBlock(noti.name, noti.userInfo, keyBoardRect);
        }
        // 无回调
        else {
            // 非列表
             NSString *durationValue = [keyBordInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
            if(_containerView){
                [UIView animateWithDuration:durationValue.floatValue animations:^{
                    self.containerView.frame  = self.oldContainerViewFrame;
                    self.oldContainerViewFrame = CGRectZero;
                }];
            }
        }
        [self removeTapGestureRecognizer];
    }
}

#pragma mark - Response Event
- (void)endEdit {
    [self.associatedView endEditing:YES];
}


#pragma mark - Private Methods
- (void)addTapGustureRecognizer {
    if (self.responseTapGesture) {
        UIView *responseView = [FJFKeyboardHelper currentFirstResponder];
        if ([FJFKeyboardHelper isTextEditViewWithResponseView:responseView]) {
            UITextField *textField = (UITextField *)responseView;
            if (textField.window) {
               [textField.window addGestureRecognizer:self.tapGestureRecognizer];
            }
        }
    }
}

// 移除 点击 手势
- (void)removeTapGestureRecognizer {
    if (self.responseTapGesture) {
        UIView *responseView = [FJFKeyboardHelper currentFirstResponder];
        if ([FJFKeyboardHelper isTextEditViewWithResponseView:responseView]) {
           UITextField *textField = (UITextField *)responseView;
           if (textField.window) {
              [textField.window removeGestureRecognizer:self.tapGestureRecognizer];
           }
        }
    }
}

#pragma mark - Setter / Getter

+ (BOOL)isTextEditViewWithResponseView:(UIView *)responseView {
    if ([responseView isKindOfClass:[UITextField class]] ||
        [responseView isKindOfClass:[UITextView class]]) {
        return YES;
    }
    return NO;
}


+ (UIView *)currentFirstResponder {
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    return firstResponder;
}


- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)];
    }
    return _tapGestureRecognizer;
}
@end

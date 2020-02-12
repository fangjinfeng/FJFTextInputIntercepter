//
//  ViewController.m
//  FJTextInputIntercepterDemo
//
//  Created by fjf on 2018/7/4.
//  Copyright © 2018年 fjf. All rights reserved.
//

// vc
#import "ViewController.h"
#import "FJFPersonalDescEditViewController.h"
#import "FJFPersonalInfomationEditViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
// tableView
@property (nonatomic, strong) UITableView *tableView;
// viewControllerDict
@property (nonatomic, strong) NSDictionary <NSString *, NSString *> *viewControllerDict;
@end

@implementation ViewController

#pragma mark - Life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"例子";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

#pragma mark - System Delegate

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewControllerDict.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSArray *keyArray = [self.viewControllerDict allKeys];
    cell.textLabel.text = [self.viewControllerDict objectForKey:keyArray[indexPath.row]];
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
     NSArray *keyArray = [self.viewControllerDict allKeys];
    NSString *className = keyArray[indexPath.row];
    id class = [[NSClassFromString(className) alloc] init];
    [self.navigationController pushViewController:class animated:YES];
}


#pragma mark - Setter / Getter

// tableView
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width ,self.view.frame.size.height - 64.0f) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

// viewControllerDict
- (NSDictionary <NSString *, NSString *> *)viewControllerDict {
    if (!_viewControllerDict) {
        _viewControllerDict = @{
                                @"FJFPersonalDescEditViewController": @"修改个人简介",
                                @"FJFPersonalInfomationEditViewController": @"修改个人信息",
                                };
    }
    return _viewControllerDict;
}
@end

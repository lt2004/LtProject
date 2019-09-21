//
//  XTCBaseNavigationController.m
//  XTCAlbum
//
//  Created by Xie Shu on 2018/5/2.
//  Copyright © 2018年 漫漫. All rights reserved.
//

#import "XTCBaseNavigationController.h"

@interface XTCBaseNavigationController ()

@end

@implementation XTCBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    id target = self.interactivePopGestureRecognizer.delegate;
    SEL handler = NSSelectorFromString(@"handleNavigationTransition:");
    UIView *targetView = self.interactivePopGestureRecognizer.view;
    UIPanGestureRecognizer * fullScreenGes = [[UIPanGestureRecognizer alloc]initWithTarget:target action:handler];
    fullScreenGes.delegate = self;
    [targetView addGestureRecognizer:fullScreenGes];
    // 关闭边缘触发手势 防止和原有边缘手势冲突
    [self.interactivePopGestureRecognizer setEnabled:NO];
}

//  防止导航控制器只有一个rootViewcontroller时触发手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //解决与左滑手势冲突
    UIPanGestureRecognizer *panGes = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint translation = [panGes translationInView:panGes.view];
    if (translation.x <= 0) {
        return NO;
    }
    // 过滤执行过渡动画时的手势处理
    if ([[self valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    if (self.childViewControllers.count == 1) {
        
    } else {
        // 手势返回
        
    }
    return self.childViewControllers.count == 1 ? NO : YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  CustomViewControllerTransition.m
//  转场动画
//
//  Created by 霍文轩 on 15/10/30.
//  Copyright © 2015年 霍文轩. All rights reserved.
//

#import "PresentTransition.h"
#import "XTCPublishPickerViewController.h"

@interface PresentTransition()
@end

@implementation PresentTransition
// 返回动画的时间
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.8;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext{
//    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    XTCPublishPickerViewController * toView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    //2 再得到过渡的容器View 用于在动画中呈现出toView
    UIView * containerView = [transitionContext containerView];
    //toView.alpha = 0;//将目标视图加入到转场容器中使其透明
    [containerView addSubview:toView.view];
    
    
    //3 接下来设置要呈现出来的View的大小等属性
    CATransform3D toViewTransform = toView.view.layer.transform;
    toViewTransform = CATransform3DScale(toViewTransform, 0.8, 0.8, 1);
    toView.view.layer.transform = toViewTransform;
    
    CGRect rect = toView.view.frame;
    toView.view.frame = rect;
    // initialSpringVelocity回弹
    [UIView animateWithDuration:0.95 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CATransform3D toViewTransform = toView.view.layer.transform;
        // 通过之前设置的位置或大小 等在这里改变位置 大小等来显示动画效果
        toViewTransform = CATransform3DScale(toViewTransform, 1.249999, 1.249999, 1);
        toView.view.layer.transform = toViewTransform;
    } completion:^(BOOL finished) {
        //动画结束 转场结束
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end

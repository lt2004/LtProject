//
//  YBIBToolViewHandler.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/7.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBToolViewHandler.h"
#import "YBIBCopywriter.h"
#import "YBIBUtilities.h"



@interface YBIBToolViewHandler ()
@property (nonatomic, strong) YBIBSheetView *sheetView;

@property (nonatomic, strong) YBIBSheetAction *saveAction;
@property (nonatomic, strong) YBIBSheetAction *deleteAction;
@property (nonatomic, strong) YBIBSheetAction *moveAction;
@property (nonatomic, strong) YBIBSheetAction *shareAction;
@property (nonatomic, strong) YBIBSheetAction *lockAction;



@property (nonatomic, strong) YBIBTopView *topView;
@end

@implementation YBIBToolViewHandler

#pragma mark - <YBIBToolViewHandler>

@synthesize yb_containerView = _yb_containerView;
@synthesize yb_containerSize = _yb_containerSize;
@synthesize yb_currentPage = _yb_currentPage;
@synthesize yb_totalPage = _yb_totalPage;
@synthesize yb_currentOrientation = _yb_currentOrientation;
@synthesize yb_currentData = _yb_currentData;

- (void)yb_containerViewIsReadied {
    [self.yb_containerView addSubview:self.topView];
    [self.yb_containerView addSubview:self.bottomHandleView];
    [self layoutWithExpectOrientation:self.yb_currentOrientation()];
}

- (void)yb_pageChanged {
    if (self.topView.operationType == YBIBTopViewOperationTypeSave) {
        self.topView.operationButton.hidden = ![self.yb_currentData() respondsToSelector:@selector(yb_saveToPhotoAlbum)];
    }
    // 暂时屏蔽
//    [self.topView setPage:self.yb_currentPage() totalPage:self.yb_totalPage()];
}

- (void)yb_respondsToLongPress {
    [self showSheetView];
}

- (void)yb_hide:(BOOL)hide {
    self.topView.hidden = hide;
    self.bottomHandleView.hidden = hide;
    [self.sheetView hideWithAnimation:NO];
}

- (void)yb_orientationWillChangeWithExpectOrientation:(UIDeviceOrientation)orientation {
    [self.sheetView hideWithAnimation:NO];
}

- (void)yb_orientationChangeAnimationWithExpectOrientation:(UIDeviceOrientation)orientation {
    [self layoutWithExpectOrientation:orientation];
}

#pragma mark - private

- (void)layoutWithExpectOrientation:(UIDeviceOrientation)orientation {
    CGSize containerSize = self.yb_containerSize(orientation);
    UIEdgeInsets padding = YBIBPaddingByBrowserOrientation(orientation);
    if (orientation == UIDeviceOrientationLandscapeRight || orientation == UIDeviceOrientationLandscapeLeft) {
         self.topView.frame = CGRectMake(padding.left, 0, containerSize.width - padding.left - padding.right, 44);
    } else {
        if (kDevice_Is_iPhoneX) {
            self.topView.frame = CGRectMake(padding.left, 0, containerSize.width - padding.left - padding.right, 44+44);
        } else {
            self.topView.frame = CGRectMake(padding.left, 0, containerSize.width - padding.left - padding.right, 20+44);
        }
    }
   
//    self.topView.backgroundColor = [UIColor redColor];
    if (kDevice_Is_iPhoneX) {
        self.bottomHandleView.frame = CGRectMake(padding.left, containerSize.height-49-kBottom_iPhoneX, containerSize.width, 49);
    } else {
        self.bottomHandleView.frame = CGRectMake(padding.left, containerSize.height-49, containerSize.width, 49);
    }
}

#pragma mark - 点击更多按钮
- (void)showSheetView {
    if (![self.sheetView.actions containsObject:self.deleteAction]) {
        [self.sheetView.actions addObject:self.deleteAction];
    }
    if (![self.sheetView.actions containsObject:self.moveAction]) {
        [self.sheetView.actions addObject:self.moveAction];
    }
    if (![self.sheetView.actions containsObject:self.shareAction]) {
        [self.sheetView.actions addObject:self.shareAction];
    }
    if (![self.sheetView.actions containsObject:self.lockAction]) {
        [self.sheetView.actions addObject:self.lockAction];
    }
    [self.sheetView showToView:self.yb_containerView orientation:self.yb_currentOrientation()];
}

#pragma mark - getters

- (YBIBSheetView *)sheetView {
    if (!_sheetView) {
        _sheetView = [YBIBSheetView new];
        __weak typeof(self) wSelf = self;
        [_sheetView setCurrentdata:^id<YBIBDataProtocol>{
            __strong typeof(wSelf) self = wSelf;
            if (!self) return nil;
            return self.yb_currentData();
        }];
    }
    return _sheetView;
}

- (YBIBSheetAction *)saveAction {
    if (!_saveAction) {
        __weak typeof(self) wSelf = self;
        _saveAction = [YBIBSheetAction actionWithName:[YBIBCopywriter sharedCopywriter].saveToPhotoAlbum byImageName:@"" action:^(id<YBIBDataProtocol> data) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            if ([data respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
                [data yb_saveToPhotoAlbum];
            }
            [self.sheetView hideWithAnimation:YES];
        }];
    }
    return _saveAction;
}

#pragma mark - 删除
- (YBIBSheetAction *)deleteAction {
    if (!_deleteAction) {
        __weak typeof(self) weakSelf = self;
        _deleteAction = [YBIBSheetAction actionWithName:@"删除" byImageName:@"detail_more_select_delete" action:^(id<YBIBDataProtocol> data) {
            [self.sheetView hideWithAnimation:YES];
            if (weakSelf.sourceHandleCallBack) {
                weakSelf.sourceHandleCallBack(SourceHandleDeleteType);
            } else {
                
            }
        }];
    }
    return _deleteAction;
}

#pragma mark - 移动
- (YBIBSheetAction *)moveAction {
    if (!_moveAction) {
        __weak typeof(self) weakSelf = self;
        _moveAction = [YBIBSheetAction actionWithName:@"移动" byImageName:@"detail_more_select_move" action:^(id<YBIBDataProtocol> data) {
            [self.sheetView hideWithAnimation:YES];
            if (weakSelf.sourceHandleCallBack) {
                weakSelf.sourceHandleCallBack(SourceHandleMoveType);
            } else {
                
            }
        }];
    }
    return _moveAction;
}

#pragma mark - 分享
- (YBIBSheetAction *)shareAction {
    if (!_shareAction) {
        __weak typeof(self)weakSelf = self;
        _shareAction = [YBIBSheetAction actionWithName:@"分享" byImageName:@"detail_more_select_share" action:^(id<YBIBDataProtocol> data) {
            [self.sheetView hideWithAnimation:YES];
            if (weakSelf.sourceHandleCallBack) {
                weakSelf.sourceHandleCallBack(SourceHandleShareType);
            } else {
                
            }
        }];
    }
    return _shareAction;
}

#pragma mark - 锁定
- (YBIBSheetAction *)lockAction {
    __weak typeof(self) weakSelf = self;
    if (!_lockAction) {
        _lockAction = [YBIBSheetAction actionWithName:@"锁定" byImageName:@"detail_more_select_unlock" action:^(id<YBIBDataProtocol> data) {
            weakSelf.sheetView.isLock = !weakSelf.sheetView.isLock;
            [weakSelf.sheetView.tableView reloadData];
            [self.sheetView hideWithAnimation:YES];
            if (weakSelf.sourceHandleCallBack) {
                weakSelf.sourceHandleCallBack(SourceHandleLockType);
            } else {
                
            }
        }];
    }
    return _lockAction;
}

- (YBIBTopView *)topView {
    if (!_topView) {
        _topView = [YBIBTopView new];
        _topView.operationType = YBIBTopViewOperationTypeMore;
        __weak typeof(self) wSelf = self;
        [_topView setClickOperation:^(YBIBTopViewOperationType type) {
            __strong typeof(wSelf) self = wSelf;
            if (!self) return;
            switch (type) {
                case YBIBTopViewOperationTypeSave: {
                    id<YBIBDataProtocol> data = self.yb_currentData();
                    if ([data respondsToSelector:@selector(yb_saveToPhotoAlbum)]) {
                        [data yb_saveToPhotoAlbum];
                    }
                }
                    break;
                case YBIBTopViewOperationTypeMore: {
                    [self showSheetView];
                }
                    break;
                default:
                    break;
            }
        }];
    }
    return _topView;
}

- (SourceBottomHandleView *)bottomHandleView {
    if (!_bottomHandleView) {
       _bottomHandleView = [SourceBottomHandleView new];
       _bottomHandleView.backgroundColor = [UIColor blackColor];
    }
    return _bottomHandleView;
}

@end

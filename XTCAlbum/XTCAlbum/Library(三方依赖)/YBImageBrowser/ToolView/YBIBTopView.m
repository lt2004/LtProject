//
//  YBIBTopView.m
//  YBImageBrowserDemo
//
//  Created by 波儿菜 on 2019/7/6.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBIBTopView.h"
#import "YBIBIconManager.h"
#import "YBIBUtilities.h"
#import "XTCHomePageViewController.h"

@interface YBIBTopView ()
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, strong) UIButton *operationButton;
@end

@implementation YBIBTopView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.popButton];
        [self addSubview:self.pageLabel];
        [self addSubview:self.operationButton];
        
        [self setOperationType:YBIBTopViewOperationTypeMore];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    CGFloat buttonWidth = 54;
    self.popButton.frame = CGRectMake(0, height-44, 50, 44);
//    self.pageLabel.frame = CGRectMake(35, height-44, width / 2.0, 44);
    self.pageLabel.frame = CGRectMake(35, height-44, width-35-buttonWidth-20, 44);
//    self.pageLabel.backgroundColor = [UIColor redColor];
    self.operationButton.frame = CGRectMake(width - buttonWidth, height-44, buttonWidth, 44);
}

#pragma mark - public

+ (CGFloat)defaultHeight {
    return 44;
}

- (void)setSourceFileDate:(NSString *)dateStr {
    NSShadow *shadow = [NSShadow new];
    shadow.shadowBlurRadius = 4;
    shadow.shadowOffset = CGSizeMake(0, 1);
    shadow.shadowColor = UIColor.darkGrayColor;
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:dateStr?dateStr:@"" attributes:@{NSShadowAttributeName:shadow}];
    self.pageLabel.attributedText = attr;
}

- (void)setPage:(NSInteger)page totalPage:(NSInteger)totalPage {
    if (totalPage <= 1) {
        self.pageLabel.hidden = YES;
    } else {
        self.pageLabel.hidden  = NO;
        
        NSString *text = [NSString stringWithFormat:@"%ld/%ld", page + (NSInteger)1, totalPage];
        NSShadow *shadow = [NSShadow new];
        shadow.shadowBlurRadius = 4;
        shadow.shadowOffset = CGSizeMake(0, 1);
        shadow.shadowColor = UIColor.darkGrayColor;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSShadowAttributeName:shadow}];
        self.pageLabel.attributedText = attr;
    }
}

#pragma mark - event

- (void)clickOperationButton:(UIButton *)button {
    XTCHomePageViewController *homePageVC = (XTCHomePageViewController *)[StaticCommonUtil topViewController];
    [homePageVC interfaceOrientation:UIInterfaceOrientationPortrait];
    if (self.clickOperation) self.clickOperation(self.operationType);
}
/*
#pragma mark - hit test

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.operationButton.frame, point)) {
        return self.operationButton;
    }
    return nil;
}
 */

#pragma mark - getters & setters

- (void)setOperationType:(YBIBTopViewOperationType)operationType {
    _operationType = operationType;
    
    UIImage *image = nil;
    switch (operationType) {
        case YBIBTopViewOperationTypeSave:
            image = [YBIBIconManager sharedManager].toolSaveImage();
            break;
        case YBIBTopViewOperationTypeMore:
            image = [YBIBIconManager sharedManager].toolMoreImage();
            break;
    }
    
    [self.operationButton setImage:image forState:UIControlStateNormal];
}

- (UILabel *)pageLabel {
    if (!_pageLabel) {
        _pageLabel = [UILabel new];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.font = [UIFont boldSystemFontOfSize:16];
        _pageLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _pageLabel;
}

- (UIButton *)operationButton {
    if (!_operationButton) {
        _operationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _operationButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _operationButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_operationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_operationButton addTarget:self action:@selector(clickOperationButton:) forControlEvents:UIControlEventTouchUpInside];
        _operationButton.layer.shadowColor = UIColor.darkGrayColor.CGColor;
        _operationButton.layer.shadowOffset = CGSizeMake(0, 1);
        _operationButton.layer.shadowOpacity = 1;
        _operationButton.layer.shadowRadius = 4;
    }
    return _operationButton;
}

- (UIButton *)popButton {
    if (!_popButton) {
        _popButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _popButton.backgroundColor = [UIColor clearColor];
        [_popButton setImage:[UIImage imageNamed:@"detail_back_white"] forState:UIControlStateNormal];
        [_popButton setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    }
    return _popButton;
}

@end

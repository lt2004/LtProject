//
//  TZSelectPublishTypeCell.h
//  vs
//
//  Created by Xie Shu on 2017/12/13.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TZSelectPublishTypeCell : UICollectionViewCell

@property (nonatomic, strong) UIButton *selectTypeButton;
@property (nonatomic, assign) SelectPublishTypeEnum selectPublishTypeEnum;

- (void)loadByIndex:(NSInteger)selectIndex isHaveDraft:(BOOL)isDraft bySelectType:(SelectPublishTypeEnum)selectType;

@end

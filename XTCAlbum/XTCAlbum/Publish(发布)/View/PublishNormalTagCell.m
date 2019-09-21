//
//  PublishNormalTagCell.m
//  vs
//
//  Created by Xie Shu on 2017/10/17.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "PublishNormalTagCell.h"

@implementation PublishNormalTagCell
@synthesize deleteFlag = _deleteFlag;


- (void)insertAboutTagView:(NSString *)tagString byDeleteFlag:(BOOL)deleteFlag {
    _deleteFlag = deleteFlag;
    for (UIView *subView in self.contentView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            continue;
        } else {
            if ([subView isKindOfClass:[UIView class]]) {
                [subView removeFromSuperview];
            } else {
                
            }
        }
        
    }
    NSArray *tagArray = [tagString componentsSeparatedByString:@","];
    float flagWidth = 70;
    float flagTop = 7;
    
    for (NSString *tag in tagArray) {
        CGSize titleSize = [tag sizeWithFont:[UIFont fontWithName:@"Helvetica-Light" size:12.0f] constrainedToSize:CGSizeMake(MAXFLOAT, 30)];
        titleSize = CGSizeMake(titleSize.width+15, 30);
        
        if (flagWidth + titleSize.width + 10 > kScreenWidth) {
            flagTop = flagTop + 35;
            flagWidth = 70;
        } else {
            
        }
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PublishTagView" owner:self options:nil];
        PublishTagView *publishTagView = [nib objectAtIndex:0];
        [self.contentView addSubview:publishTagView];
//        publishTagView.layer.cornerRadius = 12;
//        publishTagView.layer.masksToBounds = YES;
//        publishTagView.backgroundColor = HEX_RGB(0xECF2F2);
        publishTagView.tagLabel.text = tag;
        [publishTagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).with.offset(flagTop);
            make.left.equalTo(self.contentView).with.offset(flagWidth);
            make.size.mas_equalTo(CGSizeMake(titleSize.width, 30));
            if ([tag isEqualToString:tagArray.lastObject]) {
                make.bottom.equalTo(self.contentView).with.offset(-10);
            } else {
                
            }
        }];
        flagWidth = flagWidth + titleSize.width + 10;
        if (deleteFlag) {
            publishTagView.delButton.hidden = NO;
//            publishTagView.tagLabel.textAlignment = NSTextAlignmentRight;
        } else {
            publishTagView.delButton.hidden = YES;
//            publishTagView.tagLabel.textAlignment = NSTextAlignmentCenter;
        }
            publishTagView.tagLabel.layer.cornerRadius = 12;
            publishTagView.tagLabel.layer.masksToBounds = YES;
            publishTagView.tagLabel.backgroundColor = HEX_RGB(0xECF2F2);
        UITapGestureRecognizer *delTapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(delTapGes:)];
        [publishTagView addGestureRecognizer:delTapGes];
        
    }
    
}

- (void)delTapGes:(UITapGestureRecognizer *)tapGes {
    if (_deleteFlag) {
        PublishTagView *publishTagView = (PublishTagView *)tapGes.view;
        if (self.publishNormalDelTagCallBack) {
            self.publishNormalDelTagCallBack(publishTagView.tagLabel.text);
        } else {
            
        }
    } else {
        
    }
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

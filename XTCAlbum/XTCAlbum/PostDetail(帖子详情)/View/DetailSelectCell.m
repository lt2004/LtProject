//
//  DetailSelectCell.m
//  vs
//
//  Created by Xie Shu on 2017/8/5.
//  Copyright © 2017年 Xiaotangcai. All rights reserved.
//

#import "DetailSelectCell.h"

@implementation DetailSelectCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)insertAbouData:(PostDetail *)postDetailModel {
    _descLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
    _descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:postDetailModel.postDescript ? postDetailModel.postDescript : @""];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    [paragraphStyle setLineSpacing:9];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.string.length)];
    [attributedString addAttribute:NSBaselineOffsetAttributeName value:@(0) range:NSMakeRange(0, [attributedString.string length])];
    _descLabel.attributedText = attributedString;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

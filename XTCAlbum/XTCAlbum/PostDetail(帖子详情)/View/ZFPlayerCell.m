//
//  ZFPlayerCell.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFPlayerCell.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>

@interface ZFPlayerCell () {
    UITapGestureRecognizer *_doubleTap;
}

@end

@implementation ZFPlayerCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.picView = [[UIImageView alloc] init];
    self.picView.contentMode = UIViewContentModeScaleAspectFit;
    self.picView.userInteractionEnabled = YES;
    self.picView.tag = 101;
    [self.contentView addSubview:self.picView];
    [self.picView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
    }];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playBtn setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    [self.picView addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.picView);
        make.edges.equalTo(self.picView);
    }];
    
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.numberOfLines = 0;
    self.descLabel.textColor = RGBCOLOR(64, 64, 64);
    self.descLabel.font = [UIFont fontWithName:@"Helvetica" size:18];
    [self.contentView addSubview:self.descLabel];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.picView).with.offset(10);
        make.right.equalTo(self.picView).with.offset(-10);
        make.top.equalTo(self.picView.mas_bottom);
        make.bottom.equalTo(self.contentView).with.offset(-10);
        make.height.mas_equalTo(10);
    }];
    /*
    _doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction)];
//    _doubleTap.delegate                = self;
    _doubleTap.numberOfTouchesRequired = 1; //手指数
    _doubleTap.numberOfTapsRequired    = 2;
    [self.picView addGestureRecognizer:_doubleTap];
     */
}

- (void)doubleTapAction {
//    [self.picView jp_pause];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)play:(UIButton *)sender {
    if (self.playBlock) {
        self.playBlock(sender);
    }
}

@end

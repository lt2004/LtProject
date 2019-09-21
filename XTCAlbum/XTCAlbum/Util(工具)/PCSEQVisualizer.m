//
//  PCSEQVisualizer.m
//  vs
//
//  Created by Mac on 2018/10/30.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import "PCSEQVisualizer.h"

#define kWidth 4
#define kHeight 20
#define kPadding 1

#define kRecoderWidth 5
#define kRecoderPadding 4
#define kRecoderHeight 55


@implementation PCSEQVisualizer {
    NSTimer *timer;
}

- (id)initVisualizerByTypeL:(VisualizerType)type {
    self = [super init];
    if (self) {
        if (type == VisualizerSiriType) {
            self.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
            self.barColor = [UIColor whiteColor];
            self.barArray = [[NSMutableArray alloc] init];
            UIImageView *voiceImageView = [[UIImageView alloc] init];
            voiceImageView.image = [UIImage imageNamed:@"voice_hud"];
            [self addSubview:voiceImageView];
            [voiceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(self).with.offset(18);
            }];
            
            UIView *bottomBgView = [[UIView alloc] init];
            bottomBgView.backgroundColor = [UIColor clearColor];
            [self addSubview:bottomBgView];
            [bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(79, 20));
                make.bottom.equalTo(self).with.offset(-12);
                make.centerX.equalTo(self);
            }];
            
            for(int i=0; i<16; i++){
                UIImageView *bar = [[UIImageView alloc]initWithFrame:CGRectMake(i*kWidth+i*kPadding, 0, kWidth, 2)];
                bar.image = [GlobalData createImageWithColor:self.barColor];
                bar.layer.cornerRadius = 2;
                bar.layer.masksToBounds = YES;
                [bottomBgView addSubview:bar];
                [self.barArray addObject:bar];
                
                UIView *flagCorverView = [[UIView alloc] init];
                flagCorverView.backgroundColor = [UIColor whiteColor];
                [bottomBgView addSubview:flagCorverView];
                [flagCorverView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.equalTo(bar);
                    make.height.mas_equalTo(2);
                }];
            }
            
            UIView *topBgView = [[UIView alloc] init];
            topBgView.backgroundColor = [UIColor clearColor];
            [self addSubview:topBgView];
            [topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(79, 20));
                make.bottom.equalTo(bottomBgView.mas_top);
                make.centerX.equalTo(bottomBgView);
            }];
            
            for(int i=0; i<16; i++){
                UIImageView *bar = [[UIImageView alloc]initWithFrame:CGRectMake(i*kWidth+i*kPadding, 0, kWidth, 2)];
                bar.image = [GlobalData createImageWithColor:self.barColor];;
                bar.layer.cornerRadius = 2;
                bar.layer.masksToBounds = YES;
                [topBgView addSubview:bar];
                [self.barArray addObject:bar];
                
                UIView *flagCorverView = [[UIView alloc] init];
                flagCorverView.backgroundColor = [UIColor whiteColor];
                [topBgView addSubview:flagCorverView];
                [flagCorverView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.equalTo(bar);
                    make.height.mas_equalTo(2);
                }];
            }
            topBgView.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
        } else {
            // 录制音频部分
            self.backgroundColor = [UIColor clearColor];
            self.barColor = HEX_RGB(0xEDEDED);
            self.barArray = [[NSMutableArray alloc] init];
            
            UIView *bottomBgView = [[UIView alloc] init];
            bottomBgView.backgroundColor = [UIColor clearColor];
            [self addSubview:bottomBgView];
            [bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(122, 55));
                make.bottom.equalTo(self).with.offset(0);
                make.centerX.equalTo(self);
            }];
            
            for(int i=0; i<14; i++){
                UIImageView *bar = [[UIImageView alloc]initWithFrame:CGRectMake(i*kRecoderWidth+i*kRecoderPadding, 0, kRecoderWidth, 8)];
                bar.image = [GlobalData createImageWithColor:self.barColor];;
                bar.layer.cornerRadius = 2;
                bar.layer.masksToBounds = YES;
                [bottomBgView addSubview:bar];
                [self.barArray addObject:bar];
                
                UIView *flagCorverView = [[UIView alloc] init];
                flagCorverView.backgroundColor = HEX_RGB(0xEDEDED);
                [bottomBgView addSubview:flagCorverView];
                [flagCorverView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.equalTo(bar);
                    make.height.mas_equalTo(2);
                }];
            }
            
            UIView *topBgView = [[UIView alloc] init];
            topBgView.backgroundColor = [UIColor clearColor];
            [self addSubview:topBgView];
            [topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(122, 55));
                make.bottom.equalTo(bottomBgView.mas_top);
                make.centerX.equalTo(bottomBgView);
            }];
            
            for(int i=0; i<14; i++){
                UIImageView *bar = [[UIImageView alloc]initWithFrame:CGRectMake(i*kRecoderWidth+i*kRecoderPadding, 0, kRecoderWidth, 8)];
                bar.image = [GlobalData createImageWithColor:self.barColor];;
                bar.layer.cornerRadius = 2;
                bar.layer.masksToBounds = YES;
                [topBgView addSubview:bar];
                [self.barArray addObject:bar];
                
                UIView *flagCorverView = [[UIView alloc] init];
                flagCorverView.backgroundColor = HEX_RGB(0xEDEDED);
                [topBgView addSubview:flagCorverView];
                [flagCorverView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.right.equalTo(bar);
                    make.height.mas_equalTo(2);
                }];
            }
            topBgView.transform = CGAffineTransformMakeRotation(180 *M_PI / 180.0);
        }
        self.visualizerType = type;
    }
    return self;
}


-(void)start{
    
    self.hidden = NO;
    timer = [NSTimer scheduledTimerWithTimeInterval:.35 target:self selector:@selector(ticker) userInfo:nil repeats:YES];
    
}


-(void)stop{
    
    [timer invalidate];
    timer = nil;
    
}

-(void)ticker{
    
    [UIView animateWithDuration:.35 animations:^{
        
        for(UIImageView* bar in self.barArray){
            CGRect rect = bar.frame;
            if (self.visualizerType == VisualizerSiriType) {
                rect.size.height = arc4random() % kHeight + 2;
            } else {
                rect.size.height = arc4random() % (kRecoderHeight-8) + 8;
            }
            
            bar.frame = rect;
            
            
        }
        
    }];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

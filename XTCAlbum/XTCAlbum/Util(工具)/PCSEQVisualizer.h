//
//  PCSEQVisualizer.h
//  vs
//
//  Created by Mac on 2018/10/30.
//  Copyright © 2018 Xiaotangcai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VisualizerType) {
    VisualizerSiriType,
    VisualizerRecoderType,
};

@interface PCSEQVisualizer : UIView

@property (nonatomic, retain) UIColor *barColor;
@property (nonatomic, strong) NSMutableArray *barArray;
@property (nonatomic, assign) VisualizerType visualizerType;
- (id)initVisualizerByTypeL:(VisualizerType)type;

-(void)start;
-(void)stop;

@end

NS_ASSUME_NONNULL_END

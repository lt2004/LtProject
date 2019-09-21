//
//  ProData.m
//  vs
//
//  Created by 邵帅 on 2016/12/20.
//  Copyright © 2016年 Xiaotangcai. All rights reserved.
//

#import "ProData.h"

@implementation ProData

+ (ProData *)sharedInstance {
    static ProData *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[ProData alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.page = 2;
        self.proModel = [[ProModel alloc] init];
        NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                                   AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                                   AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                                   AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
        NSError *error;
        NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
        self.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        return self;
    }
    return nil;
}



@end

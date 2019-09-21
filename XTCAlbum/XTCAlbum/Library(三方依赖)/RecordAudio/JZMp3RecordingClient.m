//
//  JZMp3RecordingClient.m
//
// Copyright (c) 2014 Jacky<newbdez33@gmail.com> (http://jiezhang.me/)
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

#import "JZMp3RecordingClient.h"
#import "lame.h"

@implementation JZMp3RecordingClient

+ (instancetype)sharedClient {
    static JZMp3RecordingClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[JZMp3RecordingClient alloc] init];
    });
    return _sharedClient;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.isRecoding = NO;
    }
    return self;
}

- (void)start:(NSString *)audioFilePath
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [self stop];
    self.isRecoding = YES;
    self.currentMp3File = audioFilePath;
    // 实例化AERecorder对象
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if (session == nil) {
        
        NSLog(@"Error creating session: %@",[sessionError description]);
        
    }else{
        [session setActive:YES error:nil];
        
    }
    
    self.session = session;
    
    //设置参数
    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
                                   [NSNumber numberWithFloat: 22050],AVSampleRateKey,
                                   // 音频格式
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   //采样位数  8、16、24、32 默认为16
                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                                   // 音频通道数 1 或 2
                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
                                   //录音质量
                                   [NSNumber numberWithInt:AVAudioQualityHigh],AVEncoderAudioQualityKey,
                                   nil];
    
    NSString *tmpDir =NSTemporaryDirectory();
    NSString *filePath =[tmpDir stringByAppendingPathComponent:@"memo.caf"];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    NSURL *fileUrl =[NSURL fileURLWithPath:filePath];
    _recorder = [[AVAudioRecorder alloc] initWithURL:fileUrl settings:recordSetting error:nil];
    _recorder.delegate = self;
    
    if (_recorder) {
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        [_recorder record];
    } else{
        self.isRecoding = NO;
//        DDLogInfo(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
        
    }
}

- (void)stop {
    if ([_recorder isRecording]) {
        [_recorder stop];
    }
    self.isRecoding = NO;
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
//    DDLogInfo(@"录制完后");
    // 在录制caf文件时，需要使用双通道，否则在转换为MP3格式时，声音不对。caf录制端的设置为：

    NSMutableDictionary *recordSetting = [NSMutableDictionary dictionary];
    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];//
    [recordSetting setValue:[NSNumber numberWithFloat:22050] forKey:AVSampleRateKey];//采样率
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];//声音通道，这里必须为双通道
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];//音频质量
   // 在转换mp3端的代码为:
    NSString *tmpDir =NSTemporaryDirectory();
    NSString *filePath =[tmpDir stringByAppendingPathComponent:@"memo.caf"];
    NSString *mp3FilePath = self.currentMp3File;//存储mp3文件的路径
    @try {
        int read, write;
        FILE *pcm = fopen([filePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置

        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];

        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 22050.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);

            fwrite(mp3_buffer, write, 1, mp3);

        } while (read != 0);

        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
         [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    @finally {

    }
    self.isRecoding = NO;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];//此处需要恢复设置回放标志，否则会导致其它播放声音也会变小
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    self.isRecoding = NO;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];//此处需要恢复设置回放标志，否则会导致其它播放声音也会变小
}




@end

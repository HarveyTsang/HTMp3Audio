//
//  FileConvertViewController.m
//  HTMp3Audio Example
//
//  Created by HarveyTsang on 2020/12/9.
//

#import "FileConvertViewController.h"
#import <AVKit/AVKit.h>
#import <HTMp3Audio/HTMp3FileConverter.h>

@interface FileConvertViewController ()<AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation FileConvertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAudioSession];
}

- (void)setupAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
    [audioSession setActive:YES error:nil];
}

///  audio file save path
- (NSURL *)pcmURL {
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:@"audio.wav"];
    NSLog(@"file path:%@", urlStr);
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}

///  audio file save path
- (NSURL *)mp3URL {
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:@"audioConvert.mp3"];
    NSLog(@"file path:%@", urlStr);
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}

/// audio recorder settings
- (NSDictionary *)audioSettings{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    dicM[AVFormatIDKey] = @(kAudioFormatLinearPCM);
    dicM[AVSampleRateKey] = @16000;
    dicM[AVNumberOfChannelsKey] = @2;
    return dicM;
}

- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        NSURL *url = [self pcmURL];
        NSDictionary *settings = [self audioSettings];
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        _audioRecorder.delegate = self;
        if (error) {
            NSLog(@"create recorder fail:%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

- (IBAction)clickBtn:(id)sender {
    [self.audioRecorder recordForDuration:10];
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (flag) {
        [HTMp3FileConverter convertPCM:[self pcmURL] toMp3:[self mp3URL] completion:^(BOOL success) {
            NSLog(@"convert %@", success ? @"success" : @"fail");
        }];
    }
}

@end

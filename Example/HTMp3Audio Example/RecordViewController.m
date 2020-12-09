//
//  ViewController.m
//  HTMp3Audio Example
//
//  Created by HarveyTsang on 2020/12/4.
//

#import "RecordViewController.h"
#import <HTMp3Audio/HTMp3Audio.h>

@interface RecordViewController ()<HTMp3AudioRecorderDelegate>

@property (nonatomic, strong) HTMp3AudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UIProgressView *audioPowerIndicator;

@end

@implementation RecordViewController

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
- (NSURL *)savePath {
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlStr = [urlStr stringByAppendingPathComponent:@"audio.mp3"];
    NSLog(@"file path:%@", urlStr);
    NSURL *url = [NSURL fileURLWithPath:urlStr];
    return url;
}

/// audio recorder settings
- (NSDictionary *)audioSettings{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    dicM[AVSampleRateKey] = @16000;
    dicM[AVNumberOfChannelsKey] = @1;
    return dicM;
}

- (HTMp3AudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        NSURL *url = [self savePath];
        NSDictionary *settings = [self audioSettings];
        _audioRecorder = [[HTMp3AudioRecorder alloc] initWithURL:url settings:settings];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;
    }
    return _audioRecorder;
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)audioPowerChange{
    float power = [self.audioRecorder averagePower];
    CGFloat progress = (1.0/160.0)*(power+160.0);
    [self.audioPowerIndicator setProgress:progress];
}
#pragma mark - Actions
- (IBAction)recordClick:(UIButton *)sender {
    if (![self.audioRecorder isRecording]) {
        [self.audioRecorder record];
//        [self.audioRecorder recordForDuration:60];
        self.timer.fireDate = [NSDate distantPast];
    }
}

- (IBAction)pauseClick:(UIButton *)sender {
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder pause];
        self.timer.fireDate = [NSDate distantFuture];
    }
}

- (IBAction)resumeClick:(UIButton *)sender {
    [self recordClick:sender];
}

- (IBAction)stopClick:(UIButton *)sender {
    [self.audioRecorder stop];
    self.timer.fireDate = [NSDate distantFuture];
    self.audioPowerIndicator.progress = 0.0;
}

- (IBAction)playClick:(UIButton *)sender {
    if (![_audioPlayer isPlaying]) {
        NSURL *url = [self savePath];
        NSError *error=nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (error) {
            NSLog(@"create player fail：%@", error.localizedDescription);
        }
        _audioPlayer.numberOfLoops = 0;
        [_audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }
}

- (IBAction)stopPlayClick:(UIButton *)sender {
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
    }
}


#pragma mark - HTAudioRecorderDelegate
- (void)htAudioRecorderDidFinishRecording:(HTMp3AudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"finish recording:%d", flag);
}

@end

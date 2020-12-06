//
//  HTMp3AudioRecorder.m
//  HTMp3AudioRecorder
//
//  Created by HarveyTsang on 2020/12/4.
//

#import "HTMp3AudioRecorder.h"
#import "lame/lame.h"

static const int kMP3BufferCapacity = 4096;

typedef struct HTMP3RecorderSettings {
    float sampleRate;
    int numberOfChannels;
} HTMP3RecorderSettings;

@interface HTMp3AudioRecorder ()

@property (nonatomic, strong) AVAudioEngine *audioEngine;
@property (nonatomic, assign) lame_t lame;
@property (nonatomic, assign) unsigned char *mp3Buffer;
@property (nonatomic, assign) FILE *file;
@property (nonatomic, strong) NSDictionary *settingsDict;
@property (nonatomic, assign) HTMP3RecorderSettings settings;
@property (nonatomic, assign) BOOL isPrepare;
@property (nonatomic, assign) NSTimeInterval targetDuration;
@property (nonatomic, assign) NSTimeInterval currentTime;
@property (nonatomic, assign) AudioUnitParameterValue averagePower;

@end

@implementation HTMp3AudioRecorder

- (instancetype)initWithURL:(NSURL *)url settings:(NSDictionary *)settings {
    self = [super init];
    if (!self) return nil;
    _settingsDict = settings;
    _url = url;
    _mp3Buffer = malloc(kMP3BufferCapacity);
    return self;
}

- (BOOL)prepareToRecord {
    if (_isPrepare) return YES;
    _file = fopen([_url.path cStringUsingEncoding:1], "wb+");
    if (!_file) return NO;
    AVAudioSession *session = AVAudioSession.sharedInstance;
    [session setActive:YES error:nil];
    _audioEngine = [[AVAudioEngine alloc] init];
    if (!_audioEngine) return NO;
    
    [self prepareSetting];
    
    [self prepareLame];
    
    AVAudioInputNode *input = _audioEngine.inputNode;
    if (!_audioEngine || !input) return NO;
    AVAudioFormat *format = [input inputFormatForBus:0];
    __weak typeof(self) ws = self;
    [input installTapOnBus:0 bufferSize:kMP3BufferCapacity format:format block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        typeof(ws) ss = ws;
        if (!ss) return;
        if (!buffer.floatChannelData) return;
        
        ss.currentTime += buffer.frameLength/buffer.format.sampleRate;
        if (ss.targetDuration > 0 && ss.currentTime - ss.targetDuration > 0.000001) {
            [ss stop];
            return;
        }
        
        int frameLength = buffer.frameLength;
        
        float *channel0Buffer = buffer.floatChannelData[0];
        float *channel1Buffer = ss.settings.numberOfChannels == 2 ? channel0Buffer : NULL;
        int bytesWritten = lame_encode_buffer_ieee_float(ss.lame, channel0Buffer, channel1Buffer, frameLength, ss.mp3Buffer, kMP3BufferCapacity);
        fwrite(ss.mp3Buffer, bytesWritten, 1, ss.file);
        
        if (!ss.meteringEnabled) return;
        double sum = 0.0;
        for (int i = 0; i < frameLength; i++) {
            sum += channel0Buffer[i]*channel0Buffer[i];
        }
        ss.averagePower = 20 * log10(sqrt(sum / frameLength));
    }];
    [self.audioEngine prepare];
    _isPrepare = YES;
    return YES;
}

- (void)prepareSetting {
    AVAudioInputNode *input = _audioEngine.inputNode;
    AVAudioFormat *format = [input inputFormatForBus:0];
    float sampleRate = format.sampleRate;
    if (_settingsDict[AVSampleRateKey]) {
        sampleRate = [_settingsDict[AVSampleRateKey] floatValue];
    }
    _settings.sampleRate = MAX(MIN(sampleRate, format.sampleRate), 1.0);
    
    unsigned int numberOfChannels = format.channelCount;
    if (_settingsDict[AVNumberOfChannelsKey]) {
        numberOfChannels = [_settingsDict[AVNumberOfChannelsKey] unsignedIntValue];
    }
    _settings.numberOfChannels = MAX(MIN(numberOfChannels, 2), 1);
}

- (void)prepareLame {
    AVAudioInputNode *input = _audioEngine.inputNode;
    if (!input) return;
    AVAudioFormat *format = [input inputFormatForBus:0];
    int sampleRate = format.sampleRate;
    _lame = lame_init();
    lame_set_in_samplerate(_lame, sampleRate);
    lame_set_out_samplerate(_lame, _settings.sampleRate);
    lame_set_num_channels(_lame, _settings.numberOfChannels);
    lame_init_params(_lame);
}

- (BOOL)record {
    return [self recordForDuration:0.0];
}

- (BOOL)recordForDuration:(NSTimeInterval)duration {
    if (self.isRecording) return YES;
    else if (![self prepareToRecord]) {
        return NO;
    }
    _targetDuration = duration;
    NSError *error = nil;
    BOOL r = [self.audioEngine startAndReturnError:&error];
    if (error) NSLog(@"%@", error.localizedDescription);
    return r;
}

- (void)pause {
    [self.audioEngine pause];
}

- (void)stop {
    if (!self.audioEngine.isRunning) return;
    
    [self.audioEngine stop];
    lame_encode_flush(self.lame, self.mp3Buffer, kMP3BufferCapacity);
    lame_mp3_tags_fid(self.lame, _file);
    lame_close(_lame);
    _lame = NULL;
    fclose(_file);
    _file = NULL;
    _currentTime = 0;
    _isPrepare = NO;
    if ([self.delegate respondsToSelector:@selector(htAudioRecorderDidFinishRecording:successfully:)]) {
        [self.delegate htAudioRecorderDidFinishRecording:self successfully:YES];
    }
}

- (BOOL)isRecording {
    return _audioEngine.isRunning;
}

- (BOOL)deleteRecording {
    NSError *error = nil;
    BOOL r = [NSFileManager.defaultManager removeItemAtURL:self.url error:&error];
    if (error) NSLog(@"%@", error.localizedDescription);
    return r;
}

- (void)dealloc {
    if (_lame) lame_close(_lame);
    if (_mp3Buffer) free(_mp3Buffer);
}


@end

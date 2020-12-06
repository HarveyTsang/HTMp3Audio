//
//  HTMp3AudioRecorder.h
//  HTMp3AudioRecorder
//
//  Created by HarveyTsang on 2020/12/4.
//

#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HTMp3AudioRecorder;
@protocol HTMp3AudioRecorderDelegate <NSObject>

@optional

/* htAudioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)htMp3AudioRecorderDidFinishRecording:(HTMp3AudioRecorder *)recorder successfully:(BOOL)flag;

@end

@interface HTMp3AudioRecorder : NSObject

/// initializer
/// @param url audio file save path
/// @param settings support setting number of channels (by 'AVNumberOfChannelsKey'), sample rate(by 'AVSampleRateKey')
- (nullable instancetype)initWithURL:(NSURL *)url settings:(NSDictionary *)settings;

/// prepare to record. (optional call)
/// @return Whether the preparation is successful
- (BOOL)prepareToRecord;

- (BOOL)record;

/// record audio of specified duration
/// @param duration unit is second
- (BOOL)recordForDuration:(NSTimeInterval)duration;

- (void)pause;

- (void)stop;

- (BOOL)deleteRecording;

@property(nonatomic, weak) id<HTMp3AudioRecorderDelegate> delegate;

@property(readonly, getter=isRecording) BOOL recording;

@property(readonly) NSURL *url;

/// current recording time
@property(readonly) NSTimeInterval currentTime;
/// enable audio power measurement
@property(getter=isMeteringEnabled) BOOL meteringEnabled;

@property(readonly) AudioUnitParameterValue averagePower;

@end

NS_ASSUME_NONNULL_END

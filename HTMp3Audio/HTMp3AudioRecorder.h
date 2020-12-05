//
//  HTMp3AudioRecorder.h
//  HTMp3AudioRecorder
//
//  Created by HarveyTsang on 2020/12/4.
//

#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HTMp3AudioRecorder;
@protocol HTAudioRecorderDelegate <NSObject>

@optional

/* htAudioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)htAudioRecorderDidFinishRecording:(HTMp3AudioRecorder *)recorder successfully:(BOOL)flag;

@end

@interface HTMp3AudioRecorder : NSObject

- (nullable instancetype)initWithURL:(NSURL *)url settings:(NSDictionary *)settings;

- (BOOL)prepareToRecord;

- (BOOL)record;

- (BOOL)recordForDuration:(NSTimeInterval) duration;

- (void)pause;

- (void)stop;

- (BOOL)deleteRecording;

@property(nonatomic, weak) id<HTAudioRecorderDelegate> delegate;

@property(readonly, getter=isRecording) BOOL recording;

@property(readonly) NSURL *url;

@property(readonly) float sampleRate;

@property(readonly) NSTimeInterval currentTime;

@property(getter=isMeteringEnabled) BOOL meteringEnabled;

@property(readonly) AudioUnitParameterValue averagePower;

@end

NS_ASSUME_NONNULL_END

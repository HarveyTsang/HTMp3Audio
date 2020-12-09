//
//  HTMp3FileConverter.m
//  HTMp3Audio
//
//  Created by HarveyTsang on 2020/12/9.
//

#import "HTMp3FileConverter.h"
#import "lame.h"
#import <AVKit/AVKit.h>

@implementation HTMp3FileConverter

+ (void)convertPCM:(NSURL *)pcmFileURL toMp3:(NSURL *)mp3FileURL completion:(HTMp3FileConverterCompletion)completion {
    NSError *error = nil;
    AVAudioFile *audioFile = [[AVAudioFile alloc] initForReading:pcmFileURL error:&error];
    if (error) {
        NSLog(@"can't open pcm file:%@", error.localizedDescription);
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(NO);
            });
        }
        return;
    }
    FILE *mp3File = fopen(mp3FileURL.path.UTF8String, "wb+");
    lame_t lame = lame_init();
    lame_set_num_channels(lame, audioFile.fileFormat.channelCount);
    lame_set_in_samplerate(lame, audioFile.fileFormat.sampleRate);
    lame_set_out_samplerate(lame, audioFile.fileFormat.sampleRate);
    lame_set_VBR(lame, vbr_default);
    lame_init_params(lame);

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        const AVAudioFrameCount kBufferFrameCapacity = 1024 * 10;
        unsigned char mp3Buffer[kBufferFrameCapacity];
        AVAudioFramePosition fileLength = audioFile.length;
        AVAudioPCMBuffer *pcmBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:audioFile.processingFormat frameCapacity:kBufferFrameCapacity];
        
        BOOL occurError = NO;
        int write = 0;
        while (audioFile.framePosition < fileLength) {
            NSError *error = nil;
            if (![audioFile readIntoBuffer:pcmBuffer error:&error]) {
                NSLog(@"read fail: %@", error.localizedDescription);
                occurError = YES;
                break;
            }
            else {
                if (!pcmBuffer.floatChannelData) {
                    occurError = YES;
                    break;
                }
                write = lame_encode_buffer_ieee_float(lame, pcmBuffer.floatChannelData[0], pcmBuffer.floatChannelData[1], pcmBuffer.frameLength, mp3Buffer, kBufferFrameCapacity);
                fwrite(mp3Buffer, write, 1, mp3File);
            }
        }
        if (!occurError) {
            write = lame_encode_flush(lame, mp3Buffer, kBufferFrameCapacity);
            fwrite(mp3Buffer, write, 1, mp3File);
            lame_mp3_tags_fid(lame, mp3File);
            lame_close(lame);
            fclose(mp3File);
        }
        else {
            lame_close(lame);
            freopen(NULL, "wb+", mp3File);// clean
            fclose(mp3File);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(!occurError);
        });
    });
}

@end

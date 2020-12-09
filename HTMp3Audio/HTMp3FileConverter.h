//
//  HTMp3FileConverter.h
//  HTMp3Audio
//
//  Created by HarveyTsang on 2020/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HTMp3FileConverterCompletion)(BOOL success);

@interface HTMp3FileConverter : NSObject

/// convert pcm file to mp3 file
/// @param pcmFileURL pcm file url
/// @param mp3FileURL mp3 file url
/// @param completion called on main thread
+ (void)convertPCM:(NSURL *)pcmFileURL
             toMp3:(NSURL *)mp3FileURL
        completion:(HTMp3FileConverterCompletion _Nullable)completion;

@end

NS_ASSUME_NONNULL_END

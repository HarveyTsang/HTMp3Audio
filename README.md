# HTMp3Audio
Record mp3 format audio on iOS platform.

## Installation

### Installation with CocoaPods
Specify it in your Podfile:

```ruby
pod 'HTMp3Audio'
```

## Usage
Create recorder instance:

```Objective-C
NSMutableDictionary *settings = [NSMutableDictionary dictionary];
settings[AVSampleRateKey] = @16000;
settings[AVNumberOfChannelsKey] = @1;
HTMp3AudioRecorder *recorder = [[HTMp3AudioRecorder alloc] initWithURL:fileURL settings:settings];
```
Record

```Objective-C
[recorder record];
// [recorder recordForDuration:60];
```
# TXAudioPlayerRecorder

Simple library that handlers playing or recording audio files (local or remote)


## Usage

First, you need to create a TXAudioPlayerRecorder instance:

    self.playerRecorder = [[TXAudioPlayerRecorder alloc] init];
    
You need to set the audio file (local or remote)

	self.playerRecorder.fileURL = [NSURL URLWithString:@"http://...."];

Or

	self.playerRecorder.fileURL = [NSURL fileURLWithPath:@"http://...."];

## Delegate

	- (void)playerRecorder:(TXAudioPlayerRecorder * _Nonnull)playerRecorder willFinishSuccessfully:(BOOL)successfully;
	- (void)playerRecorder:(TXAudioPlayerRecorder * _Nonnull)playerRecorder didPreparePlayerSuccessfully:(BOOL)successfully;
	- (void)playerRecorder:(TXAudioPlayerRecorder * _Nonnull)playerRecorder didPrepareRecorderSuccessfully:(BOOL)successfully;
	- (void)playerRecorderDidUpdate:(TXAudioPlayerRecorder * _Nonnull)playerRecorder;

To run the example project, clone the repo, and run `pod install` from the Example directory first.



## Requirements

iOS 7.0

## Installation

TXAudioPlayerRecorder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "TXAudioPlayerRecorder"
```

## License

Copyright (c) 2015 Toshiro Sugii

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

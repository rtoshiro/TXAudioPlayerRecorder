//  TXAudioPlayerRecorder.h
//
// The MIT License
//
// Copyright (c) Toshiro Sugii
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

////////////////////////////////////////////////////////////////////////////////
/// @name States
////////////////////////////////////////////////////////////////////////////////

typedef enum
{
    TXAudioPlayerRecorderStateNone,
    TXAudioPlayerRecorderStatePaused,
    TXAudioPlayerRecorderStatePlaying,
    TXAudioPlayerRecorderStatePreparingToPlay,
    TXAudioPlayerRecorderStatePreparedToPlay,
    TXAudioPlayerRecorderStatePreparingToPlayAndPlaying,
    TXAudioPlayerRecorderStateRecording,
    TXAudioPlayerRecorderStatePreparingToRecord,
    TXAudioPlayerRecorderStatePreparedToRecord,
    TXAudioPlayerRecorderStatePreparingToRecordAndRecording
} TXAudioPlayerRecorderState;

@class TXAudioPlayerRecorder;

////////////////////////////////////////////////////////////////////////////////
/// @name Delegate
////////////////////////////////////////////////////////////////////////////////

@protocol TXAudioPlayerRecorderDelegate <NSObject>

@optional
/**
 *  @author Toshiro Sugii, 15-12-17 17:12:16
 *
 *  Calle when player or recorder will finish
 *
 *  @param playerRecorder Current TXAudioPlayerRecorder object
 *  @param successfully   YES if has finished successfully otherwise NO.
 *
 *  @since 1.0
 */
- (void)playerRecorder:(TXAudioPlayerRecorder * _Nonnull)playerRecorder willFinishSuccessfully:(BOOL)successfully;

/**
 *  @author Toshiro Sugii, 15-12-17 17:12:30
 *
 *  Called when player did prepared successfully
 *
 *  @param playerRecorder Current TXAudioPlayerRecorder object
 *  @param successfully   YES if has prepared successfully otherwise NO.
 *
 *  @since 1.0
 */
- (void)playerRecorder:(TXAudioPlayerRecorder * _Nonnull)playerRecorder didPreparePlayerSuccessfully:(BOOL)successfully;

/**
 *  @author Toshiro Sugii, 15-12-17 17:12:30
 *
 *  Called when recorder did prepared successfully
 *
 *  @param playerRecorder Current TXAudioPlayerRecorder object
 *  @param successfully   YES if has prepared successfully otherwise NO.
 *
 *  @since 1.0
 */
- (void)playerRecorder:(TXAudioPlayerRecorder * _Nonnull)playerRecorder didPrepareRecorderSuccessfully:(BOOL)successfully;

/**
 *  @author Toshiro Sugii, 15-12-17 17:12:40
 *
 *  Called whenever player or recorder is updated (currentTime)
 *
 *  @param playerRecorder Current TXAudioPlayerRecorder object
 *
 *  @since 1.0
 */
- (void)playerRecorderDidUpdate:(TXAudioPlayerRecorder * _Nonnull)playerRecorder;

@end


@interface TXAudioPlayerRecorder : NSObject <AVAudioRecorderDelegate>

/**
 *  NSURL of file - remote or local
 *
 *  @since 1.0
 */
@property (nonatomic, copy, nonnull) NSURL *fileURL;

/**
 *  Current player state
 *
 *  @since 1.0
 */
@property (atomic, readonly) TXAudioPlayerRecorderState state;

/**
 *  The delegate of the player
 *
 *  @see TXAudioPlayerRecorderDelegate
 *
 *  @since 1.0
 */
@property (nonatomic, weak, nullable) id<TXAudioPlayerRecorderDelegate> delegate;

/**
 *  Audio playback volume
 *
 *  @since 1.0
 */
@property (nonatomic, assign) float volume;

////////////////////////////////////////////////////////////////////////////////
/// @name Initialization
////////////////////////////////////////////////////////////////////////////////

/**
 *  Initializes TXAudioPlayerRecorder object with a specified url.
 *
 *  @param fileUrl url of the file - remote or local
 *
 *  @return TXAudioPlayerRecorder object
 *
 *  @since 1.0
 */
- (instancetype _Nonnull)initWithFileURL:(NSURL * _Nonnull )fileUrl;

////////////////////////////////////////////////////////////////////////////////
/// @name Controls
////////////////////////////////////////////////////////////////////////////////

/**
 *  Calls prepareToPlay and start playing as soon as preparation is finished
 *
 *  @return YES if preparation call started correctly. Otherwise, returns NO.
 *
 *  @since 1.0
 */
- (BOOL)play;

/**
 *  Start buffering the audio file.
 *
 *  @return YES if preparation call started correctly. Otherwise, returns NO.
 *
 *  @since 1.0
 */
- (BOOL)prepareToPlay;

/**
 *  Calls prepareToRecord and start recording as soon as preparation is finished.
 *
 *  @return YES if preparation call started correctly. Otherwise, returns NO.
 *
 *  @since 1.0
 */
- (BOOL)record;

/**
 *  Initializes the recorder internal object and start preparing for record.
 *
 *  @return YES if preparation call started correctly. Otherwise, returns NO.
 *
 *  @since 1.0
 */
- (BOOL)prepareToRecord;

/**
 *  Pauses the playback (or record) audio.
 *
 *  @since 1.0
 */
- (void)pause;

/**
 *  Moves the playback cursor to a given time.
 *
 *  @param seekTime The time to which to move the playback cursor. In seconds.
 *
 *  @since 1.0
 */
- (void)seekToTime:(NSTimeInterval)seekTime;

/**
 *  Current playback (or recording) time.
 *  Valid only in TXAudioPlayerRecorderStatePlaying or TXAudioPlayerRecorderStateRecording states
 *
 *  @return The current playback time or the current recording time.
 *
 *  @since 1.0
 */
- (NSTimeInterval)currentTime;

/**
 *  Audio duration
 *  Valid only in TXAudioPlayerRecorderStatePlaying or TXAudioPlayerRecorderStatePreparedToPlay states
 *
 *  @return The audio duration time.
 *
 *  @since 1.0
 */
- (NSTimeInterval)duration;

@end

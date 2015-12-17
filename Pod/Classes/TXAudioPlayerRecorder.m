//
//  TXAudioPlayerRecorder.m
//  Pods
//
//  Created by Toshiro Sugii on 9/25/15.
//
//

#import "TXAudioPlayerRecorder.h"

@interface TXAudioPlayerRecorder ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVAudioRecorder *avRecorder;
@property (nonatomic, strong) AVAudioSession *audioSession;

@property (atomic, readwrite) TXAudioPlayerRecorderState state;

- (void)reset;
- (void)resetTimer;
- (void)handleTimer;

- (void)registerNotifications;
- (void)unregisterNotifications;

- (void)playerItemDidPlayToEndTimeNotification;
- (void)playerItemFailedToPlayToEndTimeNotification;
- (void)playerItemTimeJumpedNotification;
- (void)playerItemNewAccessLogEntryNotification:(AVPlayerItem *)item;
- (void)playerItemNewErrorLogEntryNotification:(AVPlayerItem *)item;
- (void)audioSessionInterruptionNotification;

@end

@implementation TXAudioPlayerRecorder

- (instancetype)init
{
    if ((self = [super init]))
    {
        if (!_audioSession)
        {
            _audioSession = [AVAudioSession sharedInstance];
            
            NSError *err = nil;
            [_audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&err];
            if(err) {
                NSLog(@"audioSession: %@ %d %@", [err domain], (int)[err code], [[err userInfo] description]);
                return nil;
            }
            [_audioSession setActive:YES error:&err];
            
            err = nil;
            if(err) {
                NSLog(@"audioSession: %@ %d %@", [err domain], (int)[err code], [[err userInfo] description]);
                return nil;
            }
        }
        
        _state = TXAudioPlayerRecorderStateNone;
    }
    return self;
}

- (instancetype)initWithFileURL:(NSURL *)fileUrl
{
    if ((self = [self init]))
    {
        _fileURL = fileUrl;
    }
    return self;
}

- (void)dealloc
{
    [self reset];
    [self resetTimer];
}

- (void)setFileURL:(NSURL *)fileURL
{
    _fileURL = fileURL;
    
    [self reset];
    [self resetTimer];
}

- (BOOL)play
{
    switch (self.state)
    {
        case TXAudioPlayerRecorderStateNone:
        case TXAudioPlayerRecorderStatePaused:
        {
            if ([self prepareToPlay])
                return [self play];
            else
                return NO;
        }
        case TXAudioPlayerRecorderStatePlaying:
        case TXAudioPlayerRecorderStatePreparingToPlayAndPlaying:
        {
            return YES;
        }
        case TXAudioPlayerRecorderStatePreparingToPlay:
        {
            self.state = TXAudioPlayerRecorderStatePreparingToPlayAndPlaying;
            return YES;
        }
        case TXAudioPlayerRecorderStatePreparedToPlay:
        {
            [self.avPlayer play];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
            
            self.state = TXAudioPlayerRecorderStatePlaying;
            
            return YES;
        }
        case TXAudioPlayerRecorderStateRecording:
        case TXAudioPlayerRecorderStatePreparingToRecord:
        case TXAudioPlayerRecorderStatePreparedToRecord:
        case TXAudioPlayerRecorderStatePreparingToRecordAndRecording:
        {
            @throw [NSException exceptionWithName:@"TXAudioPlayerRecorderState" reason:@"Recording states conflicts with Playing states" userInfo:nil];
        }
        default:
            return NO;
    }
}

- (BOOL)record
{
    switch (self.state)
    {
        case TXAudioPlayerRecorderStateNone:
        case TXAudioPlayerRecorderStatePaused:
        {
            if ([self prepareToRecord])
                return [self record];
            else
                return NO;
        }
        case TXAudioPlayerRecorderStatePlaying:
        case TXAudioPlayerRecorderStatePreparingToPlay:
        case TXAudioPlayerRecorderStatePreparedToPlay:
        case TXAudioPlayerRecorderStatePreparingToPlayAndPlaying:
        {
            @throw [NSException exceptionWithName:@"TXAudioPlayerRecorderState" reason:@"Playing states conflicts with Recording states" userInfo:nil];
        }
        case TXAudioPlayerRecorderStateRecording:
        case TXAudioPlayerRecorderStatePreparingToRecordAndRecording:
        {
            return YES;
        }
        case TXAudioPlayerRecorderStatePreparingToRecord:
        {
            self.state = TXAudioPlayerRecorderStatePreparingToRecordAndRecording;
            return YES;
        }
        case TXAudioPlayerRecorderStatePreparedToRecord:
        {
            self.avRecorder.delegate = self;
            [self.avRecorder record];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
            
            self.state = TXAudioPlayerRecorderStateRecording;
            
            return YES;
        }
        default:
            return NO;
    }
}

- (void)pause
{
    [self resetTimer];
    
    switch (self.state)
    {
        case TXAudioPlayerRecorderStatePlaying:
        case TXAudioPlayerRecorderStatePreparingToPlay:
        case TXAudioPlayerRecorderStatePreparedToPlay:
        case TXAudioPlayerRecorderStatePreparingToPlayAndPlaying:
        {
            [self.avPlayer pause];
        }
        case TXAudioPlayerRecorderStateRecording:
        case TXAudioPlayerRecorderStatePreparingToRecord:
        case TXAudioPlayerRecorderStatePreparedToRecord:
        case TXAudioPlayerRecorderStatePreparingToRecordAndRecording:
        {
            if (self.avRecorder)
            {
                self.avRecorder.delegate = nil;
                [self.avRecorder stop];
                self.avRecorder = nil;
            }
        }
        default:
            break;
    }
    
    self.state = TXAudioPlayerRecorderStatePaused;
}

- (BOOL)prepareToPlay
{
    switch (self.state)
    {
        case TXAudioPlayerRecorderStateNone:
        case TXAudioPlayerRecorderStatePaused:
        {
            self.state = TXAudioPlayerRecorderStatePreparingToPlay;
            break;
        }
        case TXAudioPlayerRecorderStatePlaying:
        case TXAudioPlayerRecorderStatePreparingToPlay:
        case TXAudioPlayerRecorderStatePreparedToPlay:
        case TXAudioPlayerRecorderStatePreparingToPlayAndPlaying:
        {
            return YES;
        }
        case TXAudioPlayerRecorderStateRecording:
        case TXAudioPlayerRecorderStatePreparingToRecord:
        case TXAudioPlayerRecorderStatePreparedToRecord:
        case TXAudioPlayerRecorderStatePreparingToRecordAndRecording:
        {
            @throw [NSException exceptionWithName:@"TXAudioPlayerRecorderState" reason:@"Recording states conflicts with Playing states" userInfo:nil];
        }
    }
    
    if (!self.avPlayer)
    {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.fileURL options:nil];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        self.avPlayer = [AVPlayer playerWithPlayerItem:item];
        if (self.avPlayer)
        {
            [self registerNotifications];
        }
        else
        {
            NSLog(@"Cannot create AVAudioPlayer");
            return NO;
        }
    }
    else
    {
        self.state = TXAudioPlayerRecorderStatePreparedToPlay;
    }
    return YES;
}

- (BOOL)prepareToRecord
{
    switch (self.state)
    {
        case TXAudioPlayerRecorderStateNone:
        case TXAudioPlayerRecorderStatePaused:
        {
            [self reset];
            self.state = TXAudioPlayerRecorderStatePreparingToRecord;
            break;
        }
        case TXAudioPlayerRecorderStateRecording:
        case TXAudioPlayerRecorderStatePreparingToRecord:
        case TXAudioPlayerRecorderStatePreparedToRecord:
        case TXAudioPlayerRecorderStatePreparingToRecordAndRecording:
        {
            return YES;
        }
        case TXAudioPlayerRecorderStatePlaying:
        case TXAudioPlayerRecorderStatePreparingToPlay:
        case TXAudioPlayerRecorderStatePreparedToPlay:
        case TXAudioPlayerRecorderStatePreparingToPlayAndPlaying:
        {
            @throw [NSException exceptionWithName:@"TXAudioPlayerRecorderState" reason:@"Playing states conflicts with Recording states" userInfo:nil];
        }
    }
    
    __block TXAudioPlayerRecorder * __weak selfObject = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Configure recording parameters
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:16000.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
        
        NSError *err;
        selfObject.avRecorder = [[AVAudioRecorder alloc] initWithURL:selfObject.fileURL settings:recordSetting error:&err];
        if (err)
        {
            NSLog(@"Cannot record audio file - error: %@", [err localizedDescription]);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [selfObject pause];
                
                if (selfObject.delegate && [selfObject.delegate respondsToSelector:@selector(playerRecorder:didPrepareRecorderSuccessfully:)])
                    [selfObject.delegate playerRecorder:self didPrepareRecorderSuccessfully:NO];
            });
            
            return;
        }
        
        if ([selfObject.avRecorder prepareToRecord])
        {
#if DEBUG
            NSLog(@"Recording prepared To Record");
#endif
            dispatch_async(dispatch_get_main_queue(), ^{
                if (selfObject.state == TXAudioPlayerRecorderStatePreparingToRecordAndRecording)
                {
                    selfObject.state = TXAudioPlayerRecorderStatePreparedToRecord;
                    [selfObject record];
                }
                else
                    selfObject.state = TXAudioPlayerRecorderStatePreparedToRecord;
                
                if (selfObject.delegate && [selfObject.delegate respondsToSelector:@selector(playerRecorder:didPrepareRecorderSuccessfully:)])
                    [selfObject.delegate playerRecorder:self didPrepareRecorderSuccessfully:YES];
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [selfObject pause];
                
                if (selfObject.delegate && [selfObject.delegate respondsToSelector:@selector(playerRecorder:didPrepareRecorderSuccessfully:)])
                    [selfObject.delegate playerRecorder:self didPrepareRecorderSuccessfully:NO];
            });
        }
    });
    
    return YES;
}

- (NSTimeInterval)duration
{
    NSTimeInterval result = 0;
    if (self.state == TXAudioPlayerRecorderStatePlaying ||
        self.state == TXAudioPlayerRecorderStatePreparedToPlay)
    {
        CMTime duration = self.avPlayer.currentItem.asset.duration;
        if (duration.flags == kCMTimeFlags_Valid)
            result = CMTimeGetSeconds(duration);
    }
    return result;
}

- (NSTimeInterval)currentTime
{
    if (self.state == TXAudioPlayerRecorderStatePlaying)
    {
        CMTime time = self.avPlayer.currentItem.currentTime;
        return time.value / (float)time.timescale;
    }
    
    if (self.state == TXAudioPlayerRecorderStateRecording)
    {
        return self.avRecorder.currentTime;
    }
    
    // TODO: tratar
    return 0;
}

- (void)seekToTime:(NSTimeInterval)seekTime
{
    if (self.state == TXAudioPlayerRecorderStatePlaying)
        [self pause];
    
    if (self.state == TXAudioPlayerRecorderStatePaused)
    {
        CMTime seekingCM = CMTimeMakeWithSeconds(seekTime, 1000);
        [self.avPlayer seekToTime:seekingCM
                  toleranceBefore:kCMTimeZero
                   toleranceAfter:kCMTimePositiveInfinity];
    }
}

#pragma mark -
#pragma mark Privates

- (void)reset
{
    if (self.avPlayer)
    {
        [self.avPlayer pause];
        [self unregisterNotifications];
        
        self.avPlayer = nil;
    }
    
    if (self.avRecorder)
    {
        self.avRecorder.delegate = nil;
        [self.avRecorder stop];
        self.avRecorder = nil;
    }
    
    self.state = TXAudioPlayerRecorderStateNone;
}

- (void)resetTimer
{
    if (self.timer)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)handleTimer
{
    if (self.state == TXAudioPlayerRecorderStatePlaying && self.avPlayer)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerRecorderDidUpdate:)])
        {
            [self.delegate playerRecorderDidUpdate:self];
        }
    }
    
    if (self.state == TXAudioPlayerRecorderStateRecording && self.avRecorder)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(playerRecorderDidUpdate:)])
        {
            [self.delegate playerRecorderDidUpdate:self];
        }
    }
}

- (void)playerItemDidPlayToEndTimeNotification
{
    NSLog(@"playerItemDidPlayToEndTimeNotification");
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerRecorder:willFinishSuccessfully:)])
        [self.delegate playerRecorder:self willFinishSuccessfully:YES];
    
    [self pause];
    [self.avPlayer seekToTime:kCMTimeZero];
}

- (void)playerItemFailedToPlayToEndTimeNotification
{
    NSLog(@"playerItemFailedToPlayToEndTimeNotification");
}

- (void)playerItemTimeJumpedNotification
{
    NSLog(@"playerItemTimeJumpedNotification");
}

- (void)playerItemNewAccessLogEntryNotification:(AVPlayerItem *)item
{
    NSLog(@"playerItemNewAccessLogEntryNotification %@", item);
}

- (void)playerItemNewErrorLogEntryNotification:(AVPlayerItem *)item
{
    NSLog(@"playerItemNewErrorLogEntryNotification %@", item);
}

- (void)audioSessionInterruptionNotification
{
    NSLog(@"audioSessionInterruptionNotification");

    if (self.delegate && [self.delegate respondsToSelector:@selector(playerRecorder:willFinishSuccessfully:)])
        [self.delegate playerRecorder:self willFinishSuccessfully:NO];
    
    [self pause];
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEndTimeNotification)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemFailedToPlayToEndTimeNotification)
                                                 name:AVPlayerItemFailedToPlayToEndTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemTimeJumpedNotification)
                                                 name:AVPlayerItemTimeJumpedNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemNewAccessLogEntryNotification:)
                                                 name:AVPlayerItemNewAccessLogEntryNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemNewErrorLogEntryNotification:)
                                                 name:AVPlayerItemNewErrorLogEntryNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioSessionInterruptionNotification)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    [self.avPlayer addObserver:self forKeyPath:@"status" options:(NSKeyValueObservingOptionNew |
                                                                  NSKeyValueObservingOptionInitial |
                                                                  NSKeyValueObservingOptionPrior |
                                                                  NSKeyValueObservingOptionOld) context:nil];
}

- (void)unregisterNotifications
{
    [self.avPlayer removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemNewAccessLogEntryNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemNewErrorLogEntryNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"])
    {
        if (self.avPlayer.status == AVPlayerStatusReadyToPlay)
        {
#if DEBUG
            NSLog(@"AVPlayerStatusReadyToPlay");
#endif
            TXAudioPlayerRecorderState oldState = self.state;
            self.state = TXAudioPlayerRecorderStatePreparedToPlay;
            
            if ([self duration] > 0)
            {
                if (oldState == TXAudioPlayerRecorderStatePreparingToPlayAndPlaying)
                    [self play];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(playerRecorder:didPreparePlayerSuccessfully:)])
                    [self.delegate playerRecorder:self didPreparePlayerSuccessfully:YES];
            }
            else
            {
#if DEBUG
                NSLog(@"AVPlayerStatusReadyToPlay - Failed");
#endif
                if (self.delegate && [self.delegate respondsToSelector:@selector(playerRecorder:didPreparePlayerSuccessfully:)])
                    [self.delegate playerRecorder:self didPreparePlayerSuccessfully:NO];
                
                [self pause];
            }
        }
        else if (self.avPlayer.status == AVPlayerStatusFailed)
        {
#if DEBUG
            NSLog(@"AVPlayerStatusFailed");
#endif
            if (self.delegate && [self.delegate respondsToSelector:@selector(playerRecorder:willFinishSuccessfully:)])
                [self.delegate playerRecorder:self willFinishSuccessfully:NO];
            
            [self pause];
        }
    }
}

#pragma mark -
#pragma mark AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
#if DEBUG
    NSLog(@"audioRecorderDidFinishRecording");
#endif
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerRecorder:willFinishSuccessfully:)])
        [self.delegate playerRecorder:self willFinishSuccessfully:flag];
    
    [self pause];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
#if DEBUG
    NSLog(@"audioRecorderEncodeErrorDidOccur");
#endif
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerRecorder:willFinishSuccessfully:)])
        [self.delegate playerRecorder:self willFinishSuccessfully:NO];
    
    [self pause];
}

@end

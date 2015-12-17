//
//  TXViewController.m
//  TXAudioPlayerRecorder
//
//  Created by Toshiro Sugii on 11/18/2015.
//  Copyright (c) 2015 Toshiro Sugii. All rights reserved.
//

#import "TXViewController.h"

@interface TXViewController ()

@property (nonatomic, strong) TXAudioPlayerRecorder *playerRecorder;

@property (nonatomic, weak) IBOutlet UIButton *btPlay, *btRecord;
@property (nonatomic, weak) IBOutlet UILabel *lbPlay, *lbRecord;

@end

@implementation TXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *appFolder = [pathList objectAtIndex:0];
    if (![[NSFileManager defaultManager] fileExistsAtPath:appFolder])
        [[NSFileManager defaultManager] createDirectoryAtPath:appFolder withIntermediateDirectories:YES attributes:nil error:nil];
    
    self.playerRecorder = [[TXAudioPlayerRecorder alloc] initWithFileURL:[NSURL fileURLWithPath:[appFolder stringByAppendingString:@"sound.m4a"]]];
    self.playerRecorder.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender
{
    if (self.playerRecorder.state == TXAudioPlayerRecorderStatePlaying)
    {
        self.btPlay.selected = NO;
        [self.playerRecorder pause];
    }
    else
    {
        self.lbPlay.text = @"0";
        self.btPlay.selected = YES;
        [self.playerRecorder play];
    }
}

- (IBAction)record:(id)sender
{
    if (self.playerRecorder.state == TXAudioPlayerRecorderStateRecording)
    {
        self.btRecord.selected = NO;
        [self.playerRecorder pause];
    }
    else
    {
        self.lbRecord.text = @"0";
        self.btRecord.selected = YES;
        [self.playerRecorder record];
    }
}

- (void)playerRecorderDidUpdate:(TXAudioPlayerRecorder * _Nonnull)playerRecorder
{
    if (playerRecorder.state == TXAudioPlayerRecorderStateRecording)
    {
        self.lbRecord.text = [NSString stringWithFormat:@"%f", playerRecorder.currentTime];
    }
    else if (playerRecorder.state == TXAudioPlayerRecorderStatePlaying)
    {
        self.lbPlay.text = [NSString stringWithFormat:@"%f", playerRecorder.currentTime];
    }
}

- (void)playerRecorder:(TXAudioPlayerRecorder * _Nonnull)playerRecorder willFinishSuccessfully:(BOOL)successfully
{
    if (playerRecorder.state == TXAudioPlayerRecorderStateRecording)
    {
        self.btRecord.selected = NO;
    }
    else if (playerRecorder.state == TXAudioPlayerRecorderStatePlaying)
    {
        self.btPlay.selected = NO;
    }
}

@end

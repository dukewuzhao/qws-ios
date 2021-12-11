//
//  SoundManager.m
//  G100
//
//  Created by Tilink on 15/6/24.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "SoundManager.h"

static SoundManager * sharedInstance = nil;

@interface SoundManager () {
    NSTimer * _timer;
}

@property (assign, nonatomic) NSInteger playerTime; //!< 播放时长 s

@end

@implementation SoundManager

+(instancetype)sharedManager {
    static dispatch_once_t onceTonken;
    dispatch_once(&onceTonken, ^{
        sharedInstance = [[SoundManager alloc]init];
    });
    
    return sharedInstance;
}

-(void)playAlertSoundWithSoundName:(NSString *)soundName isVibrate:(BOOL)isVibrate {
    [self playAlertSoundWithSoundName:soundName];
    
    if (isVibrate) {
        [self playAlertVibrate];
    }
}

-(void)playAlertSoundWithSoundName:(NSString *)soundName isVibrate:(BOOL)isVibrate time:(NSInteger)time {
    _playerTime = time;
    
    [self playAlertSoundWithSoundName:soundName];
    
    if (isVibrate) {
        [self playAlertVibrate];
    }
}

-(void)playAlertSoundWithSoundName:(NSString *)soundName {
    
    self.soundName = soundName;
    if (_isPlaying) {
        [self stopAlertSound];
    }
    
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:soundName ofType:nil];
    
    if (musicPath) {
        NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
        audioPlayer.numberOfLoops = NSIntegerMax;
        audioPlayer.volume = 1.0f;
        audioPlayer.delegate = self;
        
        if([audioPlayer isPlaying]) {
            [audioPlayer stop];
            self.isPlaying = NO;
        }else {
            [audioPlayer play];
            self.isPlaying = YES;
        }
    }
    
    if (0 != _playerTime) { // 用户设置的响铃时长
        _timer = [NSTimer timerWithTimeInterval:_playerTime target:self selector:@selector(stopAlertSound) userInfo:nil repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

-(void)stopAlertSound {
    [self stopAlertVibrate];
    
    if ([audioPlayer isPlaying]) {
        [audioPlayer stop];
        audioPlayer = nil;
        
        self.isPlaying = NO;
    }
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        DLog(@"声音播放结束");
    }
    
    // 播放完成后 -> 继续其他音乐APP 播放
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    if ([audioPlayer isPlaying]) {
        [audioPlayer stop];
        self.isPlaying = NO;
    }
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    if(flags == AVAudioSessionInterruptionOptionShouldResume && player != nil) {
        [self playAlertSoundWithSoundName:_soundName];
    }
}

#pragma mark - 持续振动
void soundCompleteCallbackPop() {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
-(void)playAlertVibrate {
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, soundCompleteCallbackPop, NULL);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}
-(void)stopAlertVibrate {
    AudioServicesDisposeSystemSoundID(kSystemSoundID_Vibrate);
    AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
}

- (void)trialListenRingtones:(NSString *)soundName ofType:(NSString *)ext cycleNumber:(NSInteger)cycleNumber {
    self.soundName = soundName;
    if (_isPlaying) {
        [self stopAlertSound];
    }
    
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:soundName ofType:ext];
    
    if (musicPath) {
        NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
        
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:nil];
        audioPlayer.numberOfLoops = cycleNumber;
        audioPlayer.volume = 1.0f;
        audioPlayer.delegate = self;
        
        if([audioPlayer isPlaying]) {
            [audioPlayer stop];
            self.isPlaying = NO;
        }else {
            [audioPlayer prepareToPlay];
            [audioPlayer play];
            self.isPlaying = YES;
        }
    }
}

@end

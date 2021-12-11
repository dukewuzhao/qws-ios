//
//  SoundManager.h
//  G100
//
//  Created by Tilink on 15/6/24.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface SoundManager : NSObject <AVAudioPlayerDelegate> {
    AVAudioPlayer *audioPlayer;
}

+(instancetype)sharedManager;

@property (assign, nonatomic) BOOL isPlaying;
@property (copy, nonatomic) NSString * soundName;

/**
 *  播放警告音
 *
 *  @param soundName 播放的文件名
 *  @param isVibrate 是否震动
 */
-(void)playAlertSoundWithSoundName:(NSString *)soundName isVibrate:(BOOL)isVibrate;

/**
 *  播放警告音
 *
 *  @param soundName 播放的文件名
 *  @param isVibrate 是否震动
 *  @param time      播放时长 s
 */
-(void)playAlertSoundWithSoundName:(NSString *)soundName isVibrate:(BOOL)isVibrate time:(NSInteger)time;

/**
 *  播放警告音
 *
 *  @param soundName 播放的文件名
 */
-(void)playAlertSoundWithSoundName:(NSString *)soundName;

-(void)stopAlertSound;

/**
 *  试听本地声音
 *
 *  @param soundName    资源名称
 *  @param ext          后缀
 *  @param cycleNumber  循环次数 默认一次
 */
- (void)trialListenRingtones:(NSString *)soundName ofType:(NSString *)ext cycleNumber:(NSInteger)cycleNumber;

@end

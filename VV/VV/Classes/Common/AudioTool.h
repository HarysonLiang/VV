//
//  AudioTool.h
//  V&V
//
//  Created by Haryson Liang on 5/17/14.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioTool : NSObject{
    AVAudioPlayer *musicPlayer;
    AVAudioPlayer *soundPlayer;
}

@property (nonatomic, retain)AVAudioPlayer* musicPlayer, *soundPlayer;

+ (AudioTool *)instance;
+ (void)releaseInstance;

-(void)audioMusicPlayWithName:(NSString*)name type:(NSString*)type;
-(void)audioSoundPlayWithName:(NSString*)name type:(NSString*)type;
-(void)stopMusicAndSound;

+(void)playSystemSound:(SystemSoundID)inSystemSoundID;

@end

//
//  AudioTool.cpp
//  V&V
//
//  Created by Haryson Liang on 5/17/14.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#include "AudioTool.h"
#include "Setting.h"
#import <AudioToolbox/AudioToolbox.h>

static AudioTool *audioTool = nil;

@implementation AudioTool

@synthesize musicPlayer, soundPlayer;

//-------------------------------------------------------------------------------
+ (AudioTool *)instance{
	if (audioTool == NULL){
        audioTool = [[self alloc] init];
    }
	return audioTool;
}

//-------------------------------------------------------------------------------
+ (void)releaseInstance{
	if (audioTool != NULL) {
		audioTool = NULL;
        [audioTool setMusicPlayer:NULL];
        [audioTool setSoundPlayer:NULL];
	}
}

//-------------------------------------------------------------------------------
- (id)init  {
	self = [super init];
	if (self == NULL)  return NULL;
    
	return self;
}

-(void)audioMusicPlayWithName:(NSString*)name type:(NSString*)type
{
    if (![[Setting getInstance] isOpenMusic]) {
        return;
    }
    
    if (musicPlayer != NULL) {
        [musicPlayer stop];
    }
    
    NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSError *err;
    self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];

    [musicPlayer prepareToPlay];
    [musicPlayer setNumberOfLoops:-1];
    
    [musicPlayer play];
}


-(void)audioSoundPlayWithName:(NSString*)name type:(NSString*)type
{
    if (![[Setting getInstance] isOpenMusic]) {
        return;
    }
    
    if (soundPlayer != NULL) {
        [soundPlayer stop];
    }
    
    NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    NSError *err;
    self.soundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&err];
    
    [soundPlayer prepareToPlay];
    
    [soundPlayer play];
}


-(void)stopMusicAndSound
{
    if (musicPlayer != NULL) {
        [musicPlayer stop];
    }
    
    if (soundPlayer != NULL) {
        [soundPlayer stop];
    }
}

+(void)playSystemSound:(SystemSoundID)inSystemSoundID
{
    if (![[Setting getInstance] isOpenMusic]) {
        return;
    }
    
    AudioServicesPlaySystemSound(inSystemSoundID);
}

@end

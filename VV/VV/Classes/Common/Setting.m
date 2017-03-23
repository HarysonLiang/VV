//
//  Setting.m
//  haryson
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import "Setting.h"

@implementation Setting

@synthesize isRestartGame;
@synthesize touchBestScore;
@synthesize gravityBestScore;
@synthesize isOpenMusic;
@synthesize mode;
@synthesize isRemoveAds;

//-------------------------------------------------------------------------------
// ref: objective-c singleton (google):
// http:// stackoverflow.com/questions/145154/what-does-your-objective-c-singleton-look-like
static Setting *setting = nil;

//-------------------------------------------------------------------------------
+ (Setting *)getInstance  {
	if (setting == nil){
        setting = [[self alloc] init];
    }
	return setting;
}

//-------------------------------------------------------------------------------
+ (void)releaseInstance  {
	if (setting != nil) {
		setting = nil;
	}
}

//-------------------------------------------------------------------------------
- (id)init  {
	self = [super init];
	if (self == nil)  return nil;
    
    self.isRestartGame = false;
    self.touchBestScore = 0;
    self.gravityBestScore = 0;
    self.isOpenMusic = YES;
    self.mode = TOUCH;
    self.isRemoveAds = NO;
    
	return self;
}



//-------------------------------------------------------------------------------
//Load本地存储的设置
- (void)loadSetting{
    NSUserDefaults* preferences = [NSUserDefaults standardUserDefaults];
    if (preferences == nil) {
        return;
    }
    
    self.isRestartGame = [(NSNumber*)[preferences objectForKey:KEY_SAVE_RESTART] boolValue];
    if (self.isRestartGame) {
        self.isOpenMusic = [(NSNumber*)[preferences objectForKey:KEY_SAVE_MUSIC] boolValue];
        self.touchBestScore = [(NSNumber*)[preferences objectForKey:KEY_SAVE_TOUCH_BEST] shortValue];
        self.gravityBestScore = [(NSNumber*)[preferences objectForKey:KEY_SAVE_GRAVITY_BEST] shortValue];
        self.mode = (MODE)[(NSNumber*)[preferences objectForKey:KEY_SAVE_MODE] shortValue];
        self.isRemoveAds = [(NSNumber*)[preferences objectForKey:KEY_SAVE_REMOVE_ADS] boolValue];
#ifdef DEBUG
        self.isRemoveAds = YES;
#endif
    } else {
        [self saveIsRestartGame:YES];
        [self saveIsOpenMusic:YES];
    }
}

- (void)saveIsRestartGame:(BOOL)flag
{
    self.isRestartGame = flag;
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if(preferences ==  nil){
        return;
    }
    [preferences setObject:[[NSNumber alloc] initWithBool:self.isRestartGame] forKey:KEY_SAVE_RESTART];
    [preferences synchronize];
}

- (void)saveIsOpenMusic:(BOOL)isOpen
{
    self.isOpenMusic = isOpen;
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if(preferences ==  nil){
        return;
    }
    [preferences setObject:[[NSNumber alloc] initWithBool:isOpenMusic] forKey:KEY_SAVE_MUSIC];
    [preferences synchronize];
}

- (void)saveTouchBestScore:(short)_touchBestScore
{
    self.touchBestScore = _touchBestScore;
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if(preferences ==  nil){
        return;
    }
    [preferences setObject:[[NSNumber alloc] initWithShort:self.touchBestScore] forKey:KEY_SAVE_TOUCH_BEST];
    [preferences synchronize];
}

- (void)saveGravityBestScore:(short)_gravityBestScore
{
    self.gravityBestScore = _gravityBestScore;
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if(preferences ==  nil){
        return;
    }
    [preferences setObject:[[NSNumber alloc] initWithShort:self.gravityBestScore] forKey:KEY_SAVE_GRAVITY_BEST];
    [preferences synchronize];
}

- (void)saveMode:(MODE)_mode
{
    self.mode = _mode;
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if(preferences ==  nil){
        return;
    }
    [preferences setObject:[[NSNumber alloc] initWithShort:(short)mode] forKey:KEY_SAVE_MODE];
    [preferences synchronize];
}

- (short)getBestScore
{
    switch (mode) {
        case TOUCH:     return touchBestScore;
        case GRAVITY:   return gravityBestScore;
            
        default:
            break;
    }
    return 0;
}

- (void)saveBestScore:(short)_bestScore
{
    switch (mode) {
        case TOUCH:     [self saveTouchBestScore:_bestScore];break;
        case GRAVITY:   [self saveGravityBestScore:_bestScore];break;
            
        default:
            break;
    }
}

- (void)saveIsRemoveAds:(BOOL)flag
{
    self.isRemoveAds = flag;
    
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    if(preferences ==  nil){
        return;
    }
    [preferences setObject:[[NSNumber alloc] initWithBool:self.isRemoveAds] forKey:KEY_SAVE_REMOVE_ADS];
    [preferences synchronize];
}

@end

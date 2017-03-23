//
//  Setting.h
//  V&V
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_SAVE_RESTART        @"KeySaveRestart"
#define KEY_SAVE_MUSIC          @"KeySaveMusic"
#define KEY_SAVE_TOUCH_BEST     @"KeySaveTouchBest"
#define KEY_SAVE_GRAVITY_BEST   @"KeySaveGravityBest"
#define KEY_SAVE_MODE           @"KeySaveMode"
#define KEY_SAVE_REMOVE_ADS     @"KeySaveRemoveAds"

typedef enum{
    TOUCH = 0,
    GRAVITY,
}MODE;

@interface Setting : NSObject{
    BOOL isRestartGame;//是否非首次打开Game
    short touchBestScore;
    short gravityBestScore;
    BOOL isOpenMusic;
    MODE mode;
    BOOL isRemoveAds;
}

@property (nonatomic, assign)BOOL isRestartGame;
@property (nonatomic, assign)short touchBestScore;
@property (nonatomic, assign)short gravityBestScore;
@property (nonatomic, assign)BOOL isOpenMusic;
@property (nonatomic, assign)MODE mode;
@property (nonatomic, assign)BOOL isRemoveAds;

//-------------------------------------------------------------------------------
+ (Setting *)getInstance;
+ (void)releaseInstance;
- (void)loadSetting;
- (void)saveIsRestartGame:(BOOL)flag;
- (void)saveIsOpenMusic:(BOOL)isOpen;
- (void)saveTouchBestScore:(short)_touchBestScore;
- (void)saveGravityBestScore:(short)_gravityBestScore;
- (void)saveMode:(MODE)_mode;
- (short)getBestScore;
- (void)saveBestScore:(short)_bestScore;
- (void)saveIsRemoveAds:(BOOL)flag;
@end

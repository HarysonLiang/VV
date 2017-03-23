//
//  GameCenterManager.h
//  V&V
//
//  Created by Haryson Liang on 12/24/14.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>


@interface GameCenterManager : NSObject<GKGameCenterControllerDelegate>
{
    BOOL _enableGameCenter;
}

+ (GameCenterManager *)getInstance;

// game center ----------------------------------------
/**
 登陆gamecenter，请先设置setViewController
 */
- (void)authenticateLocalPlayer;
/**
 上传积分
 */
- (void)reportScore : (NSString*)identifier hiScore:(int64_t)score;

/**
 上传成就
 */
- (void)reportAchievementIdentifier : (NSString*)identifier percentComplete:(float)percent;
/**
 显示排行版
 */
- (void)showLeaderboard : (NSString*)leaderboard;

/**
 显示成就
 */
- (void)showAchievements;
@end

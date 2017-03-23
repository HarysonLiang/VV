//
//  GameCenterManager.m
//  V&V
//
//  Created by Haryson Liang on 12/24/14.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import "GameCenterManager.h"
#import "ViewController.h"
#import "Setting.h"
#import "Language.h"

@implementation GameCenterManager

+ (GameCenterManager *)getInstance
{
    static GameCenterManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
    });
    return mgr;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initData];
        return self;
    }
    return nil;
}

- (void)initData
{
    _enableGameCenter = NO;
}

#pragma mark - GameCenter
- (void)authenticateLocalPlayer
{
    GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    if ([localPlayer isAuthenticated] == NO) {
        localPlayer.authenticateHandler = ^(UIViewController *viewController,
                                            NSError *error) {
            if (error) {
                _enableGameCenter = NO;
                //NSLog(@"error...%@",error);
            }else{
                _enableGameCenter = YES;
                if(viewController) {
                    [[ViewController sharedViewController] presentViewController:viewController animated:YES completion:nil];
                }
                [self reportScore:@"com.mobilegametree.zhong.touch" hiScore:[[Setting getInstance] touchBestScore]];
                [self reportScore:@"com.mobilegametree.zhong.gravity" hiScore:[[Setting getInstance] gravityBestScore]];
            }
        };
    }else{
        _enableGameCenter = YES;
        [self reportScore:@"com.mobilegametree.zhong.touch" hiScore:[[Setting getInstance] touchBestScore]];
        [self reportScore:@"com.mobilegametree.zhong.gravity" hiScore:[[Setting getInstance] gravityBestScore]];
    }
}

/**
 上传积分
 */
- (void)reportScore : (NSString*)identifier hiScore:(int64_t)score;
{
    if (score < 0 || !_enableGameCenter)
        return;
    GKScore *scoreBoard = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
    scoreBoard.value = score;
    [GKScore reportScores:@[scoreBoard] withCompletionHandler:^(NSError *error) {
        if (error) {
            // handle error
        }
    }];
}

/**
 上传成就
 */
- (void)reportAchievementIdentifier : (NSString*)identifier percentComplete:(float)percent
{
    if (percent < 0 || !_enableGameCenter)
        return;
    
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: identifier];
    if (achievement){
        achievement.percentComplete = percent;
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
            if (error) {
                // handle error
            }
        }];
    }
}

/**
 显示排行版
 */
- (void)showLeaderboard : (NSString*)leaderboard
{
    if (!_enableGameCenter){
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[Language getText:@"GAME_CENTER_UNAVAILABLE"]
                                                            message:[Language getText:@"SIGNED_IN_GC"]
                                                           delegate:self
                                                  cancelButtonTitle:NULL
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
        return;
    }
    GKGameCenterViewController *gameCenterViewController = [[GKGameCenterViewController alloc] init];
    gameCenterViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
    gameCenterViewController.gameCenterDelegate = self;
    [[ViewController sharedViewController] presentViewController:gameCenterViewController animated:YES completion:nil];
}

/**
 显示成就
 */
- (void)showAchievements
{
    if (!_enableGameCenter)
        return;
    
    GKGameCenterViewController *gameCenterViewController = [[GKGameCenterViewController alloc] init];
    gameCenterViewController.viewState = GKGameCenterViewControllerStateAchievements;
    gameCenterViewController.gameCenterDelegate = self;
    [[ViewController sharedViewController] presentViewController:gameCenterViewController animated:YES completion:nil];
}

#pragma mark gameCenterViewController Close回调
- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [[ViewController sharedViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end

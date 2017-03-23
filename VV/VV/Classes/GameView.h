//
//  GameView.h
//  V&V
//
//  Created by Haryson Liang on 12/7/14.
//  Copyright (c) 2014 MobileGameTree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICircleView.h"
#import "UIRoundHighlightView.h"
#import "TitleView.h"
#import "EndView.h"
#import <CoreMotion/CoreMotion.h>

typedef enum{
    INIT = 0,
    TITLE_WAITTING,
    LOGIC,
    FAIL,
    WIN,
    END_WAITTING,
    ABSORBING,
    RESTART,
    REVIVISCENCE,
    WIN_WAITTING,
}GAME_STAGE;

@interface GameView : UIView<UIDynamicAnimatorDelegate,UICollisionBehaviorDelegate,UIAlertViewDelegate>{
    GAME_STAGE stage;
    
    UICircleView* mainCircleView;
    UIRoundHighlightView* auraView;
    
    UICircleView* subCircleView;
    UILabel* scoreLabel;
    
    UILabel* bestScoreLabel;
    UILabel *modeLabel;
    
    int score;
    int absorbDistance;
    
    CGPoint lastMainCircleCenter;
    
    BOOL isHasBestNotice;
    
    TitleView* titleView;
    EndView* endView;
    
    CMMotionManager *motionManager;
}

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, readwrite) GAME_STAGE stage;
@property (nonatomic, readwrite) int score;

- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator;
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator;

//  Touch related
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;

- (void)initSubCircleView;

- (void)update;
- (void)doEndWaitting;
- (void)doTitleWaiting;
- (void)doInit;
- (void)doLogic;
- (void)doAbsorbing;
- (void)doFail;
- (void)doWin;
- (void)doWinWaitting;
- (void)doRestart;
- (void)doReviviscence;//复活
- (BOOL)isCollision;
- (void)resetSubCircleViewCenter;
- (BOOL)incScore;
- (void)updateCollisionBehavior;
- (void)processBestNotice;
- (BOOL)isWin;
- (float)growWidth;

- (void)updateGameView;

- (void)startUpdateAccelerometer;
- (void)stopUpdateAccelerometer;
- (void)updateBestScoreLabel;
- (void)updateModeLabel;

@end

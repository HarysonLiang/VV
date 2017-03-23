//
//  ViewController.h
//  V&V
//
//  Created by Haryson Liang on 12/6/14.
//  Copyright (c) 2014 MobileGameTree. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameView.h"
#import "LoadingView.h"

#ifdef ENABLE_IAD
#import <iAd/iAd.h>
#import <iAd/UIViewControlleriAdAdditions.h>
#endif

#ifdef ENABLE_VUNGLE
#import <VungleSDK/VungleSDK.h>
#endif

@interface ViewController : UIViewController
#ifdef ENABLE_IAD
<
ADInterstitialAdDelegate
>
#endif

#ifdef ENABLE_VUNGLE
<
VungleSDKDelegate
>
#endif
{
    NSTimer *timer;
    
    GameView* gameView;
    UIView* bgView;
    BOOL isHasCollisionNotice;
    
#ifdef ENABLE_IAD
    ADInterstitialAd *interstitial;
#endif
    
    LoadingView* loadingView;
}

@property (nonatomic,readwrite)BOOL isHasCollisionNotice;

#ifdef ENABLE_IAD
@property (nonatomic, retain)ADInterstitialAd *interstitial;
#endif

+ (ViewController *)sharedViewController;

- (void)startGame;
- (void)stopGame;

- (void)doLogic;
- (void)collisionBgAnimation;

#ifdef ENABLE_IAD
- (void)cycleInterstitial;
- (void)presentInterlude;
#endif

#ifdef ENABLE_VUNGLE
-(void)showAd;
//-(void)showAdWithOptions;
#endif

- (void)hiddenLoadingView:(BOOL)flag;

@end


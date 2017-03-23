//
//  ViewController.m
//  V&V
//
//  Created by Haryson Liang on 12/6/14.
//  Copyright (c) 2014 MobileGameTree. All rights reserved.
//

#import "ViewController.h"
#import "UILib.h"
#import "AudioTool.h"
#import "Common.h"
#import "GameCenterManager.h"
#import "PayTool.h"
#import "Setting.h"
#import "Language.h"

@interface ViewController ()
@end

#define BG_DEFAULT_COLOR    [UIColor grayColor]

static ViewController *sharedViewController = nil;

@implementation ViewController

#ifdef ENABLE_IAD
@synthesize interstitial;
#endif

@synthesize isHasCollisionNotice;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    sharedViewController = self;
    
    [UILib init:self.view.frame.size.width height:self.view.frame.size.height];
    
    NSLog(@"==(%f,%f)",self.view.frame.size.width,self.view.frame.size.height);
    
    bgView = [[UIView alloc] initWithFrame:self.view.frame];
    [bgView setBackgroundColor:BG_DEFAULT_COLOR];
    [self.view addSubview:bgView];
    
    CGRect rect = CGRectMake(0, 0, bgView.frame.size.width-(6*[UILib getSizeScale]), bgView.frame.size.height-(6*[UILib getSizeScale]));
    gameView = [[GameView alloc] initWithFrame:rect];
    [gameView setCenter:self.view.center];
    [self.view addSubview:gameView];
    
    [[GameCenterManager getInstance] authenticateLocalPlayer];
    
#ifdef ENABLE_IAD
    self.interstitial = nil;
    if (![[Setting getInstance] isRemoveAds]) {
        [self cycleInterstitial];
    }
#endif
    
#ifdef ENABLE_VUNGLE
    [[VungleSDK sharedSDK] setDelegate:self];
#endif

    [[PayTool getInstance] initPayList];
    [[PayTool getInstance] checkUndonePurchase];
    
    loadingView = [[LoadingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:loadingView];
    [self hiddenLoadingView:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// for ios6
//-------------------------------------------------------------------------------
- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)dealloc
{
#ifdef ENABLE_VUNGLE
    [[VungleSDK sharedSDK] setDelegate:nil];
#endif
}


//FOR iOS7（隐藏状态栏）
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//-------------------------------------------------------------------------------
+ (ViewController *)sharedViewController  {return sharedViewController;}

//-------------------------------------------------------------------------------
- (void)startGame
{
    NSLog(@"start game!!!");
    [[GameCenterManager getInstance] authenticateLocalPlayer];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0/60))
                                             target:self
                                           selector:@selector(doLogic) userInfo:nil repeats:TRUE];
}

- (void)stopGame
{
    [timer invalidate];
    timer = nil;
    
    [UIApplication sharedApplication].idleTimerDisabled=NO;
    NSLog(@"stop game!!!");
}

//-------------------------------------------------------------------------------
- (void)doLogic
{
    if (isHasCollisionNotice) {
        [self setIsHasCollisionNotice:NO];
        [[AudioTool instance] audioSoundPlayWithName:COLLISION_SOUND type:@"WAV"];
        [self collisionBgAnimation];
    }
    
    if ([[PayTool getInstance] getPayStatus] == P_SUCCESS) {
        [[Setting getInstance] saveIsRemoveAds:YES];
#ifdef ENABLE_IAD
        self.interstitial = NULL;
#endif
        [[PayTool getInstance] setPayStatus:P_NONE];
        [self hiddenLoadingView:YES];
        
        //The Ads & Pop-ups is removed!
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NULL
                                                            message:[Language getText:@"THANKS_TIP"]
                                                           delegate:self
                                                  cancelButtonTitle:NULL
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    
    if ([[PayTool getInstance] getPayStatus] == P_FAIL) {
        [[PayTool getInstance] setPayStatus:P_NONE];
        [self hiddenLoadingView:YES];
    }
    
    if (gameView != NULL) {
        [gameView  update];
    }
}

//-------------------------------------------------------------------------------
- (void)collisionBgAnimation
{
    if (bgView == NULL) {
        return;
    }
    [bgView setBackgroundColor:BG_DEFAULT_COLOR];
    
    //AudioServicesPlaySystemSound(1109);//撞击提示音
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);//iPhone震动效果
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         [bgView setBackgroundColor:[UIColor whiteColor]];
                     }completion:^(BOOL finish){
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              [bgView setBackgroundColor:[UIColor blackColor]];
                                          }completion:^(BOOL finish){
                                              [UIView animateWithDuration:0.3
                                                               animations:^{
                                                                   [bgView setBackgroundColor:BG_DEFAULT_COLOR];
                                                               }completion:^(BOOL finish){
                                                                   //[self tapLabelAnimation];
                                                               }];
                                          }];
                     }];
}

#pragma mark -
#pragma mark Interstitial Management
//========================================================================================================================
#ifdef ENABLE_IAD
- (void)cycleInterstitial
{
    // Clean up the old interstitial...
    if (self.interstitial != nil) {
        self.interstitial.delegate = nil;
        self.interstitial = nil;
    }
    // and create a new interstitial. We set the delegate so that we can be notified of when
    self.interstitial = [[ADInterstitialAd alloc] init];
    self.interstitial.delegate = self;
}

- (void)presentInterlude
{
    if (self.interstitial == nil) {
        return;
    }
    // If the interstitial managed to load, then we'll present it now.
    if (self.interstitial.loaded) {
        //[self requestInterstitialAdPresentation];//用这个每次重新开游戏只能显示一次广告
         [interstitial presentFromViewController:self];
     }
}

#pragma mark ADInterstitialViewDelegate methods

// When this method is invoked, the application should remove the view from the screen and tear it down.
// The content will be unloaded shortly after this method is called and no new content will be loaded in that view.
// This may occur either when the user dismisses the interstitial view via the dismiss button or
// if the content in the view has expired.
- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd
{
    [self cycleInterstitial];
}

// This method will be invoked when an error has occurred attempting to get advertisement content.
// The ADError enum lists the possible error codes.
- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    [self cycleInterstitial];
}
#endif
//========================================================================================================================


#ifdef ENABLE_VUNGLE

#pragma mark - VungleSDK Delegate
- (void)vungleSDKhasCachedAdAvailable {
    NSLog(@"A new cached ad has been downloaded");
}

- (void)vungleSDKwillShowAd {
    NSLog(@"An ad is about to be played!");
    //Use this delegate method to pause animations, sound, etc.
}

- (void) vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet {
    if (willPresentProductSheet) {
        //In this case we don't want to resume animations and sound, the user hasn't returned to the app yet
        NSLog(@"The ad presented was tapped and the user is now being shown the App Product Sheet");
        NSLog(@"ViewInfo Dictionary:");
        for(NSString * key in [viewInfo allKeys]) {
            NSLog(@"%@ : %@", key, [[viewInfo objectForKey:key] description]);
        }
    } else {
        //In this case the user has declined to download the advertised application and is now returning fully to the main app
        //Animations / Sound / Gameplay can be resumed now
        NSLog(@"The ad presented was not tapped - the user has returned to the app");
        NSLog(@"ViewInfo Dictionary:");
        for(NSString * key in [viewInfo allKeys]) {
            NSLog(@"%@ : %@", key, [[viewInfo objectForKey:key] description]);
        }
    }
}

- (void)vungleSDKwillCloseProductSheet:(id)productSheet {
    NSLog(@"The user has downloaded an advertised application and is now returning to the main app");
    //This method can be used to resume animations, sound, etc. if a user was presented a product sheet earlier
}

-(void)showAd
{
    if ([[Setting getInstance] isRemoveAds]) {
        return;
    }
    
    // Play a Vungle ad (with default options)
    VungleSDK* sdk = [VungleSDK sharedSDK];
    
    if (![sdk isCachedAdAvailable]) {
        return;
    }
    
    NSError *error;
    [sdk playAd:self error:&error];
    if (error) {
        NSLog(@"Error encountered playing ad: %@", error);
    }
}

// Play a Vungle ad (with customized options)
/*
-(void)showAdWithOptions
{
    // Grab instance of Vungle SDK
    VungleSDK* sdk = [VungleSDK sharedSDK];
    
    // Dict to set custom ad options
    NSDictionary* options = @{VunglePlayAdOptionKeyOrientations: @(UIInterfaceOrientationMaskLandscape),
                              VunglePlayAdOptionKeyIncentivized: @(YES),
                              VunglePlayAdOptionKeyUser: @"user",
                              // Use this to keep track of metrics about your users
                              VunglePlayAdOptionKeyExtraInfoDictionary: @{VunglePlayAdOptionKeyExtra1: @"21",
                                                                          VunglePlayAdOptionKeyExtra2: @"Female"}};
    
    // Pass in dict of options, play ad
    NSError *error;
    [sdk playAd:self withOptions:options error:&error];
    if (error) {
        NSLog(@"Error encountered playing ad: %@", error);
    }
}
 */
#endif

- (void)hiddenLoadingView:(BOOL)flag
{
    if (loadingView == NULL) {
        return;
    }
    [loadingView setHidden:flag];
    if (!flag) {
        [self.view bringSubviewToFront:loadingView];
    }
}
@end

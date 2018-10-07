//
//  EndView.m
//  V&V
//
//  Created by Haryson Liang on 12/22/14.
//  Copyright (c) 2014 MobileGameTree. All rights reserved.
//

#import "EndView.h"
#import "UILib.h"
#import "GameView.h"
#import "Tools.h"
#import "Common.h"
#import "Setting.h"
#import "ViewController.h"
#import "GameCenterManager.h"
#import "PayTool.h"
#import "AudioTool.h"
#import "Language.h"

#ifdef ENABLE_GOOGLE_BANNER
#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADRequest.h>
#endif

#define BUTTON_SELECTED_COLOR   [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1]
#define BUTTON_UNSELECT_COLOR   [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]

#define ALERT_TAG_PAY   1

@implementation EndView

#ifdef ENABLE_IAD
@synthesize bannerView;
#endif

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView* bgView = [[UIView alloc] initWithFrame:frame];
        [bgView setBackgroundColor:[UIColor grayColor]];
        [bgView setAlpha:0.95f];
        [self addSubview:bgView];
        
        CGSize sButSize = CGSizeMake(20, 10);
        UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, sButSize.width, sButSize.height)];
        [switchButton setOnTintColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
        [switchButton setOn:[[Setting getInstance] isOpenMusic] animated:YES];
        [switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:switchButton];
        CGPoint pos = CGPointMake(frame.size.width-switchButton.frame.size.width, 0);
        [switchButton setFrame:CGRectMake(pos.x, pos.y, switchButton.frame.size.width, switchButton.frame.size.height)];
        
        UILabel* soundLabel = [[UILabel alloc] init];
        soundLabel.font = [UIFont systemFontOfSize:10];
        soundLabel.backgroundColor = [UIColor clearColor];
        soundLabel.text = [Language getText:@"SOUND"];
        [soundLabel sizeToFit];
        [self addSubview:soundLabel];
        [soundLabel setFrame:CGRectMake(switchButton.frame.origin.x+(switchButton.frame.size.width-soundLabel.frame.size.width)/2, switchButton.frame.origin.y+switchButton.frame.size.height, soundLabel.frame.size.width, soundLabel.frame.size.height)];
        
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
        [self addSubview:infoButton];
        [infoButton setFrame:CGRectMake(0, 0, infoButton.frame.size.width, infoButton.frame.size.height)];
        [infoButton addTarget:self action:@selector(doInfoAction:) forControlEvents:UIControlEventTouchUpInside];
        
        endLabel = [[UILabel alloc] init];
        endLabel.font = [UIFont systemFontOfSize:120*[UILib getSizeScale]];
        endLabel.textAlignment = NSTextAlignmentCenter;
        endLabel.backgroundColor = [UIColor clearColor];
        endLabel.text = [Language getText:@"END"];
        endLabel.textColor = DEFAULT_TEXT_COLOR;
        [endLabel sizeToFit];
        [self addSubview:endLabel];
        
        pos = [UILib offset:CGPointMake(0, 0) size:endLabel.frame.size superSize:self.frame.size anchor:ANCHOR_CENTER];
        [endLabel setFrame:CGRectMake(pos.x, pos.y, endLabel.frame.size.width, endLabel.frame.size.height)];
        endLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        [UIView animateWithDuration:1.0
                         animations:^{
                             endLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }completion:^(BOOL finish){
                              [UIView animateWithDuration:0.5
                                               animations:^{
                                                   endLabel.transform = CGAffineTransformMakeScale(0.5, 0.5);
                                                   endLabel.center = CGPointMake(self.frame.size.width/2, endLabel.frame.size.height);
                                               }completion:^(BOOL finish){
                                                   [self scoreAnimation];
                                               }];
                         }];
        
#ifdef ENABLE_IAD
        self.bannerView = nil;
        if (![[Setting getInstance] isRemoveAds]) {
            [self initBannerView];
        }
#endif
        
#ifdef ENABLE_GOOGLE_BANNER
        @autoreleasepool{
            [self initGoogleBannerView];
        }
#endif
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark -
#pragma mark Touch related
//-------------------------------------------------------------------------------
//  Touches is event-based, no update no new event
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event  {
}

//-------------------------------------------------------------------------------
//  Touches is event-based, no update no new event
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event  {
}

//-------------------------------------------------------------------------------
//  Touches is event-based, no update no new event
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event  {
}

- (void)scoreAnimation
{
    UILabel* scoreLabel = [[UILabel alloc] init];
    [scoreLabel setFont:[UIFont systemFontOfSize:25*[UILib getSizeScale]]];
    NSString* text = [NSString stringWithFormat:[Language getText:@"GET_SCORE"],[Tools generateScoreString:[(GameView*)[self superview] score]]];
    [scoreLabel setText:text];
    [scoreLabel setTextColor:DEFAULT_TEXT_COLOR];
    [scoreLabel sizeToFit];
    [self addSubview:scoreLabel];
    
    [scoreLabel setCenter:CGPointMake(-scoreLabel.frame.size.width/2, endLabel.center.y+endLabel.frame.size.height)];
    
    UILabel* bestScoreLabel = [[UILabel alloc] init];
    [bestScoreLabel setFont:[UIFont systemFontOfSize:25*[UILib getSizeScale]]];
    NSString* modeStr = [[Setting getInstance] mode] == TOUCH ? [Language getText:@"TOUCH_MODE"] : [Language getText:@"GRAVITY_MODE"];
    text = [NSString stringWithFormat:[Language getText:@"BEST_SCORE"], modeStr, [Tools generateScoreString:[[Setting getInstance] getBestScore]]];
    [bestScoreLabel setText:text];
    [bestScoreLabel setTextColor:DEFAULT_TEXT_COLOR];
    [bestScoreLabel sizeToFit];
    [self addSubview:bestScoreLabel];
    
    [bestScoreLabel setCenter:CGPointMake(-bestScoreLabel.frame.size.width/2, scoreLabel.center.y+scoreLabel.frame.size.height)];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         scoreLabel.center = CGPointMake(self.frame.size.width/2, scoreLabel.center.y);
                     }completion:^(BOOL finish){
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              bestScoreLabel.center = CGPointMake(self.frame.size.width/2, bestScoreLabel.center.y);
                                          }completion:^(BOOL finish){
                                              //TODO 检测是否为新纪录，新纪录效果循环显示动画
                                              [self buttonAnimation];
                                          }];
                     }];

}

- (void)buttonAnimation
{
    CGRect RECT_1 = CGRectMake(0, 0, 120*[UILib getScaleX], 40*[UILib getScaleY]);
    CGRect RECT_2 = CGRectMake(0, 0, 80*[UILib getScaleX], 40*[UILib getScaleY]);
    
    UIButton *leaderboardBtn = [self addButton:RECT_1 title: [Language getText:@"LEADERBOARD"] action:@selector(doLeaderboard:)];
    float intervalX = (self.frame.size.width-leaderboardBtn.frame.size.width*2)/3;
    CGPoint point = CGPointMake(intervalX, self.frame.size.height/2-leaderboardBtn.frame.size.height);
    leaderboardBtn.frame = CGRectMake(point.x, point.y, leaderboardBtn.frame.size.width, leaderboardBtn.frame.size.height);
    
    UIButton* tryAgainBtn = [self addButton:RECT_1 title:[Language getText:@"TRY_AGAIN"] action:@selector(doTryAgain:)];
    point = CGPointMake(leaderboardBtn.frame.origin.x+leaderboardBtn.frame.size.width+intervalX, leaderboardBtn.frame.origin.y);
    tryAgainBtn.frame = CGRectMake(point.x, point.y, tryAgainBtn.frame.size.width, tryAgainBtn.frame.size.height);
    
    UIButton* shareBtn = [self addButton:RECT_2 title:[Language getText:@"SHARE"] action:@selector(doShare:)];
    intervalX = (self.frame.size.width-shareBtn.frame.size.width*3)/4;
    float intervalY = 15*[UILib getScaleY];
    point = CGPointMake(intervalX, leaderboardBtn.frame.origin.y+leaderboardBtn.frame.size.height+intervalY);
    shareBtn.frame = CGRectMake(point.x, point.y, shareBtn.frame.size.width, shareBtn.frame.size.height);
    
    UIButton* helpBtn = [self addButton:RECT_2 title:[Language getText:@"HELP"] action:@selector(doHelp:)];
    point = CGPointMake(shareBtn.frame.origin.x+shareBtn.frame.size.width+intervalX, shareBtn.frame.origin.y);
    helpBtn.frame = CGRectMake(point.x, point.y, helpBtn.frame.size.width, helpBtn.frame.size.height);
    
    UIButton* rateBtn = [self addButton:RECT_2 title:[Language getText:@"RATE"] action:@selector(doRate:)];
    point = CGPointMake(helpBtn.frame.origin.x+helpBtn.frame.size.width+intervalX, helpBtn.frame.origin.y);
    rateBtn.frame = CGRectMake(point.x, point.y, rateBtn.frame.size.width, rateBtn.frame.size.height);
    
    MODE mode = [[Setting getInstance] mode];
    NSLog(@"mode==%d",mode);
    touchModeBtn = [self addButton:RECT_1 title:[Language getText:@"TOUCH_MODE"] action:@selector(doTouchMode:)];
    intervalX = (self.frame.size.width-leaderboardBtn.frame.size.width*2)/3;
    point = CGPointMake(intervalX, shareBtn.frame.origin.y+shareBtn.frame.size.height+intervalY);
    touchModeBtn.frame = CGRectMake(point.x, point.y, touchModeBtn.frame.size.width, touchModeBtn.frame.size.height);
    if (mode != TOUCH) {
        touchModeBtn.backgroundColor = BUTTON_UNSELECT_COLOR;
    }
    
    gravityModeBtn = [self addButton:RECT_1 title:[Language getText:@"GRAVITY_MODE"] action:@selector(doGravityMode:)];
    point = CGPointMake(touchModeBtn.frame.origin.x+gravityModeBtn.frame.size.width+intervalX, touchModeBtn.frame.origin.y);
    gravityModeBtn.frame = CGRectMake(point.x, point.y, gravityModeBtn.frame.size.width, gravityModeBtn.frame.size.height);
    if (mode != GRAVITY) {
        gravityModeBtn.backgroundColor = BUTTON_UNSELECT_COLOR;
    }
    
    NSString* tipText = [NSString stringWithFormat:[Language getText:@"TIP"],[[PayTool getInstance] getLocalPrice:IAP1]];
    tipBtn = [self addButton:RECT_1 title:tipText action:@selector(doTip:)];//动画中action没反应，加入realTipBtn处理
    point = CGPointMake((self.frame.size.width-tipBtn.frame.size.width)/2, touchModeBtn.frame.origin.y+touchModeBtn.frame.size.height+intervalY*2);
    tipBtn.frame = CGRectMake(point.x, point.y, tipBtn.frame.size.width, tipBtn.frame.size.height);
    tipBtn.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    
    realTipBtn = [[UIButton alloc] initWithFrame:tipBtn.frame];
    [realTipBtn addTarget:self action:@selector(doTip:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:realTipBtn];
    
    leaderboardBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
    leaderboardBtn.alpha = 0;
    tryAgainBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
    tryAgainBtn.alpha = 0;
    shareBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
    shareBtn.alpha = 0;
    helpBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
    helpBtn.alpha = 0;
    rateBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
    rateBtn.alpha = 0;
    touchModeBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
    touchModeBtn.alpha = 0;
    gravityModeBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
    gravityModeBtn.alpha = 0;
    tipBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
    tipBtn.alpha = 0;
    
    float ANIM_DURATION = 0.15f;
    [UIView animateWithDuration:ANIM_DURATION
                     animations:^{
                         leaderboardBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         leaderboardBtn.alpha = 1;
                     }completion:^(BOOL finish){
                         [UIView animateWithDuration:ANIM_DURATION
                                          animations:^{
                                              tryAgainBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                              tryAgainBtn.alpha = 1;
                                          }completion:^(BOOL finish){
                                              [UIView animateWithDuration:ANIM_DURATION
                                                               animations:^{
                                                                   shareBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                                   shareBtn.alpha = 1;
                                                               }completion:^(BOOL finish){
                                                                   [UIView animateWithDuration:ANIM_DURATION
                                                                                    animations:^{
                                                                                        helpBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                                                        helpBtn.alpha = 1;
                                                                                    }completion:^(BOOL finish){
                                                                                        [UIView animateWithDuration:ANIM_DURATION
                                                                                                         animations:^{
                                                                                                             rateBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                                                                             rateBtn.alpha = 1;
                                                                                                         }completion:^(BOOL finish){
                                                                                                             [UIView animateWithDuration:ANIM_DURATION
                                                                                                                              animations:^{
                                                                                                                                  touchModeBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                                                                                                  touchModeBtn.alpha = 1;
                                                                                                                              }completion:^(BOOL finish){
                                                                                                                                  [UIView animateWithDuration:ANIM_DURATION
                                                                                                                                                   animations:^{
                                                                                                                                                       gravityModeBtn.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                                                                                                                       gravityModeBtn.alpha = 1;
                                                                                                                                                   }completion:^(BOOL finish){
                                                                                                                                                       [self removeAdsBtnAnimation];
                                                                                                                                                   }];
                                                                                                                              }];
                                                                                                             
                                                                                                         }];
                                                                                    }];

                                                               }];
                                          }];
                     }];
    
//    if ([[Setting getInstance] isRemoveAds]) {
//        [removeAdsBtn removeFromSuperview];
//        removeAdsBtn = NULL;
//        [realRemoveAdsBtn removeFromSuperview];
//        realRemoveAdsBtn = NULL;
//    }
}


- (void)removeAdsBtnAnimation
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         tipBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         tipBtn.alpha = 1;
                     }completion:^(BOOL finish){
                         [self removeAdsBtnAnimationLoop];
                     }];
}

- (void)removeAdsBtnAnimationLoop
{
    [UIView animateWithDuration:1.5
                     animations:^{
                         tipBtn.transform = CGAffineTransformMakeScale(0.9, 0.9);
                         tipBtn.alpha = 0.5;
                     }completion:^(BOOL finish){
                         [UIView animateWithDuration:1.5
                                          animations:^{
                                              tipBtn.transform = CGAffineTransformMakeScale(1.2, 1.2);
                                              tipBtn.alpha = 1.0;
                                          }completion:^(BOOL finish){
                                              [self removeAdsBtnAnimationLoop];
                                          }];
                     }];
}

- (void)doLeaderboard:(id)sender
{
    [[GameCenterManager getInstance] showLeaderboard:@"Leaderboard"];
}

- (void)doTryAgain:(id)sender
{
    [(GameView*)[self superview] setStage:RESTART];
}

- (void)doShare:(id)sender
{
    NSString* imgName = NULL;
    NSArray *activityItems = NULL;
    NSString* text = [Language getText:@"SHARE_TEXT"];
    if (imgName != NULL) {
        UIImage* image = [UIImage imageNamed:imgName];
        activityItems = @[text, image];
    } else {
        activityItems = @[text];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems  applicationActivities:nil];
    if ( [activityController respondsToSelector:@selector(popoverPresentationController)] ) {
        // fix iOS8 iPad crash
        activityController.popoverPresentationController.sourceView = sender;
        [[ViewController sharedViewController] presentViewController:activityController  animated:YES completion:nil];
    }
}

- (void)doHelp:(id)sender
{
    NSString* touchContent = [Language getText:@"HELP_TOUCH_MODEL"];
    NSString* gravityContent = [Language getText:@"HELP_GRAVITY_MODE"];
    NSString* content = [[Setting getInstance] mode] == TOUCH ? touchContent : gravityContent;
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[Language getText:@"HOW_TO_PLAY"]
                                                        message:content
                                                       delegate:self
                                              cancelButtonTitle:[Language getText:@"CLOSE"]
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)doRate:(id)sender
{
    NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/us/app/v-v/id1053465000?ls=1&mt=8"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (void)doTouchMode:(id)sender
{
    if ([[Setting getInstance] mode] == TOUCH) {
        [self doTryAgain:nil];
        return;
    }
    UIButton* button = (UIButton*)sender;
    if (button == NULL) {
        return;
    }
    [[Setting getInstance] saveMode:TOUCH];
    button.backgroundColor = BUTTON_SELECTED_COLOR;
    
    gravityModeBtn.backgroundColor = BUTTON_UNSELECT_COLOR;
    
    [(GameView*)[self superview] stopUpdateAccelerometer];
    [(GameView*)[self superview] updateGameView];
    
    [self doTryAgain:nil];
}

- (void)doGravityMode:(id)sender
{
    if ([[Setting getInstance] mode] == GRAVITY) {
        [self doTryAgain:nil];
        return;
    }
    UIButton* button = (UIButton*)sender;
    if (button == NULL) {
        return;
    }
    [[Setting getInstance] saveMode:GRAVITY];
    button.backgroundColor = BUTTON_SELECTED_COLOR;
    
    touchModeBtn.backgroundColor = BUTTON_UNSELECT_COLOR;
    
    [(GameView*)[self superview] startUpdateAccelerometer];
    [(GameView*)[self superview] updateGameView];
    
    [self doTryAgain:nil];
}

- (void)doTip:(id)sender
{
    [[PayTool getInstance] buy:0 productId:IAP1];
    
//    NSString* message = [NSString stringWithFormat:@"%@\n%@",[[PayTool getInstance] getLocalPrice:IAP1],@"Remove all ads & pop-ups from V&V, improve performance, have more fun!"];
//    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Remove Ads & Pop-ups?"
//                                                        message:message
//                                                       delegate:self
//                                              cancelButtonTitle:@"Soon"
//                                              otherButtonTitles:@"Yes, Remove!",@"Restore Purchase", nil];
//    [alertView setTag:ALERT_TAG_PAY];
//    [alertView show];
}

- (UIButton*)addButton:(CGRect)rect title:(NSString*)title action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = rect;
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:10.0]; //设置矩形四个圆角半径
    [button.layer setBorderWidth:1.0]; //边框宽度
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 0, 0, 0, 1 });
    
    [button.layer setBorderColor:colorref];//边框颜色
    
    [button setTitle:title forState:UIControlStateNormal];//button title
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];//title color
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];//button 点击回调方法
    
    button.backgroundColor = BUTTON_SELECTED_COLOR;
    [self addSubview:button];

    return button;
}

- (void)update
{
    if ([[Setting getInstance] isRemoveAds]) {
#ifdef ENABLE_IAD
        if (self.bannerView != NULL) {
            [self.bannerView removeFromSuperview];
            self.bannerView = NULL;
        }
#endif
//        if (removeAdsBtn != NULL) {
//            [removeAdsBtn removeFromSuperview];
//            removeAdsBtn = NULL;
//        }
//        if (realRemoveAdsBtn != NULL) {
//            [realRemoveAdsBtn removeFromSuperview];
//            realRemoveAdsBtn = NULL;
//        }
    }
}


//=======================================================================================================
#ifdef ENABLE_IAD
- (void)initBannerView{
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
        self.bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    } else {
        self.bannerView = [[ADBannerView alloc] init];
    }
    self.bannerView.delegate = self;
    [self.bannerView setFrame:CGRectMake((self.frame.size.width-[UILib getWidth])/2, [UILib getHeight], 0, 0)];
    [self addSubview:self.bannerView];
}
 
- (void)layoutAnimated:(BOOL)animated
{
    if (self.bannerView == nil) {
        return;
    }
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    CGRect contentFrame = self.bounds;
//    if (contentFrame.size.width < contentFrame.size.height) {
//        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
//    } else {
//        self.bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
//    }
    [self.bannerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    CGRect bannerFrame = self.bannerView.frame;
    if (self.bannerView.bannerLoaded) {
        contentFrame.size.height -= self.bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height+([UILib getHeight]-self.frame.size.height)/2;
    } else {
        bannerFrame.origin.y = contentFrame.size.height+([UILib getHeight]-self.frame.size.height)/2;
    }

    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        //        _contentView.frame = contentFrame;
        //        [_contentView layoutIfNeeded];
        self.bannerView.frame = bannerFrame;
    }];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self layoutAnimated:YES];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //[self layoutAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}
#endif

#pragma mark -
#pragma mark Google banner ads
//----------------------------------------------------------------
#ifdef ENABLE_GOOGLE_BANNER
- (void)initGoogleBannerView
{
    GADAdSize adSize = kGADAdSizeSmartBannerPortrait;
    
    // Initialize the banner at the bottom of the screen.
    CGPoint origin = CGPointMake((self.frame.size.width - CGSizeFromGADAdSize(adSize).width)/2,
                                 self.frame.size.height - CGSizeFromGADAdSize(adSize).height);
    
    // Use predefined GADAdSize constants to define the GADBannerView.
    _gBannerView = [[GADBannerView alloc] initWithAdSize:adSize origin:origin];
    if (_gBannerView == nil) {
        return;
    }
    [self addSubview:_gBannerView];
    
    // Replace this ad unit ID with your own ad unit ID.
    _gBannerView.adUnitID = @"ca-app-pub-5134090789350916/7184413987";
    _gBannerView.rootViewController = [ViewController sharedViewController];
    
    GADRequest *request = [GADRequest request];
    // Requests test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made.
    //request.testDevices = @[ GAD_SIMULATOR_ID, @"MY_TEST_DEVICE_ID" ];
    [_gBannerView loadRequest:request];
}

#endif
//=======================================================================================================


#pragma mark -
#pragma mark UIAlertViewDelegate
//----------------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case ALERT_TAG_PAY:
        {
            switch (buttonIndex) {
                case 0://Cancel
                    break;
                case 1://Remove Ads
                    [[ViewController sharedViewController] hiddenLoadingView:NO];
                    [[PayTool getInstance] buy:0 productId:IAP1];
                    break;
                case 2://Restore Purchase
                    [[ViewController sharedViewController] hiddenLoadingView:NO];
                    [[PayTool getInstance] restoreCompletedTransactions];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark Switch Button Action
//----------------------------------------------------------------------------------------------------------------
-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        [[Setting getInstance] saveIsOpenMusic:YES];
        [[AudioTool instance] audioMusicPlayWithName:FAIL_MUSIC type:@"mp3"];
    }else {
        [[Setting getInstance] saveIsOpenMusic:NO];
        [[AudioTool instance] stopMusicAndSound];
    }
}


//----------------------------------------------------------------------------------------------------------------
-(void)doInfoAction:(id)sender
{
    NSString* vStr = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString* content = [Language getText:@"GAME_INFO"];
    content = [NSString stringWithFormat:content,vStr];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"V&V"
                                                        message:content
                                                       delegate:self
                                              cancelButtonTitle:[Language getText:@"CLOSE"]
                                              otherButtonTitles:nil];
    [alertView show];
}


@end

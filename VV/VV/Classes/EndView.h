//
//  EndView.h
//  V&V
//
//  Created by Haryson Liang on 12/22/14.
//  Copyright (c) 2014 MobileGameTree. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef ENABLE_IAD
#import <iAd/iAd.h>
#endif

#ifdef ENABLE_GOOGLE_BANNER
@class GADBannerView;
#endif

@interface EndView : UIView<UIAlertViewDelegate
#ifdef ENABLE_IAD
,ADBannerViewDelegate
#endif
>
{
    UILabel* endLabel;
    
    UIButton* touchModeBtn;
    UIButton* gravityModeBtn;
    
    UIButton* tipBtn;
    UIButton* realTipBtn;
    
#ifdef ENABLE_IAD
    ADBannerView* bannerView;
#endif
    
#ifdef ENABLE_GOOGLE_BANNER
    GADBannerView* _gBannerView;
#endif
}

#ifdef ENABLE_IAD
@property (nonatomic, retain)ADBannerView* bannerView;
#endif

//  Touch related
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;

- (void)scoreAnimation;
- (void)buttonAnimation;
- (void)removeAdsBtnAnimation;
- (void)removeAdsBtnAnimationLoop;

- (void)doLeaderboard:(id)sender;
- (void)doTryAgain:(id)sender;
- (void)doShare:(id)sender;
- (void)doHelp:(id)sender;
- (void)doRate:(id)sender;
- (void)doTouchMode:(id)sender;
- (void)doGravityMode:(id)sender;
- (void)doTip:(id)sender;

- (UIButton*)addButton:(CGRect)rect title:(NSString*)title action:(SEL)action;

- (void)update;

#ifdef ENABLE_IAD
- (void)initBannerView;
#endif

#ifdef ENABLE_GOOGLE_BANNER
- (void)initGoogleBannerView;
#endif

@end

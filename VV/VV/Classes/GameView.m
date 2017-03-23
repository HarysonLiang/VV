//
//  GameView.m
//  V&V
//
//  Created by Haryson Liang on 12/7/14.
//  Copyright (c) 2014 MobileGameTree. All rights reserved.
//

#import "GameView.h"
#import "UILib.h"
#import "UIRoundHighlightView.h"
#import "Tools.h"
#import "Setting.h"
#import "ViewController.h"
#import "AudioTool.h"
#import "Common/Common.h"
#import "Language.h"

#include <math.h>

#define GROW_WIDTH          1
#define WIN_SCORE           200
#define MAIN_CIRCLE_WIDTH   (50*[UILib getSizeScale])

#define ALERT_TAG_WIN       1

@implementation GameView

@synthesize stage;
@synthesize score;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blackColor]];
        [self setMultipleTouchEnabled:NO];
        
        UIColor* textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:0.5];
        bestScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120*[UILib getSizeScale], 20*[UILib getSizeScale])];
        [bestScoreLabel setTextColor:textColor];
        [bestScoreLabel setFont:[UIFont systemFontOfSize:20*[UILib getSizeScale]]];
        [bestScoreLabel adjustsFontSizeToFitWidth];
        [bestScoreLabel setTextAlignment:NSTextAlignmentCenter];
        [bestScoreLabel setCenter:CGPointMake(self.frame.size.width/2, bestScoreLabel.frame.size.height)];
        [self addSubview:bestScoreLabel];
        [self updateBestScoreLabel];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200*[UILib getSizeScale], 100*[UILib getSizeScale])];
        //[label setBackgroundColor:[UIColor redColor]];
        [label setText:@"V&V"];
        [label setTextColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont systemFontOfSize:100*[UILib getSizeScale]]];
        [label adjustsFontSizeToFitWidth];
        [label setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - 15*[UILib getSizeScale])];
        [self addSubview:label];
        
        NSString* modeStr = [[Setting getInstance] mode] == TOUCH ? [Language getText:@"TOUCH_MODE"] : [Language getText:@"GRAVITY_MODE"];
        modeLabel = [[UILabel alloc] init];
        [modeLabel setText:modeStr];
        [modeLabel setTextColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5]];
        [modeLabel setFont:[UIFont systemFontOfSize:20*[UILib getSizeScale]]];
        [modeLabel sizeToFit];
        [modeLabel setCenter:CGPointMake(self.frame.size.width/2, label.center.y-label.frame.size.height/2-modeLabel.frame.size.height/2)];
        [self addSubview:modeLabel];
        
        float textSize = 13*[UILib getScaleX];
        UILabel* tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-textSize*2, self.frame.size.width, textSize*1.5)];
        [tipsLabel setText:[Language getText:@"ABSORB_TEXT"]];
        [tipsLabel setTextColor:textColor];
        [tipsLabel setTextAlignment:NSTextAlignmentCenter];
        [tipsLabel setFont:[UIFont systemFontOfSize:textSize]];
        [tipsLabel adjustsFontSizeToFitWidth];
        [self addSubview:tipsLabel];
        
        
        //圆点，受控制点
        float width = MAIN_CIRCLE_WIDTH;
        float height = width;
        mainCircleView = [[UICircleView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [mainCircleView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
        [self addSubview:mainCircleView];
        
        //光环
        auraView = [[UIRoundHighlightView alloc ]initWithFrame:mainCircleView.frame];
        [auraView setCenter:CGPointMake(mainCircleView.frame.size.width/2, mainCircleView.frame.size.height/2)];
        [mainCircleView addSubview:auraView];
        
        [mainCircleView setContentMode:UIViewContentModeRedraw];//重新setFrame会重新调用drawRect
        [auraView setContentMode:UIViewContentModeRedraw];
        
        //成绩/分数显示
        score = 0;
        CGRect rect = CGRectMake(0, 0, [mainCircleView frame].size.width*0.8, [mainCircleView frame].size.height*0.4);
        scoreLabel = [[UILabel alloc] initWithFrame:rect];
        [scoreLabel setText:@"000"];
        [scoreLabel setTextAlignment:NSTextAlignmentCenter];
        [scoreLabel setTextColor:[UIColor grayColor]];
        [scoreLabel setFont:[UIFont systemFontOfSize:[mainCircleView frame].size.height*0.4]];
        [scoreLabel setCenter:CGPointMake(mainCircleView.frame.size.width/2,mainCircleView.frame.size.height/2)];
        [mainCircleView addSubview:scoreLabel];
        
        //吸咐及碰撞动画
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
        self.animator.delegate = self;
        
        NSArray* items = [NSArray arrayWithObjects:mainCircleView,subCircleView,nil];
        self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:items];
        // Account for any top and bottom bars when setting up the reference bounds.
        [self.collisionBehavior setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake([self frame].size.height, 0, [self frame].size.height, 0)];
        [self.collisionBehavior setCollisionDelegate:self];
        [self.animator addBehavior:self.collisionBehavior];
        
        self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[mainCircleView] mode:UIPushBehaviorModeContinuous];
        self.pushBehavior.angle = 0.0;
        self.pushBehavior.magnitude = 0.0;
        [self.animator addBehavior:self.pushBehavior];
        
        self.gravityBehavior = NULL;
        
        lastMainCircleCenter = mainCircleView.center;
        subCircleView = NULL;
        absorbDistance = 0;
        isHasBestNotice = NO;
        motionManager = NULL;
        
        titleView = [[TitleView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:titleView];
        [self setStage:TITLE_WAITTING];
        
        endView = NULL;
    }
    return self;
}

#pragma mark -
#pragma mark Touch UIDynamicAnimatorDelegate
//-------------------------------------------------------------------------------
- (void)dynamicAnimatorWillResume:(UIDynamicAnimator*)animator
{
}
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator
{
}


#pragma mark -
#pragma mark UICollisionBehaviorDelegate
//-------------------------------------------------------------------------------
// The identifier of a boundary created with translatesReferenceBoundsIntoBoundary or setTranslatesReferenceBoundsIntoBoundaryWithInsets is nil
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier atPoint:(CGPoint)p
{
    NSLog(@"fail began!!!");
}

- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item withBoundaryIdentifier:(id <NSCopying>)identifier
{
    NSLog(@"end began!!!");
    [[ViewController sharedViewController] setIsHasCollisionNotice:YES];
#ifdef DEBUG
    //return;
#endif
    //震动动画
    //碰壁后弹出广告
    if (stage == FAIL || stage == END_WAITTING || stage == WIN_WAITTING) {
        return;
    }
    [self setStage:FAIL];
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
    //UITouch *touch = [[event allTouches] anyObject];
    //CGPoint point = [touch locationInView:self];
}

//-------------------------------------------------------------------------------
//  Touches is event-based, no update no new event
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event  {
    MODE mode = [[Setting getInstance] mode];
    if (mode != TOUCH) {
        return;
    }
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint p = [touch locationInView:self];
    
    // NSLog(@"touch point(%f,%f)",point.x,point.y);
    
    CGPoint o = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat distance = sqrtf(powf(p.x-o.x, 2.0)+powf(p.y-o.y, 2.0));
    CGFloat angle = atan2(p.y-o.y, p.x-o.x);
    distance = MIN(distance, 119*[UILib getSizeScale]);//200.0 for iPad2
    
    // These two lignes change the actual force vector.
    if (self.pushBehavior != NULL) {
        [self.pushBehavior setMagnitude:distance / (180/[UILib getSizeScale])];//100.0 for iPad2
        [self.pushBehavior setAngle:angle];
    }
}

//-------------------------------------------------------------------------------
//  Touches is event-based, no update no new event
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event  {
    //UITouch *touch = [[event allTouches] anyObject];
    //CGPoint point = [touch locationInView:self];
}

//-------------------------------------------------------------------------------
- (void)initSubCircleView
{
    if (subCircleView != NULL) {
        [subCircleView removeFromSuperview];
        subCircleView = NULL;
    }
    
    //圆点，受控制点
    float width = 20*[UILib getSizeScale];
    float height = width;
    subCircleView = [[UICircleView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self addSubview:subCircleView];
    [self bringSubviewToFront:mainCircleView];
}

//-------------------------------------------------------------------------------
- (void)update
{
    if ([self stage] == LOGIC && [[Setting getInstance] mode] == GRAVITY && ![UIApplication sharedApplication].idleTimerDisabled) {
        [UIApplication sharedApplication].idleTimerDisabled=YES;//禁止自动休眠
    } else {
        [UIApplication sharedApplication].idleTimerDisabled=NO;
    }
    
    switch ([self stage]) {
        case TITLE_WAITTING:    [self doTitleWaiting];      break;
        case INIT:              [self doInit];              break;
        case LOGIC:             [self doLogic];             break;
        case ABSORBING:         [self doAbsorbing];         break;
        case FAIL:              [self doFail];              break;
        case WIN:               [self doWin];               break;
        case RESTART:           [self doRestart];           break;
        case REVIVISCENCE:      [self doReviviscence];      break;
        case END_WAITTING:      [self doEndWaitting];        break;
        case WIN_WAITTING:      [self doWinWaitting];break;
            
        default:
            break;
    }
}

- (void)doEndWaitting
{
    if (endView != NULL) {
        [endView update];
    }
}

- (void)doTitleWaiting
{
    if (titleView != NULL) {
        [titleView update];
    }
}

- (void)doInit
{
    [self initSubCircleView];
    [self resetSubCircleViewCenter];
    absorbDistance = mainCircleView.frame.size.width/2  + subCircleView.frame.size.width/2;
    
    if ([[Setting getInstance] mode] == GRAVITY) {
        [self startUpdateAccelerometer];
        [[AudioTool instance] audioMusicPlayWithName:GRAVITY_BG_MUSIC type:@"mp3"];
    } else {
        [[AudioTool instance] audioMusicPlayWithName:TOUCH_BG_MUSIC type:@"mp3"];
    }
    
    [self setStage:LOGIC];
}

- (void)doLogic
{
    BOOL isCollision = [self isCollision];
    if (isCollision) {
        NSLog(@"is collision!!!");
        [[AudioTool instance] audioSoundPlayWithName:ABSORB_SOUND type:@"wav"];
        [self setStage:ABSORBING];
    }
}

- (void)doAbsorbing
{
    float x1 = mainCircleView.center.x;
    float y1 = mainCircleView.center.y;
    float x2 = subCircleView.center.x;
    float y2 = subCircleView.center.y;
    float r1 = mainCircleView.frame.size.width/2;
    float r2 = subCircleView.frame.size.width/2;
    
    if (absorbDistance <= r1 - r2) {
        //完全呑噬后获得积分并产生新的sub circleView
        if (![self incScore]) {
            [subCircleView removeFromSuperview];
            subCircleView = NULL;
            return;
        }
        [self resetSubCircleViewCenter];
        absorbDistance = mainCircleView.frame.size.width/2 + subCircleView.frame.size.width/2;
        
        [self setStage:LOGIC];
        return;
    }
    
    absorbDistance--;
    CGPoint point = [Tools seekPointWithX1:x1 X2:x2 Y1:y1 Y2:y2 distance:absorbDistance];
    [subCircleView setCenter:point];
}

- (void)doFail
{
    NSLog(@"doFail");
    if (endView != NULL) {
        return;
    }
    [self setStage:END_WAITTING];
    [[AudioTool instance] audioMusicPlayWithName:FAIL_MUSIC type:@"mp3"];
    
    endView = [[EndView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [endView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height*1.5)];
    [self addSubview:endView];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         endView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                     }completion:^(BOOL finish){
#ifdef ENABLE_IAD
                         [[ViewController sharedViewController] presentInterlude];
#endif

#ifdef ENABLE_VUNGLE
                         [[ViewController sharedViewController] showAd];
#endif
                     }];
}

- (void)doWin
{
    [[AudioTool instance] audioMusicPlayWithName:SUCCESS_MUSIC type:@"mp3"];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:[Language getText:@"CONGRATULATIONS"]
                                                        message:[Language getText:@"YOU_ARE_THE_GOD"]
                                                       delegate:self
                                              cancelButtonTitle:[Language getText:@"RESTART"]
                                              otherButtonTitles:nil];
    [alertView setTag:ALERT_TAG_WIN];
    [alertView show];
    [self setStage:WIN_WAITTING];
}

- (void)doWinWaitting
{
}

- (void)doRestart
{
    if (endView != NULL) {
        [endView removeFromSuperview];
        endView = NULL;
    }
    
    [mainCircleView resetFrame];
    [mainCircleView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    [mainCircleView setNeedsDisplay];
    lastMainCircleCenter = mainCircleView.center;
    
    [auraView resetFrame];
    [auraView setCenter:CGPointMake(mainCircleView.frame.size.width/2, mainCircleView.frame.size.height/2)];
    [auraView setNeedsDisplay];
    [scoreLabel setCenter:auraView.center];
    [self.animator updateItemUsingCurrentState:mainCircleView];
    if (self.pushBehavior != NULL) {
        [self.pushBehavior setAngle:0.0f magnitude:0.0f];
    }
    if (self.gravityBehavior != NULL) {
        [self.gravityBehavior setAngle:0.0f magnitude:0.0f];
        [self.gravityBehavior setGravityDirection:CGVectorMake(0.0f, 0.0f)];
    }
    
    [self setScore:0];
    if (subCircleView == NULL) {
        [self initSubCircleView];
    }
    [self resetSubCircleViewCenter];
    absorbDistance = mainCircleView.frame.size.width/2 + subCircleView.frame.size.width/2;
    [scoreLabel setText:[Tools generateScoreString:score]];
    [self updateCollisionBehavior];
    
    if ([[Setting getInstance] mode] == GRAVITY) {
        [[AudioTool instance] audioMusicPlayWithName:GRAVITY_BG_MUSIC type:@"mp3"];
    } else {
        [[AudioTool instance] audioMusicPlayWithName:TOUCH_BG_MUSIC type:@"mp3"];
    }
    
    [self setStage:LOGIC];
}

- (void)doReviviscence
{
    //TODO
    [mainCircleView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    lastMainCircleCenter = mainCircleView.center;
    [self.animator updateItemUsingCurrentState:mainCircleView];
    [self.pushBehavior setAngle:0.0f magnitude:0.0f];
    [self setStage:LOGIC];
}


- (BOOL)isCollision
{
    float x1 = mainCircleView.center.x;
    float y1 = mainCircleView.center.y;
    float x2 = subCircleView.center.x;
    float y2 = subCircleView.center.y;
    float r1 = mainCircleView.frame.size.width/2;
    float r2 = subCircleView.frame.size.width/2;
    
    BOOL isCollision = [Tools isCollisionWithCircleX1:x1 X2:x2 Y1:y1 Y2:y2 R1:r1 R2:r2];
    
    lastMainCircleCenter = CGPointMake(x1, y1);
    
    if (isCollision) {
        return YES;
    }
    
    //计算两帧之间行过的路径是否有碰撞
    int distance = sqrt(pow(x1 - lastMainCircleCenter.x, 2) + pow(y1 - lastMainCircleCenter.y, 2));
    while (distance >= 1) {
        distance--;
        CGPoint tPoint = [Tools seekPointWithX1:x1 X2:lastMainCircleCenter.x Y1:y1 Y2:lastMainCircleCenter.y distance:distance];
        isCollision = [Tools isCollisionWithCircleX1:tPoint.x X2:x2 Y1:tPoint.y Y2:y2 R1:r1 R2:r2];
        if (isCollision) {
            return YES;
        }
    }
    
    return NO;
}

- (void)resetSubCircleViewCenter
{
    if (mainCircleView == NULL || subCircleView == NULL) {
        return;
    }
    
    int rX = 0;
    int rY = 0;
    int oX = subCircleView.center.x;
    int oY = subCircleView.center.y;
    BOOL isRandomFail = YES;
    while (isRandomFail) {
        //不同score,在不同范围,score <= 10 受保护范围为center(width*0.5,height*0.5)
        if (score <= 5) {
            rX = [Tools randomNumber:self.frame.size.width*0.25 to:self.frame.size.width*0.75];
            rY = [Tools randomNumber:self.frame.size.height*0.25 to:self.frame.size.height*0.75];
        }else{
            rX = [Tools randomNumber:subCircleView.frame.size.width/2 to:(self.frame.size.width - subCircleView.frame.size.width)];
            rY = [Tools randomNumber:subCircleView.frame.size.width/2 to:(self.frame.size.height - subCircleView.frame.size.width)];
        }
        
        //新位置与旧位置没有碰撞重叠
        BOOL isSame = [Tools isCollisionWithCircleX1:rX X2:oX Y1:rY Y2:oY R1:subCircleView.frame.size.width/2 R2:subCircleView.frame.size.width/2];
        
        //新位置与mainCircle没有碰撞
        BOOL isCollisionMainCircle = [Tools isCollisionWithCircleX1:rX X2:mainCircleView.center.x Y1:rY Y2:mainCircleView.center.y R1:subCircleView.frame.size.width/2 R2:mainCircleView.frame.size.width/2];
        
        if (isSame == NO
            && isCollisionMainCircle == NO) {
            isRandomFail = NO;
        }
        
        //不要产生没法碰撞的位置
        //左上角检查
        BOOL canCollision = YES;
        float mLeftX = mainCircleView.frame.size.width/2+5;//+5是防止出现极端情况需要帖边才能食
        float mTopY = mainCircleView.frame.size.height/2+5;
        float mRightX = self.frame.size.width - (mainCircleView.frame.size.width/2+5);
        float mBottomY = self.frame.size.height - (mainCircleView.frame.size.height/2+5);
        float mainR = mainCircleView.frame.size.width/2;
        float subR = subCircleView.frame.size.width/2;
        if (rX <= mLeftX && rY <= mTopY) {
            canCollision = [Tools isCollisionWithCircleX1:mLeftX X2:rX Y1:mTopY Y2:rY R1:mainR R2:subR];
        }
        //右上角检查
        if (rX >= mRightX && rY <= mTopY) {
            canCollision = [Tools isCollisionWithCircleX1:mRightX X2:rX Y1:mTopY Y2:rY R1:mainR R2:subR];
        }
        //左下角检查
        if (rX <= mLeftX && rY >= mBottomY) {
            canCollision = [Tools isCollisionWithCircleX1:mLeftX X2:rX Y1:mBottomY Y2:rY R1:mainR R2:subR];
        }
        //右下角检查
        if (rX >= mRightX && rY >= mBottomY) {
            canCollision = [Tools isCollisionWithCircleX1:mRightX X2:rX Y1:mBottomY Y2:rY R1:mainR R2:subR];
        }
        
        if (!canCollision) {
            isRandomFail = YES;
        }
    }
    
    [subCircleView setCenter:CGPointMake(rX, rY)];
}

- (BOOL)incScore
{
    score++;
    [scoreLabel setText:[Tools generateScoreString:score]];
    
    if (score > [[Setting getInstance] getBestScore]) {
        [[Setting getInstance] saveBestScore:score];
        [self updateBestScoreLabel];
        isHasBestNotice = YES;
    }
    
    float growWidth = [self growWidth];
    CGPoint center = [mainCircleView center];
    [mainCircleView setFrame:CGRectMake(0, 0, mainCircleView.frame.size.width + growWidth, mainCircleView.frame.size.height + growWidth)];
    [mainCircleView setCenter:center];
    //[mainCircleView setNeedsDisplay];
    
    [auraView setFrame:CGRectMake(0, 0, auraView.frame.size.width + growWidth, auraView.frame.size.height + growWidth)];
    [auraView setCenter:CGPointMake(mainCircleView.frame.size.width/2, mainCircleView.frame.size.height/2)];
    [mainCircleView sizeToFit];
    //[auraView setNeedsDisplay];
    
    [scoreLabel setCenter:[auraView center]];
    
    if ([self isWin]) {
        [self setStage:WIN];
        return NO;
    }
    
    [self updateCollisionBehavior];//更新碰撞边框
    [self processBestNotice];//分数破纪录效果
    
    return YES;
}

- (void)updateCollisionBehavior
{
    [self.collisionBehavior removeBoundaryWithIdentifier:@"top"];
    [self.collisionBehavior removeBoundaryWithIdentifier:@"bottom"];
    [self.collisionBehavior removeBoundaryWithIdentifier:@"left"];
    [self.collisionBehavior removeBoundaryWithIdentifier:@"right"];
    
    float offsetBoundarySize = (mainCircleView.frame.size.width - MAIN_CIRCLE_WIDTH)/2;

    [self.collisionBehavior addBoundaryWithIdentifier:@"top" fromPoint:CGPointMake(offsetBoundarySize, offsetBoundarySize) toPoint:CGPointMake(self.frame.size.width - offsetBoundarySize, offsetBoundarySize)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"bottom" fromPoint:CGPointMake(offsetBoundarySize, self.frame.size.height - offsetBoundarySize) toPoint:CGPointMake(self.frame.size.width - offsetBoundarySize, self.frame.size.height - offsetBoundarySize)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"left" fromPoint:CGPointMake(offsetBoundarySize, offsetBoundarySize) toPoint:CGPointMake(offsetBoundarySize, self.frame.size.height - offsetBoundarySize)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"right" fromPoint:CGPointMake(self.frame.size.width - offsetBoundarySize, offsetBoundarySize) toPoint:CGPointMake(self.frame.size.width - offsetBoundarySize, self.frame.size.height - offsetBoundarySize)];
}

//-------------------------------------------------------------------------------
- (void)processBestNotice
{
    if (!isHasBestNotice) {
        return;
    }
    
    isHasBestNotice = NO;
    bestScoreLabel.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         bestScoreLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
                     }completion:^(BOOL finish){
                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              bestScoreLabel.transform = CGAffineTransformMakeScale(0.9, 0.9);
                                          }completion:^(BOOL finish){
                                              [UIView animateWithDuration:0.5
                                                               animations:^{
                                                                   bestScoreLabel.transform = CGAffineTransformMakeScale(1, 1);
                                                               }completion:^(BOOL finish){
                                                                   
                                                               }];
                                          }];
                     }];
}

//-------------------------------------------------------------------------------
- (BOOL)isWin
{
    //return mainCircleView.frame.size.width >= self.frame.size.width || mainCircleView.frame.size.width >= self.frame.size.height;
    return self.score >= WIN_SCORE;
}

- (float)growWidth
{
    float growWidth = GROW_WIDTH;
    
    int processScore = 5;
    if (score <= processScore) {
        growWidth = ((processScore+1)-score)*(1.3*[UILib getSizeScale]);
    } else {
        growWidth = (self.frame.size.width - mainCircleView.frame.size.width)/(WIN_SCORE+1 - score);
    }

    return growWidth;
}

#pragma mark -
#pragma mark Gravity Mode
//-------------------------------------------------------------------------------
- (void)startUpdateAccelerometer
{
    if (motionManager == NULL) {
        motionManager =[[CMMotionManager alloc] init];
    }
    
    if (self.gravityBehavior == NULL) {
        self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[mainCircleView]];
        self.gravityBehavior.angle = 0.0;
        self.gravityBehavior.magnitude = 0.0;
        self.gravityBehavior.gravityDirection = CGVectorMake(0.0, 0.0);
        [self.animator addBehavior:self.gravityBehavior];
    }
    
    /* 设置采样的频率，单位是秒 */
    NSTimeInterval updateInterval = 1.0/60.0;//0.07;
    
    /* 判断是否加速度传感器可用，如果可用则继续 */
    if ([motionManager isAccelerometerAvailable] == YES) {
        /* 给采样频率赋值，单位是秒 */
        [motionManager setAccelerometerUpdateInterval:updateInterval];
        
        /* 加速度传感器开始采样，每次采样结果在block中处理 */
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error)
         {
             if (error) {
                 [motionManager stopAccelerometerUpdates];//停止使用加速度计
             }else{
                 CGFloat x = accelerometerData.acceleration.x;
                 CGFloat y = accelerometerData.acceleration.y;
                 switch ([[ViewController sharedViewController] interfaceOrientation]) {
                     case   UIInterfaceOrientationLandscapeRight:
                         self.gravityBehavior.gravityDirection = CGVectorMake(- y, - x); break;
                     case   UIInterfaceOrientationLandscapeLeft:
                         self.gravityBehavior.gravityDirection = CGVectorMake(y, x); break;
                     case   UIInterfaceOrientationPortrait:
                         self.gravityBehavior.gravityDirection = CGVectorMake(x, - y); break;
                     case   UIInterfaceOrientationPortraitUpsideDown:
                         self.gravityBehavior.gravityDirection = CGVectorMake(- x, y); break;
                     case UIInterfaceOrientationUnknown:
                         NSLog(@"UIInterfaceOrientationUnknown");
                 }

             }
         }];
    }
    
}

/* 停止传感器，当不是用的时候要及时停掉 */
- (void)stopUpdateAccelerometer
{
    if (motionManager == NULL) {
        return;
    }
    if ([motionManager isAccelerometerActive] == YES)
    {
        [motionManager stopAccelerometerUpdates];
    }
    
    [self.animator removeBehavior:self.gravityBehavior];
    self.gravityBehavior = NULL;
}


- (void)updateGameView
{
    [self updateBestScoreLabel];
    [self updateModeLabel];
}


- (void)updateBestScoreLabel
{
    if (bestScoreLabel == NULL) {
        return;
    }
    
    [bestScoreLabel setText:[NSString stringWithFormat:[Language getText:@"NEW_BEST"],[Tools generateScoreString:[[Setting getInstance] getBestScore]]]];
}


- (void)updateModeLabel
{
    if (modeLabel == NULL) {
        return;
    }
    
    NSString* modeStr = [[Setting getInstance] mode] == TOUCH ? [Language getText:@"TOUCH_MODE"] : [Language getText:@"GRAVITY_MODE"];
    [modeLabel setText:modeStr];
    [modeLabel sizeToFit];
}

#pragma mark -
#pragma mark UIAlertViewDelegate
//----------------------------------------------------------------------------------------------------------------
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case ALERT_TAG_WIN:
        {
            switch (buttonIndex) {
                case 0:
                    [self setStage:RESTART];
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


@end

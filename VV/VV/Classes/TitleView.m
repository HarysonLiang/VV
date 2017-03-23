//
//  TitleView.m
//  V&V
//
//  Created by Haryson Liang on 12/18/14.
//  Copyright (c) 2014 MobileGameTree. All rights reserved.
//

#import "TitleView.h"
#import "UILib.h"
#import "GameView.h"
#import "AudioTool.h"
#import "Common/Common.h"
#import "Language.h"

@implementation TitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView* bgView = [[UIView alloc] initWithFrame:frame];
        [bgView setBackgroundColor:[UIColor grayColor]];
        [bgView setAlpha:0.95f];
        [self addSubview:bgView];
        
        story = [Language getText:@"STORY_INFO"];
        
        storyLength = 1;
        NSRange range;
        range.location = 0;
        range.length = storyLength;
        NSString *start = [story substringWithRange:range];
        
        UIFont* font = [UIFont boldSystemFontOfSize:35.0f*[UILib getScaleX]];
        float fontHeight = font.pointSize;
        float labelWidth = self.frame.size.width;
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        CGSize labelSize = [story boundingRectWithSize:CGSizeMake(labelWidth, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
        
        storyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
        storyLabel.font = font;
        storyLabel.textAlignment = NSTextAlignmentLeft;
        storyLabel.backgroundColor = [UIColor clearColor];
        storyLabel.text = start;
        storyLabel.textColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
        storyLabel.numberOfLines = ceil(labelSize.height / fontHeight);
        
        [self addSubview:storyLabel];
        
        frameIndex = 0;
        
        font = [UIFont boldSystemFontOfSize:35.0f*[UILib getScaleX]];
        tapLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45.0f*[UILib getScaleX])];
        tapLabel.font = font;
        tapLabel.textAlignment = NSTextAlignmentCenter;
        tapLabel.backgroundColor = [UIColor clearColor];
        tapLabel.text = [Language getText:@"TAP_TO_PLAY"];
        tapLabel.textColor = [UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f];
        CGPoint point = [UILib offset:CGPointMake(0, -100.0f*[UILib getScaleY]) size:tapLabel.frame.size superSize:self.frame.size anchor:ANCHOR_CENTER];
        [tapLabel setFrame:CGRectMake(point.x, point.y, tapLabel.frame.size.width, tapLabel.frame.size.height)];
        
        [self addSubview:tapLabel];
    }
    return self;
}

//-------------------------------------------------------------------------------
- (void)update
{
    frameIndex++;
    if (frameIndex%3 != 0) {
        return;
    }
    if (storyLength >= [story length]) {
        return;
    }
    
    storyLength++;
    
    NSRange range;
    range.location = 0;
    range.length = storyLength;
    NSString *str = [story substringWithRange:range];
    
    storyLabel.text = str;
    
    [[AudioTool instance] audioSoundPlayWithName:KEYBOARD_SOUND type:@"wav"];
    
    if (storyLength >= [story length]) {
        [[AudioTool instance] audioMusicPlayWithName:TITLE_BG_MUSIC type:@"wav"];
        [self tapLabelAnimation];
    }
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
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.center = CGPointMake(self.frame.size.width/2, -self.frame.size.height/2);
                     }completion:^(BOOL finish){
                         [(GameView*)[self superview] setStage:INIT];
                         [self removeFromSuperview];
                     }];
}

//-------------------------------------------------------------------------------
//  Touches is event-based, no update no new event
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event  {
}


- (void)tapLabelAnimation
{
    if (tapLabel == NULL) {
        return;
    }
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         //AudioServicesPlaySystemSound(1321);
                         tapLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         tapLabel.alpha = 1.0f;
                     }completion:^(BOOL finish){
                         [UIView animateWithDuration:1.0
                                          animations:^{
                                              tapLabel.transform = CGAffineTransformMakeScale(0.8, 0.8);
                                              tapLabel.alpha = 0.5f;
                                          }completion:^(BOOL finish){
                                              [UIView animateWithDuration:1.0
                                                               animations:^{
                                                                   tapLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
                                                                   tapLabel.alpha = 1.0f;
                                                               }completion:^(BOOL finish){
                                                                   [self tapLabelAnimation];
                                                               }];
                                          }];
                     }];
}

@end

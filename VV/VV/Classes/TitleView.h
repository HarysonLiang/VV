//
//  TitleView.h
//  V&V
//
//  Created by Haryson Liang on 12/18/14.
//  Copyright (c) 2014 MobileGameTree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleView : UIView{
    NSString* story;
    NSUInteger storyLength;
    
    UILabel *storyLabel;
    NSUInteger frameIndex;
    
    UILabel *tapLabel;
}

//  Touch related
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event;
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;

- (void)update;
- (void)tapLabelAnimation;

@end

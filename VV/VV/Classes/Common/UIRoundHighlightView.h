//
//  UIRoundHighlightView.h
//  V&V
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIRoundHighlightView : UIView{
	CGFloat radius;
    CGRect INIT_FRAME;
}

@property (nonatomic, readwrite) CGFloat radius;

- (void)resetFrame;

@end

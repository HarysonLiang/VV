//
//  UIRoundedRectView.h
//  V&V
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIRoundedRectView : UIView {
	CGFloat radius;
	UIColor *borderColor;
	UIColor *bgColor;
	BOOL willFadeOut;
}

@property (nonatomic, readwrite) BOOL willFadeOut;
@property (nonatomic, readwrite) CGFloat radius;
@property (nonatomic, retain) UIColor *borderColor, *bgColor;

@end

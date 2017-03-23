//
//  UICircleView.h
//  V&V
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICircleView : UIView{
    CGRect INIT_FRAME;
}

@property (nonatomic,readwrite)UIColor *fillColor;

- (void)resetFrame;

@end

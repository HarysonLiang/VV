//
//  LoadingView.m
//  V&V
//
//  Created by Haryson Liang on 1/10/15.
//  Copyright (c) 2015 MobileGameTree. All rights reserved.
//

#import "LoadingView.h"
#import "UIRoundedRectView.h"
#import "UILib.h"
#import "Language.h"

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIRoundedRectView* bgView = [[UIRoundedRectView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width*0.6, frame.size.height*0.2)];
        [bgView setBgColor:[UIColor blackColor]];
        [bgView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [bgView setRadius:15];
        [bgView setBorderColor:[UIColor whiteColor]];
        [self addSubview:bgView];
        
        UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30*[UILib getSizeScale], 30*[UILib getSizeScale])];
        [activityIndicator setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        UILabel* msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bgView.frame.size.width, bgView.frame.size.height/4)];
        [msgLabel setBackgroundColor:[UIColor clearColor]];
        [msgLabel setCenter:CGPointMake(bgView.center.x, bgView.center.y+bgView.frame.size.height/4)];
        [msgLabel setTextColor:[UIColor whiteColor]];
        [msgLabel setTextAlignment:NSTextAlignmentCenter];
        [msgLabel setText:[Language getText:@"ONE_MOMENT"]];
        [msgLabel.layer setMasksToBounds:YES];
        [self addSubview:msgLabel];
        
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

@end

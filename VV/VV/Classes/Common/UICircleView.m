//
//  UICircleHighlightView.m
//  V&V
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import "UICircleView.h"

@implementation UICircleView

@synthesize fillColor;

- (id)initWithFrame:(CGRect)frame
{
    INIT_FRAME = frame;
    self = [super initWithFrame:INIT_FRAME];
    if (self) {
        // Initialization code
        [self setOpaque:NO];
        fillColor = [UIColor whiteColor];//default
    }
    return self;
}

- (void)resetFrame
{
    [self setFrame:INIT_FRAME];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //透明背景
    CGContextTranslateCTM(context, 0.0f, rect.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    UIGraphicsPushContext(context);
    CGContextSetLineWidth(context,rect.size.width);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 0.0);
    CGContextStrokeRect(context, rect);
    UIGraphicsPopContext();
    
    //画圆
    CGContextSetFillColorWithColor(context, fillColor.CGColor);
    
    
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, rect.size.width/2-1, 0, 2 * M_PI, NO);
    
    CGContextDrawPath(context, kCGPathFill);
}


@end

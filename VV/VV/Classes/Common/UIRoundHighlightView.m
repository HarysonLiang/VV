//
//  UIRoundHighlightView.m
//  V&V
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import "UIRoundHighlightView.h"
#import "UILib.h"

@implementation UIRoundHighlightView

@synthesize radius;

- (id)initWithFrame:(CGRect)frame
{
    radius = 10.0f * [UILib getSizeScale];
    INIT_FRAME = CGRectMake(0, 0, frame.size.width + radius * 2, frame.size.height + radius * 2);
    self = [super initWithFrame:INIT_FRAME];
    if (self) {
        // Initialization code
		[self setOpaque:NO];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	
    
	// Draw the spotlight (more of a Fresnel lens effect but okay I'll stop now)
	const CGFloat components[] = {1, 1, 1, 0.2,
		1, 1, 1, 0.0};
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);
	CGPoint center = CGPointMake(rect.size.width/2, rect.size.height/2);
	CGFloat startRadius = MIN(rect.size.width - radius*2, rect.size.height - radius*2)/2;
	CGFloat endRadius = startRadius + radius;
	CGContextDrawRadialGradient(context,
								gradient,
								center, startRadius,
								center, endRadius,
								kCGGradientDrawsAfterEndLocation);
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(gradient);
    
     
    
    // Draw the clear circle
    CGContextSetRGBFillColor(context, 0, 0, 0, 0);
    CGContextFillEllipseInRect(context, CGRectMake(radius, radius, rect.size.width - radius*2, rect.size.height - radius*2));
}

- (void)resetFrame
{
    [self setFrame:INIT_FRAME];
}

@end

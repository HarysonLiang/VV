//
//  UIRoundedRectView.m
//  V&V
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import "UIRoundedRectView.h"


@implementation UIRoundedRectView

@synthesize borderColor, bgColor, radius;
@synthesize willFadeOut;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame])
	{
		[self setOpaque:NO];
		willFadeOut = NO;
	}
	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Set colors
	[borderColor setStroke];
	[bgColor setFill];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect rrect = rect;
	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	CGContextSetLineWidth(context, 1.0f);
	CGContextSetLineJoin(context, kCGLineJoinRound);
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	CGContextDrawPath(context, kCGPathEOFillStroke);
}


- (void)dealloc {
}


@end

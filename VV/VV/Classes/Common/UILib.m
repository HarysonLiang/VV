//
//  UILib.m
//  V&V
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import "UILib.h"

@implementation UILib

static float sWidth = 0;
static float sHeight = 0;

+ (void)init:(float)screenWidth height:(float)screenHeight
{
    sWidth = screenWidth;
    sHeight = screenHeight;
}

+ (int) getWidth {
    return sWidth;
}

+ (int) getHeight {
    return sHeight;
}

+ (float) getScaleX
{
    return sWidth/320;
}

+ (float) getScaleY
{
    return sHeight/568;
}

+ (float) getSizeScale
{
    return [self getScaleX] < [self getScaleY] ? [self getScaleX] : [self getScaleY];
}


+ (CGPoint) offset:(CGPoint)offset size:(CGSize)size anchor:(int)anchor{
    return [UILib offset:offset size:size superSize:CGSizeMake(sWidth, sHeight) anchor:anchor];
}


+ (CGPoint) offset:(CGPoint)offset size:(CGSize)size superSize:(CGSize)superSize anchor:(int)anchor{
    CGPoint result = CGPointZero;

    offset.x *= [self getScaleX];
    offset.y *= [self getScaleY];
    switch (anchor) {
        case ANCHOR_TOP_LEFT:
        {
            result = offset;
        }
            break;
        case ANCHOR_TOP_RIGHT:
        {
            result.x = superSize.width - offset.x - size.width;
            result.y = offset.y;
        }
            break;
        case ANCHOR_BOTTOM_LEFT:
        {
            result.x = offset.x;
            result.y = superSize.height - offset.y - size.height;
        }
            break;
        case ANCHOR_BOTTOM_RIGHT:
        {
            result.x = superSize.width - offset.x - size.width;
            result.y = superSize.height - offset.y - size.height;
        }
            break;
        case ANCHOR_CENTER:
        {
            result.x = superSize.width / 2 - (size.width / 2) - offset.x;
            result.y = superSize.height / 2 - (size.height / 2) - offset.y;
        }
            break;
        case ANCHOR_CENTER_TOP:
        {
            result.x = superSize.width / 2 - (size.width / 2) + offset.x;
            result.y = offset.y;
        }
            break;
        case ANCHOR_CENTER_LEFT:
        {
            result.x = offset.x;
            result.y = superSize.height / 2 - (size.height/2) - offset.y;
        }
            break;
        case ANCHOR_CENTER_RIGHT:
        {
            result.x = superSize.width - offset.x - size.width;
            result.y = superSize.height / 2 - (size.height/2) - offset.y;
        }
            break;
        case ANCHOR_CENTER_BOTTOM:
        {
            result.x = superSize.width / 2 - (size.width / 2) + offset.x;
            result.y = superSize.height - size.height - offset.y;
        }
            break;
            
        default:
        {
            NSLog(@"BUG: offset:wrong anchor %d", anchor);
            
            // bug case, put it in
            result.x = 0;
            result.y = 0;
        }
            break;
    }

    return result;
}

+ (CGRect)autoAdjustRect:(CGRect)orginRect
{
    float x = orginRect.origin.x*[UILib getScaleX];
    float y = orginRect.origin.y*[UILib getScaleY];
    float w = orginRect.size.width*[UILib getSizeScale];
    float h = orginRect.size.height*[UILib getSizeScale];
    
    return CGRectMake(x, y, w, h);
}

@end

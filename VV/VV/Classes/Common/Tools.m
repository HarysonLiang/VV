//
//  Tools.m
//  V&V
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import "Tools.h"

@implementation Tools

// -------------------------------------------------------------------------------
+ (int)randomNumber:(int)from to:(int)to {
    return (int)(from + arc4random() % (to-from+1));
}

/**
 * 圆形碰撞
 * @param x1 圆形1 的圆心X 坐标
 * @param y1 圆形2 的圆心X 坐标
 * @param x2 圆形1 的圆心Y 坐标
 * @param y2 圆形2 的圆心Y 坐标
 * @param r1 圆形1 的半径
 * @param r2 圆形2 的半径
 * @return
 */
+ (BOOL)isCollisionWithCircleX1:(float)x1 X2:(float)x2 Y1:(float)y1 Y2:(float)y2 R1:(float)r1 R2:(float)r2
{
    //Math.sqrt:开平方
    //Math.pow(double x, double y): X 的Y 次方
    if (sqrtf(powf(x1 - x2, 2) + pow(y1 - y2, 2)) <= r1 + r2) {
        //如果两圆的圆心距小于或等于两圆半径则认为发生碰撞
        return YES;
    }
    
    return NO;
}

+ (NSArray*)generateLinePointArrayX1:(float)x1 X2:(float)x2 Y1:(float)y1 Y2:(float)y2;
{
    //TODO
    NSMutableArray* array = [[NSMutableArray alloc] init];
    return array;
}

/**
 * 点A(x1,y1)与点B(x2,y2)之间距点长度为distance的点的坐标
 */
+ (CGPoint)seekPointWithX1:(int)x1 X2:(int)x2 Y1:(int)y1 Y2:(int)y2 distance:(int)distance
{
    int lineDistance = sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
    int dx = (float)distance / lineDistance * abs(x2 - x1);
    int dy = (float)distance / lineDistance * abs(y2 - y1);
    
    int px = x1;
    if (x1 < x2) {
        px += dx;
    } else {
        px -= dx;
    }
    
    int py = y1;
    if (y1 < y2) {
        py += dy;
    } else {
        py -= dy;
    }
    
    return CGPointMake(px, py);
}

+ (NSString*)generateScoreString:(int) score
{
    NSString* str = [NSString stringWithFormat:@"%d",score];
    if (score / 100 >= 1) {
    } else if (score / 10 >= 1) {
        str = [NSString stringWithFormat:@"0%d",score];
    } else {
        str = [NSString stringWithFormat:@"00%d",score];
    }

    return str;
}

@end

//
//  Tools.h
//  V&V
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Tools : NSObject

+ (int)randomNumber:(int)from to:(int)to;
+ (BOOL)isCollisionWithCircleX1:(float)x1 X2:(float)x2 Y1:(float)y1 Y2:(float)y2 R1:(float)r1 R2:(float)r2;
+ (NSArray*)generateLinePointArrayX1:(float)x1 X2:(float)x2 Y1:(float)y1 Y2:(float)y2;
+ (CGPoint)seekPointWithX1:(int)x1 X2:(int)x2 Y1:(int)y1 Y2:(int)y2 distance:(int)distance;

+ (NSString*)generateScoreString:(int) score;

@end

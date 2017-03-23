//
//  UILib.h
//  V&V
//
//  Created by Haryson Liang on 19/1/13.
//  Copyright (c) 2017 MobileGameTree. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ANCHOR_CENTER           1
#define ANCHOR_TOP_LEFT         2
#define ANCHOR_TOP_RIGHT        3
#define ANCHOR_BOTTOM_LEFT      4
#define ANCHOR_BOTTOM_RIGHT     5

#define ANCHOR_CENTER_TOP       6
#define ANCHOR_CENTER_LEFT      7
#define ANCHOR_CENTER_RIGHT     8
#define ANCHOR_CENTER_BOTTOM    9

@interface UILib : NSObject {
}




//-------------------------------------------------------------------------------
+ (void)init:(float)screenWidth height:(float)screenHeight;

+ (CGPoint) offset:(CGPoint)offset size:(CGSize)size anchor:(int)anchor;
+ (CGPoint) offset:(CGPoint)offset size:(CGSize)size superSize:(CGSize)superSize anchor:(int)anchor;


// get screen width / height
+ (int) getWidth;
+ (int) getHeight;
//物理屏幕尺寸的缩放
+ (float) getScaleX;
+ (float) getScaleY;
+ (float) getSizeScale;

+ (CGRect)autoAdjustRect:(CGRect)orginRect;

@end

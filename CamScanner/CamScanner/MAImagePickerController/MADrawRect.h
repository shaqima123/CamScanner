//
//  MADrawRect.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/17.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAConstants.h"

//            cd
//  d   -------------   c
//     |             |
//     |             |
//  da |             |  bc 
//     |             |
//     |             |
//     |             |
//  a   -------------   b
//            ab
//
// a = 1, b = 2, c = 3, d = 4

@interface MADrawRect : UIView
{
    CGPoint touchOffset;
    CGPoint a;
    CGPoint b;
    CGPoint c;
    CGPoint d;
    
    BOOL frameMoved;
}

@property (strong, nonatomic) UIButton *pointD;
@property (strong, nonatomic) UIButton *pointC;
@property (strong, nonatomic) UIButton *pointB;
@property (strong, nonatomic) UIButton *pointA;

- (BOOL)frameEdited;
- (void)resetFrame;
- (CGPoint)coordinatesForPoint: (int)point withScaleFactor: (CGFloat)scaleFactor;

- (void)bottomLeftCornerToCGPoint: (CGPoint)point;
- (void)bottomRightCornerToCGPoint: (CGPoint)point;
- (void)topRightCornerToCGPoint: (CGPoint)point;
- (void)topLeftCornerToCGPoint: (CGPoint)point;

@end

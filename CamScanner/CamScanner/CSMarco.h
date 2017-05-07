//
//  CSMarco.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/26.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#ifndef CSMarco_h
#define CSMarco_h


#endif /* CSMarco_h */

// 颜色值转换
#define RGB(r,g,b) \
[UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.f]

#define RGBA(r,g,b,a) \
[UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a]

#define RGBAHEX(hex,a) RGBA((float)((hex & 0xFF0000) >> 16),(float)((hex & 0xFF00) >> 8),(float)(hex & 0xFF),a)

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
// 相册 主色调
#define CSMainBlueColor RGBAHEX(0x6699cc, 1.f)

#define CSMainLightBlueColor RGBAHEX(0x99ccff, .4f)

#define CSMainGrayColor RGBAHEX(0x919194, 1.f)

#define CSMainBlackColor RGBAHEX(0x0f0f14, 1.f)

#define CSMainLightGreenColor RGBAHEX(0xccffff, 1.f)

#define CSMainGreenColor RGBAHEX(0x669966, 1.f)

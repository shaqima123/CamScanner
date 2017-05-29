//
//  CSTool.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/26.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "CSTool.h"

@implementation CSTool

+ (void)saveToAlbumWithData:(NSData *)data{
    UIImage * img = [UIImage imageWithData:data];
    [self loadImageFinished:img];
}

+ (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"警告" message:[NSString stringWithFormat:@"保存到相册失败 error:%@",error] delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        //显示alertView
        [alertView show];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"保存成功" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        //显示alertView
        [alertView show];
    }
}

+ (UIImage *)compressImage:(UIImage *)image toByte:(NSUInteger)maxLength {
    // Compress by quality
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return image;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    UIImage *resultImage = [UIImage imageWithData:data];
    if (data.length < maxLength) return resultImage;
    
    // Compress by size
    NSUInteger lastDataLength = 0;
    while (data.length > maxLength && data.length != lastDataLength) {
        lastDataLength = data.length;
        CGFloat ratio = (CGFloat)maxLength / data.length;
        CGSize size = CGSizeMake((NSUInteger)(resultImage.size.width * sqrtf(ratio)),
                                 (NSUInteger)(resultImage.size.height * sqrtf(ratio))); // Use NSUInteger to prevent white blank
        UIGraphicsBeginImageContext(size);
        [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        resultImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        data = UIImageJPEGRepresentation(resultImage, compression);
    }
    
    return resultImage;
}

@end

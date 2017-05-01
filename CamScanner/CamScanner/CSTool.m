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


@end

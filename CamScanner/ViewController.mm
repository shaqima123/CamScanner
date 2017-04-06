//
//  ViewController.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/6.
//  Copyright © 2017年 沙琪玛. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/highgui/highgui.hpp>

#import "ToolBox.h"
#import "ViewController.h"

using namespace cv;
using namespace std;

@interface ViewController ()
{
    cv::Mat cvImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    CGRect rect = [UIScreen mainScreen].bounds;
    self.imgView.frame = rect;
    
    UIImage *image = [UIImage imageNamed:@"test.png"];
    cvImage = [ToolBox cvMatFromUIImage:image];
//    UIImageToMat(image, cvImage);
    
    if(!cvImage.empty()){
        cv::Mat gray;
        // 将图像转换为灰度显示
        cv::cvtColor(cvImage,gray,CV_RGB2GRAY);
        // 应用高斯滤波器去除小的边缘
        cv::GaussianBlur(gray, gray, cv::Size(5,5), 1.2,1.2);
        // 计算与画布边缘
        cv::Mat edges;
        cv::Canny(gray, edges, 0, 50);
        // 使用白色填充
        cvImage.setTo(cv::Scalar::all(225));
        // 修改边缘颜色
        cvImage.setTo(cv::Scalar(0,128,255,255),edges);
        // 将Mat转换为Xcode的UIImageView显示
//        self.imgView.image = MatToUIImage(cvImage);
        self.imgView.image = [ToolBox UIImageFromCVMat:cvImage];
    }
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

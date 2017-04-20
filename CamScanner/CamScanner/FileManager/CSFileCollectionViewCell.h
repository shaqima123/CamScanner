//
//  CSFileCollectionViewCell.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/17.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSFileCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileCreateTime;
@property (weak, nonatomic) IBOutlet UILabel *fileLabel;

@end

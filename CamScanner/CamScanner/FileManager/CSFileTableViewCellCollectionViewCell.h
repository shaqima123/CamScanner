//
//  CSFileTableViewCellCollectionViewCell.h
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/25.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSFileTableViewCellCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *fileImage;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileCreateTime;
@property (weak, nonatomic) IBOutlet UILabel *fileLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@end

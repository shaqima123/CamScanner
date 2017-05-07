//
//  CSFileTableViewCellCollectionViewCell.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/4/25.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "CSFileTableViewCellCollectionViewCell.h"
#import "CSMarco.h"

@implementation CSFileTableViewCellCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [_selectButton setHidden:YES];
    CALayer *layer=[self.fileImage layer];
    //是否设置边框以及是否可见
    [layer setMasksToBounds:YES];
    
    [layer setBorderWidth:1];
    //设置边框线的颜色
    [layer setBorderColor:[CSMainGreenColor CGColor]];
}

@end

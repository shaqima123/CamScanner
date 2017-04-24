//
//  MAViewController.m
//  CamScanner
//
//  Created by Maximilian Mackh on 11/5/12.
//  Copyright (c) 2012 mackh ag. All rights reserved.
//

#import "MAViewController.h"
#import "CSFileCollectionViewCell.h"
#import "MAAppDelegate.h"

@interface MAViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *fileCollectionView;
@end

@implementation MAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initView];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)initView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    float itemWidth = 111.0;
    float itemHeight = 150.0;
    
    layout.minimumInteritemSpacing = 5.f;// 垂直方向的间距
    layout.minimumLineSpacing = (self.fileCollectionView.frame.size.width - itemWidth * 3)/2; // 水平方向的间距
   
    layout.itemSize = CGSizeMake(itemWidth,itemHeight);
    [_fileCollectionView setCollectionViewLayout:layout];
    _fileCollectionView.backgroundColor = [UIColor whiteColor];
    _fileCollectionView.alwaysBounceVertical=YES;
    _fileCollectionView.dataSource = self;
    _fileCollectionView.delegate = self;
    NSLog(@"width: %f,height:%f",self.fileCollectionView.frame.size.width,self.fileCollectionView.frame.size.height);
    
    [_fileCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([CSFileCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:@"FILECELL"];
    
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"WWCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
    //
    //    // 注册collectionview底部的view,需要注意的是这里的view需要继承自UICollectionReusableView
    //    [self.collectionView registerNib:[UINib nibWithNibName:@"WWCollectionFooterReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"footer"];
}

- (void)initData{
    MAAppDelegate *myDelegate = [[UIApplication sharedApplication] delegate];
    _fileArray = myDelegate.fileArray;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 15;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CSFileCollectionViewCell *cell = (CSFileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"FILECELL" forIndexPath:indexPath];
    if (cell) {
        cell.fileName.text = @"new file";
        cell.fileName.textColor = [UIColor blackColor];
        cell.backgroundColor = [UIColor yellowColor];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)initButton:(id)sender
{
    MAImagePickerController *imagePicker = [[MAImagePickerController alloc] init];
   
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:MAImagePickerControllerSourceTypeCamera];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePicker];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)imagePickerDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerDidChooseImageWithPath:(NSString *)path
{
   // [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"File Found at %@", path);
        
    }
    else
    {
        NSLog(@"No File Found at %@", path);
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end

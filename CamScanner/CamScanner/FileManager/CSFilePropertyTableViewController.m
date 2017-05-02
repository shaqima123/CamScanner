//
//  CSFilePropertyTableViewController.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/5/2.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "CSFilePropertyTableViewController.h"
#import "CSNormalTableViewCell.h"

@interface CSFilePropertyTableViewController ()

@end

@implementation CSFilePropertyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"文档属性";
    [self.tableView registerNib:[UINib nibWithNibName:@"CSNormalTableViewCell" bundle:nil] forCellReuseIdentifier:@"CELL"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 1;
            break;
        case 3:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CSNormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CELL" forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:
            [cell.leftLabel setText:@"文件名"];
            [cell.rightLabel setText:_csfile.fileName];
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    [cell.leftLabel setText:@"文件类型"];
                    [cell.rightLabel setText:@"PDF"];
                    break;
                case 1:
                    [cell.leftLabel setText:@"文件大小"];
                    [cell.rightLabel setText:_csfile.fileSize];
                    break;
                case 2:
                {
                    [cell.leftLabel setText:@"创建时间"];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    
                    [formatter setDateFormat:@"YYYY年MM月dd日 HH时mm分ss秒"];
                    NSString *currentTimeString = [formatter stringFromDate:_csfile.fileCreatedTime];
                    [cell.rightLabel setText:currentTimeString];
                    break;
                }
                default:
                    break;
            }
        }
            break;
        case 2:
            [cell.leftLabel setText:@"标签"];
            [cell.rightLabel setText:_csfile.fileLabel];
            break;
        case 3:
            [cell.leftLabel setText:@"PDF方向"];
            [cell.rightLabel setText:@"纵向"];
            break;
        default:
            break;
    }
    [cell layoutSubviews];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

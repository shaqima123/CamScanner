//
//  MoreOperationViewController.m
//  CamScanner
//
//  Created by 沙琪玛 on 2017/5/2.
//  Copyright © 2017年 mackh ag. All rights reserved.
//

#import "MoreOperationViewController.h"
#import "CSFilePropertyTableViewController.h"
@interface MoreOperationViewController ()

@end

@implementation MoreOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)toFileProperty:(id)sender {
    [self performSegueWithIdentifier:@"ToCSFileProperty" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"ToCSFileProperty"]){
        CSFilePropertyTableViewController *vc = segue.destinationViewController;
        vc.csfile = _csfile;
    }
}

@end

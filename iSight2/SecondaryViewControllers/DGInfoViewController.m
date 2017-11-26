//
//  DGInfoViewController.m
//  iSight2
//
//  Created by Kevin Hunt on 2017-11-19.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import "DGInfoViewController.h"

@interface DGInfoViewController ()

@end

@implementation DGInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view.
    [self.textView setContentOffset:CGPointZero animated:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneButtonPresed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

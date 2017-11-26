//
//  DBSettingsViewController.m
//  iSight2
//
//  Created by Kevin Hunt on 2017-11-19.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import "DBSettingsViewController.h"
#import "DGConstants.h"

@interface DBSettingsViewController ()

@end

@implementation DBSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark Button Methods

-(IBAction)openFacebook:(id)sender {
//    [Flurry logEvent:@"Facebook page shown"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://facebook.com/Official.Prophet.Studios/"] options:[NSDictionary dictionary] completionHandler:nil];
}

-(IBAction)openTwitter:(id)sender {
//    [Flurry logEvent:@"Twitter page shown"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/ProphetStudios/"] options:[NSDictionary dictionary] completionHandler:nil];
}

-(IBAction)openWebsite:(id)sender {
//    [Flurry logEvent:@"Web page shown"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://prophetstudios.com/"] options:[NSDictionary dictionary] completionHandler:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return DGSettingsItemCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    NSInteger row = indexPath.row;
    
    switch(row) {
        case DGSettingsItemTerms: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DGTermsCell" forIndexPath:indexPath];
            break;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellSingleRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kSettingsFooterHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.aboutView;
}

@end

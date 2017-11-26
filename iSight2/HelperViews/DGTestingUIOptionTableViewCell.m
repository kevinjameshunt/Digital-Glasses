//
//  DGTestingUIOptionTableViewCell.m
//  DigitalGlasses
//
//  Created by Kevin Hunt on 2015-09-19.
//  Copyright © 2015 ProphetStudios. All rights reserved.
//

#import "DGTestingUIOptionTableViewCell.h"
#import "DGAppDelegate.h"

@implementation DGTestingUIOptionTableViewCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)testingUISwitchChanged:(id)sender {
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch *testingUISwitch = (UISwitch *)sender;
        DGAppDelegate *AppDel = (DGAppDelegate *)[[UIApplication sharedApplication] delegate];
        AppDel.showOnScreenControls = testingUISwitch.isOn;
    }
}

@end

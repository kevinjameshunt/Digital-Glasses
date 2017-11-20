//
//  ISTestingUIOptionTableViewCell.h
//  iSight2
//
//  Created by Kevin Hunt on 2015-09-19.
//  Copyright © 2015 ProphetStudios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISTestingUIOptionTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UISwitch *testingUISwitch;

- (IBAction)testingUISwitchChanged:(id)sender;

@end

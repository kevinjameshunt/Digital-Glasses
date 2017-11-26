//
//  DBInstructionsViewController.h
//  iSight2
//
//  Created by Kevin Hunt on 2017-11-19.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBInstructionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)closeButtonPressed:(id)sender;

@end

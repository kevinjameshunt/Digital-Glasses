//
//  DBSettingsViewController.h
//  iSight2
//
//  Created by Kevin Hunt on 2017-11-19.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBSettingsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIView *aboutView;

-(IBAction)openFacebook:(id)sender;
-(IBAction)openTwitter:(id)sender;
-(IBAction)openWebsite:(id)sender;
- (IBAction)closeButtonPressed:(id)sender;

@end

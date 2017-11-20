//
//  InterfaceController.h
//  WatchControl Extension
//
//  Created by Kevin Hunt on 2017-04-30.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController : WKInterfaceController <WCSessionDelegate>

@property (nonatomic, readonly) WCSession* watchSession;

@property (strong, nonatomic) IBOutlet WKInterfaceTable *tableView;

@end

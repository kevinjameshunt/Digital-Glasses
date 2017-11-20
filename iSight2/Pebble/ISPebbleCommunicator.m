//
//  ISPebbleCommunicator.m
//  iSight2
//
//  Created by Kevin Hunt on 2015-08-30.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PebbleKit/PebbleKit.h>
#import <PebbleKit/PBWatch+AppMessages.h>
#import "ISPebbleCommunicator.h"

#define KEY_BUTTON_UP   0
#define KEY_BUTTON_DOWN 1

@implementation ISPebbleCommunicator


static ISPebbleCommunicator *pebbleCommunicator = nil;

+ (ISPebbleCommunicator *) sharedPebbleCommunicator {
    if (pebbleCommunicator == nil){ 
        pebbleCommunicator = [[super alloc] init];
    }
    return pebbleCommunicator;
}

- (id)init {
    if (self = [super init]) {
        self.watch = [[PBPebbleCentral defaultCentral] lastConnectedWatch];

        NSLog(@"CONNECTED WATCH");
        
        uuid_t appUUIDbytes;
        NSUUID *appUUID = [[NSUUID alloc] initWithUUIDString: @"69a1a821-6788-4dc0-ad2f-4be47b9820cf"];
        [appUUID getUUIDBytes:appUUIDbytes];
        
        [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:appUUIDbytes length:16]];
        
        [self.watch appMessagesLaunch:^void(PBWatch *watch, NSError *error) {
            NSLog(@"Watch app launched");
        }];
        
        [self.watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
            [self performSelectorInBackground:@selector(notifyDelegateOfPebbleUpdate:) withObject:update];
            return YES;
        }];
    }
    return self;
}

- (void)notifyDelegateOfPebbleUpdate:(NSDictionary *) dict {
    NSLog(@"Received data: %@",dict);
    if (self.communicatorDelegate && [self.communicatorDelegate respondsToSelector:@selector(pebbleCommunicatorDidReceiveData:)]) {
        [self.communicatorDelegate pebbleCommunicatorDidReceiveData:dict];
    }
}

@end
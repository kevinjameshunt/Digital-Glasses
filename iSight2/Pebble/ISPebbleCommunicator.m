//
//  ISPebbleCommunicator.m
//  DigitalGlasses
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

//        NSLog(@"CONNECTED WATCH");
        
        uuid_t appUUIDbytes;
        NSUUID *appUUID = [[NSUUID alloc] initWithUUIDString: @"69a1a821-6788-4dc0-ad2f-4be47b9820cf"];
        [appUUID getUUIDBytes:appUUIDbytes];
        
        [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:appUUIDbytes length:16]];
        
        // Connect to the watch
        [self.watch appMessagesLaunch:^void(PBWatch *watch, NSError *error) {
            if (error) {
                NSLog(@"Pebble Watch app failed to launch.");
                [self performSelectorInBackground:@selector(notifyDelegateOfPebbleConnectWithError:) withObject:error];
            } else {
                NSLog(@"Pebble Watch app launched.");
                [self performSelectorInBackground:@selector(notifyDelegateOfPebbleConnectWithError:) withObject:nil];
            }
        }];
        
        // Set handler for receiving data
        [self.watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
            // When we receive data, we notify our delegate in a backgorund thread
            [self performSelectorInBackground:@selector(notifyDelegateOfPebbleUpdate:) withObject:update];
            return YES;
        }];
    }
    return self;
}

- (void)notifyDelegateOfPebbleConnectWithError:(NSError *)error {
    // If we have a delegate and it responds to the selector
    if (self.communicatorDelegate && [self.communicatorDelegate respondsToSelector:@selector(pebbleCommunicatorDidConnectWithError:)]) {
        [self.communicatorDelegate pebbleCommunicatorDidConnectWithError:error];
    }
}

- (void)notifyDelegateOfPebbleUpdate:(NSDictionary *) dict {
    NSLog(@"Received data: %@",dict);
    // If we have a delegate and it responds to the selector
    if (self.communicatorDelegate && [self.communicatorDelegate respondsToSelector:@selector(pebbleCommunicatorDidReceiveData:)]) {
        [self.communicatorDelegate pebbleCommunicatorDidReceiveData:dict];
    }
}

@end

//
//  ISPebbleCommunicator.h
//  iSight2
//
//  Created by Kevin Hunt on 2015-08-30.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.
//

#ifndef iSight_ISPebbleCommunicator_h
#define iSight_ISPebbleCommunicator_h
#endif

#import <PebbleKit/PebbleKit.h>

@protocol ISPebbleCommunicatorDelegate;

@interface ISPebbleCommunicator : PBPebbleCentral {
    
}

@property PBWatch *watch;
@property BOOL watchAppRunning;
@property id<ISPebbleCommunicatorDelegate> communicatorDelegate;

+ (ISPebbleCommunicator *)sharedPebbleCommunicator;
//- (void)onReceive:(PBWatch *)watch :(NSDictionary *) dict;

@end

@protocol ISPebbleCommunicatorDelegate <NSObject>

-(void)pebbleCommunicatorDidReceiveData:(NSDictionary *)dict;

@end
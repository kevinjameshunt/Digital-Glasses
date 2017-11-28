//
//  DGPebbleManager.h
//  DigitalGlasses
//
//  Created by Kevin Hunt on 2015-08-30.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.
//

#ifndef iSight_DGPebbleManager_h
#define iSight_DGPebbleManager_h
#endif

#import <PebbleKit/PebbleKit.h>

@protocol DGPebbleManagerDelegate;

@interface DGPebbleManager : NSObject <PBPebbleCentralDelegate>

@property PBWatch *watch;
@property BOOL watchAppRunning;
@property id<DGPebbleManagerDelegate> communicatorDelegate;

+ (DGPebbleManager *)sharedPebbleManager;
//- (void)onReceive:(PBWatch *)watch :(NSDictionary *) dict;

@end

@protocol DGPebbleManagerDelegate <NSObject>

-(void)pebbleManagerDidConnectWithError:(NSError *)error;
-(void)pebbleManagerDidReceiveData:(NSDictionary *)dict;

@end

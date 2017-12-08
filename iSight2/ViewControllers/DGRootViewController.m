 //
//  DGRootViewController.m
//  DigitalGlasses
//
//  Created by Kevin Hunt on 2015-08-30.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.
//


#import "DGRootViewController.h"
#import <QuartzCore/QuartzCore.h>
//#import "DGPebbleManager.h"
#import "Flurry.h"

@implementation DGRootViewController {

}

- (instancetype)init
{
    if ((self = [super init])) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Flurry logEvent:@"Main page loaded"];
    
    // Start communicating with Pebble if possible
//    [DGPebbleManager sharedPebbleManager];
    
    // Round the buttons
    _magnifierButton.layer.cornerRadius = 10;
    _magnifierButton.clipsToBounds = YES;
    _headsetButton.layer.cornerRadius = 10;
    _headsetButton.clipsToBounds = YES;
    
    
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

@end

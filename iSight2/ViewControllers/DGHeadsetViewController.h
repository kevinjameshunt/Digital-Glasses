//
//  DGHeadsetViewController.h
//  iSight2
//
//  Created by Kevin Hunt on 2017-11-19.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DGConstants.h"

#import <FastttCamera/FastttFilterCamera.h>
#import <GPUImage/GPUImage.h>

#import <PebbleKit/PebbleKit.h>
#import "DGPebbleManager.h"

#import <WatchConnectivity/WatchConnectivity.h>

#import "iCadeReaderView.h"

@interface DGHeadsetViewController : FastttFilterCamera <DGPebbleManagerDelegate, iCadeEventDelegate, WCSessionDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *instructionlabel;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

- (IBAction)closeButtonPressed:(id)sender;

@end

//
//  ISRootViewController.h
//  iSight2
//
//  Created by Kevin Hunt on 2015-08-30.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FastttCamera/FastttFilterCamera.h>
#import <GPUImage/GPUImage.h>

#import <PebbleKit/PebbleKit.h>
#import "ISPebbleCommunicator.h"

#import <WatchConnectivity/WatchConnectivity.h>

#import "iCadeReaderView.h"

#define BKM_IS_NOT_MAIN_THREAD() \
([NSThread currentThread] != [NSThread mainThread])

#define BKM_REQUEUE_ON_MAIN_THREAD(__ONE_ARG) \
[self performSelectorOnMainThread : _cmd withObject : __ONE_ARG waitUntilDone : NO]

typedef NS_ENUM(NSInteger, DGUIDisplayState) {
    DGUIDisplayStateSettings,
    DGUIDisplayStateMagnifier,
    DGUIDisplayStateCardboard
};

@interface ISRootViewController : FastttFilterCamera <ISPebbleCommunicatorDelegate, iCadeEventDelegate, WCSessionDelegate, UITableViewDataSource, UITableViewDelegate>

// Testing UI
@property (nonatomic, strong) IBOutlet UIBarButtonItem *takePhotoButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *catureVideoButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *flashButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *torchButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *resetButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsButton;
@property (nonatomic, strong) IBOutlet UISlider *zoomSlider;
@property (nonatomic, strong) IBOutlet UIStepper *brightnessControl;
@property (nonatomic, strong) IBOutlet UIStepper *contrastControl;
@property (nonatomic, strong) IBOutlet UIStepper *saturationControl;
@property (nonatomic, strong) IBOutlet UIToolbar *cameraControlsToolbar;
@property (nonatomic, strong) IBOutlet UIView *filterTestingView;
@property (nonatomic, strong) IBOutlet UITableView *optionsTableView;

- (IBAction)sliderVaueChanged:(id)sender;
- (IBAction)takePhotoButtonPressed:(id)sender;
- (IBAction)flashButtonPressed:(id)sender;
- (IBAction)torchButtonPressed:(id)sender;
- (IBAction)brightnessValueChanged:(id)sender;
- (IBAction)contrastValueChanged:(id)sender;
- (IBAction)saturationValueChanged:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;
- (IBAction)settingsButtonPressed:(id)sender;

@end


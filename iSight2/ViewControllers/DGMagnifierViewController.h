//
//  DGMagnifierViewController.h
//  iSight2
//
//  Created by Kevin Hunt on 2017-11-19.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FastttCamera/FastttFilterCamera.h>
#import <GPUImage/GPUImage.h>

@interface DGMagnifierViewController : FastttFilterCamera <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *takePhotoButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *catureVideoButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *flashButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *torchButton;
@property (nonatomic, strong) IBOutlet UISlider *zoomSlider;
@property (strong, nonatomic) IBOutlet UIButton *resetButton;
@property (strong, nonatomic) IBOutlet UIPickerView *filterPicker;
@property (nonatomic, strong) IBOutlet UIStepper *filterControl;
@property (nonatomic, strong) IBOutlet UIToolbar *cameraControlsToolbar;
@property (nonatomic, strong) IBOutlet UIView *filterTestingView;

- (IBAction)sliderVaueChanged:(id)sender;
- (IBAction)filterValueChanged:(id)sender;
- (IBAction)resetButtonPressed:(id)sender;
- (IBAction)torchButtonPressed:(id)sender;
- (IBAction)flashButtonPressed:(id)sender;
- (IBAction)takePhotoButtonPressed:(id)sender;
- (IBAction)captureVideoButtonPressed:(id)sender;
- (IBAction)closeButtonPressed:(id)sender;

@end

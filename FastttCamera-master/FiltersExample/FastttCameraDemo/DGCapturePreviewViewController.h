//
//  ConfirmViewController.h
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

@import UIKit;
@class FastttCapturedImage;
@protocol DGCaptureConfirmControllerDelegate;

@interface DGCapturePreviewViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIBarButtonItem *confirmButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, strong) IBOutlet UIToolbar *onScreenControls;
@property (nonatomic, strong) IBOutlet UIView *instructionsView;
@property (nonatomic, weak) id <DGCaptureConfirmControllerDelegate> delegate;
@property (nonatomic, strong) FastttCapturedImage *capturedImage;
@property (nonatomic, assign) BOOL imagesReady;

- (IBAction)dismissConfirmController:(id)sender;
- (IBAction)confirmButtonPressed:(id)sender;

@end

@protocol DGCaptureConfirmControllerDelegate <NSObject>

- (void)dismissConfirmController:(DGCapturePreviewViewController *)controller;

@end

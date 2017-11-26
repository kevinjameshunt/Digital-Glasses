//
//  ConfirmViewController.m
//  FastttCamera
//
//  Created by Laura Skelton on 2/9/15.
//  Copyright (c) 2015 IFTTT. All rights reserved.
//

#import "DGCapturePreviewViewController.h"
#import "DGAppDelegate.h"
#import <FastttCamera/FastttCapturedImage.h>
@import AssetsLibrary;
@import MessageUI;

@interface DGCapturePreviewViewController ()

@property (nonatomic, strong) UIImageView *previewImageViewFullscreen;
@property (nonatomic, strong) UIImageView *previewImageViewL;
@property (nonatomic, strong) UIImageView *previewImageViewR;

@end

@implementation DGCapturePreviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // Setup the image preview
    [self setupImagePreview];
    
    // If we are in the cardboard state
    if (_displayState == DGUIDisplayStateCardboard) {
        // Show the instructions view
        self.onScreenControls.hidden = YES;
        self.instructionsView.hidden = NO;
        [self.view bringSubviewToFront:self.instructionsView];
        
        // Add labels on the screen
        NSString *dualViewInstructions = @"UP to save, DOWN to cancel";
        CGRect leftLabelFrame = CGRectMake(10, 10, self.instructionsView.frame.size.width/2-20, self.instructionsView.frame.size.height-20);
        CGRect rightLabelFrame = CGRectMake(self.instructionsView.frame.size.width/2+10, 10, self.instructionsView.frame.size.width/2-20, self.instructionsView.frame.size.height-20);
        UILabel *instructionsLabelL = [[UILabel alloc] initWithFrame:leftLabelFrame];
        UILabel *instructionsLabelR = [[UILabel alloc] initWithFrame:rightLabelFrame];
        instructionsLabelL.text = dualViewInstructions;
        instructionsLabelR.text = dualViewInstructions;
        [self.instructionsView addSubview:instructionsLabelL];
        [self.instructionsView addSubview:instructionsLabelR];
    } else {
        // if we are in the the magnifier view, show the controls
        self.onScreenControls.hidden = NO;
        self.instructionsView.hidden = YES;
        [self.view bringSubviewToFront:self.onScreenControls];
    }
    
    if (!self.capturedImage.isNormalized) {
        self.confirmButton.enabled = NO;
    }
}

- (void)setImagesReady:(BOOL)imagesReady
{
    _imagesReady = imagesReady;
    if (imagesReady) {
        self.confirmButton.enabled = YES;
    }
}

- (void)setupImagePreview {
    
    if (_displayState == DGUIDisplayStateCardboard) {
        _previewImageViewL = [[UIImageView alloc] initWithImage:self.capturedImage.rotatedPreviewImage];
        _previewImageViewR = [[UIImageView alloc] initWithImage:self.capturedImage.rotatedPreviewImage];
        
        self.previewImageViewL.contentMode = UIViewContentModeScaleAspectFill;
        self.previewImageViewR.contentMode = UIViewContentModeScaleAspectFill;
        
        // Set the frame to cover only the left side of the screen
        self.previewImageViewL.frame = CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height);
        
        // Set the frame to cover only the right side of the screen
        self.previewImageViewR.frame = CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, self.view.frame.size.height);
        
         // Add as a subview
        [self.view insertSubview:self.previewImageViewL atIndex:0];
        [self.view insertSubview:self.previewImageViewR atIndex:0];
    } else {
        _previewImageViewFullscreen = [[UIImageView alloc] initWithImage:self.capturedImage.rotatedPreviewImage];
        
        _previewImageViewFullscreen.contentMode = UIViewContentModeScaleAspectFill;
        
        // Set the frame to cover the whole screen
        _previewImageViewFullscreen.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        // Add as a subview
        [self.view insertSubview:_previewImageViewFullscreen atIndex:0];
    }
}

#pragma mark - Actions

- (IBAction)dismissConfirmController:(id)sender
{
    [self.delegate dismissConfirmController:self];
}

- (IBAction)confirmButtonPressed:(id)sender
{
    
    [self savePhotoToCameraRoll];
}

- (void)savePhotoToCameraRoll
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeImageToSavedPhotosAlbum:[self.capturedImage.fullImage CGImage]
                              orientation:(ALAssetOrientation)[self.capturedImage.fullImage imageOrientation]
                          completionBlock:^(NSURL *assetURL, NSError *error){
                              if (error) {
                                  NSLog(@"Error saving photo: %@", error.localizedDescription);
                              } else {
                                  NSLog(@"Saved photo to saved photos album.");
                              }
                              [self.delegate dismissConfirmController:self];
                          }];
}

@end

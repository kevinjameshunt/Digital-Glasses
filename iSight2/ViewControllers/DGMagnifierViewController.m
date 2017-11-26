//
//  DGMagnifierViewController.m
//  iSight2
//
//  Created by Kevin Hunt on 2017-11-19.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import "DGMagnifierViewController.h"
#import "DGCapturePreviewViewController.h"
#import "DGFilterBase.h"
#import "DGFilterRange.h"
#import "DGFilterImageFactory.h"
#import "DGConstants.h"

@interface DGMagnifierViewController () <FastttCameraDelegate, DGCaptureConfirmControllerDelegate>

@property (nonatomic, strong) FastttFilterCamera *fastCamera;
@property (nonatomic, strong) DGFilterRange *currentFilter;
@property (nonatomic, strong) DGCapturePreviewViewController *confirmController;
@property (nonatomic, strong) DGFilterRange *brightnessFilter;
@property (nonatomic, strong) DGFilterRange *contrastFilter;
@property (nonatomic, strong) DGFilterRange *saturationFilter;

@end

@implementation DGMagnifierViewController {
    BOOL _aspectRatioFixed;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    _aspectRatioFixed = NO;
    
    // Create the camera
    _currentFilter = [DGFilterBase filterWithType:ISFilterTypeNone];
    _fastCamera = [FastttFilterCamera cameraWithFilterImage:self.currentFilter.filterImage];
    self.fastCamera.delegate = self;
    self.fastCamera.maxScaledDimension = 600.f;
    [self.fastCamera setCameraDevice:FastttCameraDeviceRear];
    [self.fastCamera setCameraFlashMode:FastttCameraFlashModeOff];
    [self.fastCamera setCameraTorchMode:FastttCameraTorchModeOff];
    
    // Create the filter objects
    _brightnessFilter = [DGFilterImageFactory filterRangeForFilterType:ISFilterTypeBrightness];
    _contrastFilter = [DGFilterImageFactory filterRangeForFilterType:ISFilterTypeContrast];
    _saturationFilter = [DGFilterImageFactory filterRangeForFilterType:ISFilterTypeSaturation];

    // Set the default values
    _filterControl.minimumValue = _brightnessFilter.minFilterValue;
    _filterControl.maximumValue = _brightnessFilter.maxFilterValue;
    _filterControl.stepValue = _brightnessFilter.filterValueIncrement;
    _filterControl.value = 0;

    [self resetAllFilters];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.confirmController = nil;
    
    // Add the filter camera to the view heirarchy
    [self setupMagnifierView];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self tearDownMagnifierView];
}

- (void)viewDidUnload {
    
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self setupMagnifierView];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
//    [self setupMagnifierView];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
//    [self tearDownMagnifierView];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [self tearDownMagnifierView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - Fast Camera Functions

- (void)setupMagnifierView {
    // Add camera to this view
    [self addChildViewController:self.fastCamera];
    [self.fastCamera didMoveToParentViewController:self];
    [self.view insertSubview:self.fastCamera.view atIndex:0];
    
    // Set the frame to cover only the left side of the screen
    self.fastCamera.view.frame = CGRectMake(0, 0,
                                            self.view.frame.size.width,
                                            self.view.frame.size.height - self.filterTestingView.frame.size.height - self.cameraControlsToolbar.frame.size.height);
}

- (void)tearDownMagnifierView {
    [self.fastCamera.view removeFromSuperview];
    //    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)updateCurrentFilterRangeWithIncrease:(BOOL)increase {
    // Ensure this is only called on the appropriate filters
    if ([self.currentFilter isKindOfClass:[DGFilterRange class]]) {
        DGFilterRange *tempFilter = (DGFilterRange *)self.currentFilter;
        
        // If we have been instructed to increase the filter value
        if (increase){
            [tempFilter increaseFilterValue];
        } else {
            // If not, we decrease it
            [tempFilter decreaseFilterValue];
        }
        NSLog(@"Updating filter: %@ increase: %d, new value: %ld", tempFilter.filterName, increase, (long)tempFilter.filterValue);
        
        self.currentFilter = tempFilter;
        // Get the new image for the updated filter value and pass to camera
        self.fastCamera.filterImage = self.currentFilter.filterImage;
    } else {
        NSLog(@"Update filter range called on non-range filter");
    }
}

- (void)updateTorchState:(BOOL)torchOn {
    FastttCameraTorchMode torchMode;
    NSString *torchTitle;
    if (torchOn) {
        torchMode = FastttCameraTorchModeOn;
        torchTitle = [NSString stringWithFormat:@"%@: ON",kDGTorchLabel];
    } else {
        torchMode = FastttCameraTorchModeOff;
        torchTitle = [NSString stringWithFormat:@"%@: OFF",kDGTorchLabel];
    }
    if ([self.fastCamera isTorchAvailableForCurrentDevice]) {
        [self.fastCamera setCameraTorchMode:torchMode];
        [self.torchButton setTitle:torchTitle];
    }
}

- (void)updateFlashState:(BOOL)flashOn {
    FastttCameraFlashMode flashMode;
    NSString *flashTitle;
    if (flashOn) {
        flashMode = FastttCameraFlashModeOn;
        flashTitle = [NSString stringWithFormat:@"%@: ON",kDGFlashLabel];
    } else {
        flashMode = FastttCameraFlashModeOff;
        flashTitle = [NSString stringWithFormat:@"%@: OFF",kDGFlashLabel];
    }
    if ([self.fastCamera isFlashAvailableForCurrentDevice]) {
        [self.fastCamera setCameraFlashMode:flashMode];
        [self.flashButton setTitle:flashTitle];
    }
}

- (void)resetAllFilters {
    // reset the filter by setting the generic filter image. This is easier than clearing the target heirarchy and recreating the zoom filter
    _currentFilter = [DGFilterBase filterWithType:ISFilterTypeNone];
    self.fastCamera.filterImage = _currentFilter.filterImage;
    
    // Reset the zoom scale rather than recreating the filter
    self.zoomSlider.value = 1.0;
    [self.fastCamera setZoomScale:1.0];
    
    // Reset the values of all the filters
    _filterControl.value = 0;
    _brightnessFilter.filterValue = 0;
    _contrastFilter.filterValue = 0;
    _saturationFilter.filterValue = 0;
}



#pragma mark - IFTTTFastttCameraDelegate

- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishCapturingImage:(FastttCapturedImage *)capturedImage
{
    NSLog(@"A photo was taken");
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _confirmController = [sb instantiateViewControllerWithIdentifier:@"DGCapturePreviewViewController"];
    self.confirmController.capturedImage = capturedImage;
    self.confirmController.delegate = self;
    
    UIView *flashView = [[UIView alloc] initWithFrame:self.view.frame];
    flashView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
    flashView.alpha = 0.f;
    [self.view addSubview:flashView];
    
    [UIView animateWithDuration:0.15f
                          delay:0.f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         flashView.alpha = 1.f;
                     }
                     completion:^(BOOL finished) {
                         
                         [self.view insertSubview:self.confirmController.view belowSubview:flashView];
                         
                         [UIView animateWithDuration:0.15f
                                               delay:0.05f
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              flashView.alpha = 0.f;
                                          }
                                          completion:^(BOOL finished2) {
                                              [flashView removeFromSuperview];
                                          }];
                     }];
}

- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishNormalizingCapturedImage:(FastttCapturedImage *)capturedImage
{
    NSLog(@"Photos are ready");
    
    self.confirmController.imagesReady = YES;
}

#pragma mark - ConfirmControllerDelegate

- (void)dismissConfirmController:(DGCapturePreviewViewController *)controller
{
    [self fastttRemoveChildViewController:controller];
}

#pragma mark - UIPickerViewDataSource and Delegate

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return DGFilterPickerTypeCount;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return NSStringFromDGFilterPickerType(row);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (row) {
        case DGFilterPickerTypeBrightness:
            _currentFilter = self.brightnessFilter;
            break;
        case DGFilterPickerTypeContrast:
            _currentFilter = self.contrastFilter;
            break;
        case DGFilterPickerTypeSaturation:
            _currentFilter = self.saturationFilter;
            break;
        default:
            break;
    }
    // Update the control value
    _filterControl.minimumValue = _currentFilter.minFilterValue;
    _filterControl.maximumValue = _currentFilter.maxFilterValue;
    _filterControl.stepValue = _currentFilter.filterValueIncrement;
    _filterControl.value = _currentFilter.filterValue;
    
    // Update the filter
    self.fastCamera.filterImage = _currentFilter.filterImage;
}

#pragma mark - Action Handlers

- (IBAction)sliderVaueChanged:(id)sender {
    NSLog(@"Zoom changed: %f",self.zoomSlider.value);
    [self.fastCamera setZoomScale:self.zoomSlider.value];
}

- (IBAction)filterValueChanged:(id)sender {
    if ([sender isKindOfClass:[UIStepper class]]) {
        UIStepper *control = (UIStepper *)sender;
        
        // Get the current filter
        NSInteger selectedFilter = [self.filterPicker selectedRowInComponent:0];
        switch (selectedFilter) {
            case DGFilterPickerTypeBrightness:
                _currentFilter = self.brightnessFilter;
                break;
            case DGFilterPickerTypeContrast:
                _currentFilter = self.contrastFilter;
                break;
            case DGFilterPickerTypeSaturation:
                _currentFilter = self.saturationFilter;
                break;
            default:
                break;
        }
        self.currentFilter.filterValue = control.value;
    }
    self.fastCamera.filterImage = self.currentFilter.filterImage;
}

- (IBAction)resetButtonPressed:(id)sender {
    [self resetAllFilters];
}

- (IBAction)torchButtonPressed:(id)sender {
    NSLog(@"torch button pressed");
    
    switch(self.fastCamera.cameraTorchMode) {
        case FastttCameraTorchModeOn:
            [self updateTorchState:NO];
            break;
        case FastttCameraTorchModeOff:
            [self updateTorchState:YES];
        default:
            break;
    }
}

- (IBAction)flashButtonPressed:(id)sender {
    NSLog(@"flash button pressed");
    
    switch(self.fastCamera.cameraFlashMode) {
        case FastttCameraFlashModeOn:
            [self updateFlashState:NO];
            break;
        case FastttCameraFlashModeOff:
            [self updateFlashState:YES];
        default:
            break;
    }
}

- (IBAction)takePhotoButtonPressed:(id)sender
{
    NSLog(@"Take photo button pressed");
    
    [self.fastCamera takePicture];
}

- (IBAction)captureVideoButtonPressed:(id)sender
{
    NSLog(@"Capture video button pressed");
    
    [self.fastCamera captureVideo];
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

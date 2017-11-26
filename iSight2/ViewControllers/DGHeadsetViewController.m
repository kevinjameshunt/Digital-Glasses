//
//  DGHeadsetViewController.m
//  iSight2
//
//  Created by Kevin Hunt on 2017-11-19.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import "DGHeadsetViewController.h"
#import "DGAppDelegate.h"
#import "ISPebbleCommunicator.h"
#import "DGFilterBase.h"
#import "DGFilterRange.h"
#import "DGFilterImageFactory.h"
#import "DGConstants.h"

@interface DGHeadsetViewController () <FastttCameraDelegate>

@property (nonatomic, strong) FastttFilterCamera *fastCameraL;
@property (nonatomic, strong) CAReplicatorLayer *replicatorLayerR;
@property (nonatomic, strong) DGFilterBase *currentFilter;
@property (nonatomic, strong) DGFilterRange *brightnessFilter;
@property (nonatomic, strong) DGFilterRange *contrastFilter;
@property (nonatomic, strong) DGFilterRange *saturationFilter;
@property (nonatomic, strong) iCadeReaderView *control;
@property (nonatomic, strong) UILabel *menuLabelL;
@property (nonatomic, strong) UILabel *menuLabelR;
@property (nonatomic, readwrite) DGMenuItem currentDGMenuItem;

@end

@implementation DGHeadsetViewController {
    BOOL _aspectRatioFixed;
    DGUIDisplayState _uiDisplayState;
    float _zoomValue;
    NSTimer *_timer;
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
    _zoomValue = 1.0;
    
    // Apple Watch support
    if ([WCSession isSupported]) {
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
        
        if (session.paired == NO) {
            NSLog(@"No device paired");
        }
        
        if (session.watchAppInstalled == NO) {
            NSLog(@"Watch app is not installed");
        }
    } else {
        NSLog(@"WatchConnectivity is not supported on this device");
    }
    
    // Pebble Watch support
    [[ISPebbleCommunicator sharedPebbleCommunicator] setCommunicatorDelegate:self];
    
    // iCade support
    _control = [[iCadeReaderView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_control];
    _control.active = YES;
    _control.delegate = self;
    
    // iCade menu support
    _currentDGMenuItem = DGMenuItemZoom;
    CGRect lFrame = CGRectMake((self.view.frame.size.width/2-20)-50, 5, 100, 30);
    _menuLabelL = [[UILabel alloc] initWithFrame:lFrame];
    _menuLabelL.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    _menuLabelL.textColor = [UIColor whiteColor];
    _menuLabelL.textAlignment = NSTextAlignmentCenter;
    _menuLabelL.layer.masksToBounds = YES;
    _menuLabelL.layer.cornerRadius = 8;
    [self.view addSubview:_menuLabelL];
    
    CGRect rFrame = CGRectMake((self.view.frame.size.width-40+_menuLabelL.frame.origin.x), 5, 100, 30);
    _menuLabelR = [[UILabel alloc] initWithFrame:rFrame];
    _menuLabelR.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
    _menuLabelR.textColor = [UIColor whiteColor];
    _menuLabelR.textAlignment = NSTextAlignmentCenter;
    _menuLabelR.layer.masksToBounds = YES;
    _menuLabelR.layer.cornerRadius = 8;
    [self.view addSubview:_menuLabelR];
    
    [self hideMenuLabels];
    
    // Create the filters
    _currentFilter = [DGFilterBase filterWithType:ISFilterTypeNone];
    _brightnessFilter = [DGFilterImageFactory filterRangeForFilterType:ISFilterTypeBrightness];
    _contrastFilter = [DGFilterImageFactory filterRangeForFilterType:ISFilterTypeContrast];
    _saturationFilter = [DGFilterImageFactory filterRangeForFilterType:ISFilterTypeSaturation];
    [self resetAllFilters];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Show/hide appropriate UI components, depending on the orientation of the device
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationMaskPortrait || orientation == UIInterfaceOrientationPortrait) {
        _uiDisplayState = DGUIDisplayStateInstructions;
    } else {
        _uiDisplayState = DGUIDisplayStateCardboard;
        // Add the camera views to the view heirarchy
        [self setupCameraView];
    }
    
    [self updateUICurrentState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self tearDownCameraView];
    
}

- (void)viewDidUnload {
    
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    // Add it to the view heirarchy
//    [self setupCameraView];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    // Remove the camera from teh view heirarchy
    [self tearDownCameraView];
    
    // Return to the previous screen
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Code here will execute before the rotation begins.
    // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Code here will execute after the rotation has finished.
        // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        
        // Show/hide appropriate UI components, depending on the orientation of the device
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationMaskPortrait || orientation == UIInterfaceOrientationPortrait) {
            _uiDisplayState = DGUIDisplayStateInstructions;
            
            // Remove the camera views from the view heirarchy
            [self tearDownCameraView];
        } else {
            // For Landscape, show the cardboard viewer
            _uiDisplayState = DGUIDisplayStateCardboard;
            
            // Add the camera views to the view heirarchy
            [self setupCameraView];
        }
        
        [self updateUICurrentState];
    }];
}

#pragma mark - Action Handlers

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Fast Camera Functions

- (void)updateUICurrentState {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Show the instructions UI components
        if (_uiDisplayState == DGUIDisplayStateInstructions) {
            self.fastCameraL.view.hidden = YES;
            self.replicatorLayerR.hidden = YES;
            self.imageView.hidden = NO;
            self.instructionlabel.hidden = NO;
            self.closeButton.hidden = NO;
            [self hideMenuLabels];
        } else if (_uiDisplayState == DGUIDisplayStateCardboard){
            // Show the headset UI components
            self.fastCameraL.view.hidden = NO;
            self.replicatorLayerR.hidden = NO;
            self.imageView.hidden = YES;
            self.instructionlabel.hidden = YES;
            self.closeButton.hidden = YES;
        }
        [self.view setNeedsLayout];
    });
}

- (void)setupCameraView {
    dispatch_async(dispatch_get_main_queue(), ^{
        // If we actually have something to remove
        if (_replicatorLayerR == nil) {
            NSLog(@"Creating new headset camera view");
            _fastCameraL = [FastttFilterCamera cameraWithFilterImage:self.currentFilter.filterImage];
            self.fastCameraL.delegate = self;
            self.fastCameraL.maxScaledDimension = 600.f;
            [self.fastCameraL setCameraDevice:FastttCameraDeviceRear];
            [self.fastCameraL setCameraTorchMode:FastttCameraTorchModeOff];
            [self.fastCameraL setCameraFlashMode:FastttCameraFlashModeOff];
            
            // Add camera to this view
            [self addChildViewController:self.fastCameraL];
            [self.fastCameraL didMoveToParentViewController:self];
            [self.view insertSubview:self.fastCameraL.view atIndex:0];
            
            // Set the frame to cover only the left side of the screen
            self.fastCameraL.view.frame = CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height);
            
            
            // Replicate the layer by transforming it horizontally
            _replicatorLayerR = [CAReplicatorLayer layer];
            _replicatorLayerR.frame = CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height);
            _replicatorLayerR.instanceCount = 2;
            _replicatorLayerR.instanceTransform = CATransform3DMakeTranslation(self.view.bounds.size.width / 2, 0.0, 0.0);
            [_replicatorLayerR addSublayer:self.fastCameraL.previewView.layer];
            [self.fastCameraL.view.layer addSublayer:_replicatorLayerR];
        } else {
            NSLog(@"Skipping new headset camera view because views already exist");
        }
    });
}

- (void)tearDownCameraView {
    dispatch_async(dispatch_get_main_queue(), ^{
        // If we actually have something to remove
        if (_replicatorLayerR != nil) {
            NSLog(@"Tearing down headset camera view");
//            [self.fastCameraL.previewView.layer removeFromSuperlayer];
//            [_replicatorLayerR removeFromSuperlayer];
//            [self.fastCameraL.view removeFromSuperview];
//            [self.fastCameraL viewWillDisappear:NO];
            [self.fastCameraL removeFromParentViewController];
            _replicatorLayerR = nil;
        } else {
            NSLog(@"Skipping headset camera teardown because view doestn exist");
        }
    });
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
        self.fastCameraL.filterImage = self.currentFilter.filterImage;
    } else {
        NSLog(@"Update filter range called on non-range filter");
    }
}

- (void)updateTorchState:(BOOL)torchOn {
    NSLog(@"torch button pressed");
    
    FastttCameraTorchMode torchMode;
    if (torchOn) {
        torchMode = FastttCameraTorchModeOn;
    } else {
        torchMode = FastttCameraTorchModeOff;
    }
    if ([self.fastCameraL isTorchAvailableForCurrentDevice]) {
        [self.fastCameraL setCameraTorchMode:torchMode];
    }
}

- (void)resetAllFilters {
    // reset the filter by setting the generic filter image. This is easier than clearing the target heirarchy and recreating the zoom filter
    _currentFilter = [DGFilterBase filterWithType:ISFilterTypeNone];
    self.fastCameraL.filterImage = _currentFilter.filterImage;
    
    // Reset the zoom scale rather than recreating the filter
    _zoomValue = 1.0;
    [self.fastCameraL setZoomScale:_zoomValue];
}

- (NSString *)menuTextForDGMenuItem:(DGMenuItem)DGMenuItem {
    switch (DGMenuItem) {
        case DGMenuItemZoom:
            return kDGZoomLabel;
            break;
        case DGMenuItemBrightness:
            return kDGBrightnessLabel;
            break;
        case DGMenuItemContrast:
            return kDGContrastLabel;
            break;
        case DGMenuItemSaturation:
            return kDGSaturationLabel;
            break;
        case DGMenuItemTorch:
            return kDGTorchLabel;
            break;
        case DGMenuItemReset:
            return kDGResetLabel;
            break;
//        case DGMenuItemCaptureFlash:
//            return @"Flash";
//            break;
//        case DGMenuItemCaptureImage:
//            return @"Camera";
//            break;
//        case DGMenuItemCaptureVideo:
//            return @"Video";
//            break;
            
        default:
            break;
    }
    return @"";
}

- (void)showMenuLabelsWithMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Clear the old timer
        if (_timer) {
            [_timer invalidate];
            _timer = nil;
        }
        
        // Update the UI
        [_menuLabelL setText:message];
        [_menuLabelR setText:message];
        _menuLabelL.hidden = NO;
        _menuLabelR.hidden = NO;
        
        // Set timer to hide labels after 3 seconds
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideMenuLabels) userInfo:nil repeats:NO];
    });
}

- (void)hideMenuLabels {
    dispatch_async(dispatch_get_main_queue(), ^{
        _menuLabelL.hidden = YES;
        _menuLabelR.hidden = YES;
    });
}

- (void)updateMenuSelection:(BOOL)moveUp {
    DGMenuItem newDGMenuItem = _currentDGMenuItem;
    
    if (moveUp) { // Moving up in the list, so decrease the index
        if (newDGMenuItem == DGMenuItemZoom) {
            newDGMenuItem = DGMenuItemReset;
        } else {
            newDGMenuItem --;
        }
    } else { // Moving down, so increase the index
        if (newDGMenuItem == DGMenuItemReset) {
            newDGMenuItem = DGMenuItemZoom;
        } else {
            newDGMenuItem ++;
        }
    }
    _currentDGMenuItem = newDGMenuItem;
    
    NSString *message = [self menuTextForDGMenuItem:_currentDGMenuItem];
    [self showMenuLabelsWithMessage:message];
}


//- (void)showCardboard {
//    [self tearDownCameraView];
//
//    _uiDisplayState = DGUIDisplayStateCardboard;
//    self.fastCameraL.view.hidden = NO;
//    self.replicatorLayerR.hidden = NO;
//    [self setupCameraView];
//}

-(void)executeInstruction:(NSInteger)instruction withValue:(BOOL)action {
    switch (instruction) {
        case DGMenuItemZoom : {
            if (action == NO && _zoomValue > 1) {
                _zoomValue += -.25;
            } else if (action == YES && _zoomValue < 10) {
                _zoomValue += .25;
            }
            
            // Update zoom filter scale
            [self.fastCameraL setZoomScale:_zoomValue];
            break;
        }
        case DGMenuItemBrightness : {
            self.currentFilter = self.brightnessFilter;
            [self updateCurrentFilterRangeWithIncrease:action];
            break;
        }
        case DGMenuItemContrast : {
            self.currentFilter = self.contrastFilter;
            [self updateCurrentFilterRangeWithIncrease:action];
            break;
        }
        case DGMenuItemSaturation : {
            self.currentFilter = self.saturationFilter;
            [self updateCurrentFilterRangeWithIncrease:action];
            break;
        }
        case DGMenuItemTorch : {
            [self updateTorchState:action];
            break;
        }
        case DGMenuItemReset : {
            [self resetAllFilters];
            break;
        }
//        case DGMenuItemCaptureImage : {
//                        if ([value integerValue] == DGMenuItemCaptureImage) {
//                            // Remove the view if we have received this call a second time due to race condition
//                            if ([self.confirmController.view isDescendantOfView:self.view]) {
//                                [self.confirmController dismissConfirmController:self];
//                            }
//            
//                            // Abort a previous capture attempt if we are trying again due to race condition
//                            if (![self.fastCameraL isReadyToCapturePhoto]) {
//                                [self.fastCameraL cancelImageProcessing];
//                            }
//            
//                            // Capture an image from what is being displayed to the view
//                            [self.fastCameraL takePicture];
//            
//                        } else if ([self.confirmController.view isDescendantOfView:self.view]) {
//                            if ([value integerValue] == 1) {
//                                [self.confirmController confirmButtonPressed:self];
//                            } else if ([value integerValue] == 0) {
//                                [self.confirmController dismissConfirmController:self];
//                            }
//                        } else {
//                            // Abort a previous capture attempt if we are trying again due to race condition
//                            if (![self.fastCameraL isReadyToCapturePhoto]) {
//                                [self.fastCameraL cancelImageProcessing];
//                            }
//                        }
//            break;
//        }
        default:
            break;
    }
}


#pragma mark - IFTTTFastttCameraDelegate

- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishCapturingImage:(FastttCapturedImage *)capturedImage {
//    NSLog(@"A photo was taken");
//
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    _confirmController = [sb instantiateViewControllerWithIdentifier:@"DGCapturePreviewViewController"];
//    self.confirmController.capturedImage = capturedImage;
//    self.confirmController.delegate = self;
//
//    UIView *flashView = [[UIView alloc] initWithFrame:self.view.frame];
//    flashView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.f];
//    flashView.alpha = 0.f;
//    [self.view addSubview:flashView];
//
//    [UIView animateWithDuration:0.15f
//                          delay:0.f
//                        options:UIViewAnimationOptionCurveEaseIn
//                     animations:^{
//                         flashView.alpha = 1.f;
//                     }
//                     completion:^(BOOL finished) {
//
//                         [self.view insertSubview:self.confirmController.view belowSubview:flashView];
//
//                         [UIView animateWithDuration:0.15f
//                                               delay:0.05f
//                                             options:UIViewAnimationOptionCurveEaseOut
//                                          animations:^{
//                                              flashView.alpha = 0.f;
//                                          }
//                                          completion:^(BOOL finished2) {
//                                              [flashView removeFromSuperview];
//                                          }];
//                     }];
}

- (void)cameraController:(id<FastttCameraInterface>)cameraController didFinishNormalizingCapturedImage:(FastttCapturedImage *)capturedImage {
    NSLog(@"Photos are ready");
    
//    self.confirmController.imagesReady = YES;
}

#pragma mark - ConfirmControllerDelegate

//- (void)dismissConfirmController:(DGCapturePreviewViewController *)controller
//{
//    [self fastttRemoveChildViewController:controller];
//}

#pragma mark - PebbleCommunicatorDelegate

-(void)pebbleCommunicatorDidConnectWithError:(NSError *)error {
    if (error == nil) { // Show a connection successful message if there is no error
        [self showMenuLabelsWithMessage:@"Connected"];
    }
}

-(void)pebbleCommunicatorDidReceiveData:(NSDictionary *)dict {
    if(BKM_IS_NOT_MAIN_THREAD()) {
        BKM_REQUEUE_ON_MAIN_THREAD(dict);
    } else {
        // Loop through all keys and execute the sent instructions
        for (NSNumber *key in [dict allKeys]) {
            NSNumber *value  = [dict objectForKey:key];
            [self executeInstruction:[key integerValue] withValue:[value boolValue]];
        }
    }
}

#pragma mark - Apple Watch

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler {
    NSDictionary *contextDict;
    
    for (NSString *key in [message allKeys]) {
        NSNumber *value  = [message objectForKey:key];
        [self executeInstruction:[key integerValue] withValue:[value boolValue]];
    }
    replyHandler(contextDict);
}

- (void)session:(WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message {
    for (NSString *key in [message allKeys]) {
        NSNumber *value  = [message objectForKey:key];
        [self executeInstruction:[key integerValue] withValue:[value boolValue]];
    }
}

#pragma mark - iCade Delegate

- (void)buttonDown:(iCadeState)button {
    switch (button) {
        case iCadeButtonA:
            [self executeInstruction:_currentDGMenuItem withValue:NO];
            break;
        case iCadeButtonB:
            [self updateMenuSelection:NO];
            break;
        case iCadeButtonC:
            [self updateMenuSelection:YES];
            break;
        case iCadeButtonD:
            [self executeInstruction:_currentDGMenuItem withValue:YES];
            break;
            
            //        case iCadeJoystickUp:
            //            if (state) {
            //                center.y -= offset;
            //            } else {
            //                center.y += offset;
            //            }
            //            break;
            //        case iCadeJoystickRight:
            //            if (state) {
            //                center.x += offset;
            //            } else {
            //                center.x -= offset;
            //            }
            //            break;
            //        case iCadeJoystickDown:
            //            if (state) {
            //                center.y += offset;
            //            } else {
            //                center.y -= offset;
            //            }
            //            break;
            //        case iCadeJoystickLeft:
            //            if (state) {
            //                center.x -= offset;
            //            } else {
            //                center.x += offset;
            //            }
            //            break;
            
        default:
            break;
    }
}

@end


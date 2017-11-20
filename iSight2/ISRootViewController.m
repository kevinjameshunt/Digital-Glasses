 //
//  ISRootViewController.m
//  iSight2
//
//  Created by Kevin Hunt on 2015-08-30.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ISRootViewController.h"
#import "DGCapturePreviewViewController.h"
#import "DGAppDelegate.h"
#import "ISPebbleCommunicator.h"
#import "ISFilterBase.h"
#import "ISFilterRange.h"
#import "ISFilterImageFactory.h"
#import "ISConstants.h"

@interface ISRootViewController ()<FastttCameraDelegate, DGCaptureConfirmControllerDelegate>

@property (nonatomic, strong) FastttFilterCamera *fastCameraL;
@property (nonatomic, strong) CAReplicatorLayer *replicatorLayerR;
@property (nonatomic, strong) ISFilterBase *currentFilter;
@property (nonatomic, strong) DGCapturePreviewViewController *confirmController;
@property (nonatomic, strong) ISFilterRange *brightnessFilter;
@property (nonatomic, strong) ISFilterRange *contrastFilter;
@property (nonatomic, strong) ISFilterRange *saturationFilter;
@property (nonatomic, strong) iCadeReaderView *control;
@property (nonatomic, strong) UILabel *menuLabelL;
@property (nonatomic, strong) UILabel *menuLabelR;
@property (nonatomic, readwrite) MenuItem currentMenuItem;

@end

@implementation ISRootViewController {
    DGUIDisplayState _uiDisplayState;
    BOOL _aspectRatioFixed;
}

- (instancetype)init
{
    if ((self = [super init])) {
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    _aspectRatioFixed = NO;
    
    // iCade support
    _control = [[iCadeReaderView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_control];
    _control.active = YES;
    _control.delegate = self;
    
    // iCade menu support
    _currentMenuItem = MenuItemZoom;
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
    
    [self updateMenuLabels:YES];
    
    // Create the camera
    _currentFilter = [ISFilterBase filterWithType:ISFilterTypeNone];
    _fastCameraL = [FastttFilterCamera cameraWithFilterImage:self.currentFilter.filterImage];
    self.fastCameraL.delegate = self;
    self.fastCameraL.maxScaledDimension = 600.f;
    [self.fastCameraL setCameraDevice:FastttCameraDeviceRear];
    
    _brightnessFilter = [ISFilterImageFactory filterRangeForFilterType:ISFilterTypeBrightness];
    _brightnessControl.minimumValue = _brightnessFilter.minFilterValue;
    _brightnessControl.maximumValue = _brightnessFilter.maxFilterValue;
    _brightnessControl.stepValue = _brightnessFilter.filterValueIncrement;
    _brightnessControl.value = 0;
    
    _contrastFilter = [ISFilterImageFactory filterRangeForFilterType:ISFilterTypeContrast];
    _contrastControl.minimumValue = _contrastFilter.minFilterValue;
    _contrastControl.maximumValue = _contrastFilter.maxFilterValue;
    _contrastControl.stepValue = _contrastFilter.filterValueIncrement;
    _contrastControl.value = 0;
    
    _saturationFilter = [ISFilterImageFactory filterRangeForFilterType:ISFilterTypeSaturation];
    _saturationControl.minimumValue = _saturationFilter.minFilterValue;
    _saturationControl.maximumValue = _saturationFilter.maxFilterValue;
    _saturationControl.stepValue = _saturationFilter.filterValueIncrement;
    _saturationControl.value = 0;
    
    // Take photo button
    [self.takePhotoButton setTitle:@"Take Photo"];
    
    // Flash button
    [self.flashButton setTitle:@"Flash Off"];
    [self.fastCameraL setCameraFlashMode:FastttCameraFlashModeOff];
    
    // Torch button
    [self.torchButton setTitle:@"Torch Off"];
    [self.fastCameraL setCameraTorchMode:FastttCameraTorchModeOff];
    
    // Hide the on-screen UI by default
    self.filterTestingView.hidden = YES;
    self.cameraControlsToolbar.hidden = YES;
    
    [[ISPebbleCommunicator sharedPebbleCommunicator] setCommunicatorDelegate:self];
    
    [self resetAllFilters];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.confirmController = nil;
    
    // Add it to the view heirarchy
    [self setupCameraView];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationMaskPortrait || orientation == UIInterfaceOrientationPortrait) {
        self.fastCameraL.view.hidden = YES;
        self.replicatorLayerR.hidden = YES;
        self.optionsTableView.hidden = NO;
        _uiDisplayState = DGUIDisplayStateSettings;
    } else {
        self.fastCameraL.view.hidden = NO;
        self.replicatorLayerR.hidden = NO;
        self.optionsTableView.hidden = YES;
        _uiDisplayState = DGUIDisplayStateMagnifier;
    }
}

- (void)tearDownCameraView {
    [_replicatorLayerR removeFromSuperlayer];
    [self.fastCameraL.view removeFromSuperview];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self tearDownCameraView];
    
}

- (void)viewDidUnload {
    
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    // Add it to the view heirarchy
    [self setupCameraView];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    // Add it to the view heirarchy
    [self setupCameraView];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    
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
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationMaskPortrait || orientation == UIInterfaceOrientationPortrait) {
            if (_uiDisplayState == DGUIDisplayStateCardboard) {
                [self showSettings];
            }
        } else {
            [self showCardboard];
            
            DGAppDelegate *AppDel = (DGAppDelegate *)[[UIApplication sharedApplication] delegate];
            self.filterTestingView.hidden = !AppDel.showOnScreenControls;
            self.cameraControlsToolbar.hidden = !AppDel.showOnScreenControls;
        }
    }];
}

- (void)setupCameraView {
    // Add camera to this view
    [self addChildViewController:self.fastCameraL];
    [self.fastCameraL didMoveToParentViewController:self];
    [self.view insertSubview:self.fastCameraL.view atIndex:0];
    
    // Set the frame to cover only the left side of the screen
    self.fastCameraL.view.frame = CGRectMake(self.view.frame.origin.x,
                                             self.view.frame.origin.y,
                                             self.view.frame.size.width/2,
                                             self.view.frame.size.height);
    
    // Get the previewView subview from the FastCamera viewcontroller
    //    GPUImageView *previewView;
    //    for (UIView *view in self.fastCameraL.view.subviews) {
    //        if ([view isKindOfClass:[GPUImageView class]]) {
    //            previewView = (GPUImageView *)view;
    //        }
    //    }
    
    // Replicate the layer by transforming it horizontally
    _replicatorLayerR = [CAReplicatorLayer layer];
    _replicatorLayerR.frame = CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height);
    _replicatorLayerR.instanceCount = 2;
    _replicatorLayerR.instanceTransform = CATransform3DMakeTranslation(self.view.bounds.size.width / 2, 0.0, 0.0);
    [_replicatorLayerR addSublayer:self.fastCameraL.previewView.layer];
    [self.fastCameraL.view.layer addSublayer:_replicatorLayerR];
    
}

- (void)setupMagnifierView {
    // Add camera to this view
    [self addChildViewController:self.fastCameraL];
    [self.fastCameraL didMoveToParentViewController:self];
    [self.view insertSubview:self.fastCameraL.view atIndex:0];
    
    // Set the frame to cover only the left side of the screen
    self.fastCameraL.view.frame = CGRectMake(self.view.frame.origin.x,
                                             self.view.frame.origin.y,
                                             self.view.frame.size.width,
                                             self.view.frame.size.height);
}

- (void)updateCurrentFilterRangeWithIncrease:(BOOL)increase {
    // Ensure this is only called on the appropriate filters
    if ([self.currentFilter isKindOfClass:[ISFilterRange class]]) {
        ISFilterRange *tempFilter = (ISFilterRange *)self.currentFilter;
        
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
    NSString *torchTitle;
    if (torchOn) {
        torchMode = FastttCameraTorchModeOn;
        torchTitle = @"Torch On";
    } else {
        torchMode = FastttCameraTorchModeOff;
        torchTitle = @"Torch Off";
    }
    if ([self.fastCameraL isTorchAvailableForCurrentDevice]) {
        [self.fastCameraL setCameraTorchMode:torchMode];
        [self.torchButton setTitle:torchTitle];
    }
}

- (void)resetAllFilters {
    // reset the filter by setting the generic filter image. This is easier than clearing the target heirarchy and recreating the zoom filter
    _currentFilter = [ISFilterBase filterWithType:ISFilterTypeNone];
    self.fastCameraL.filterImage = _currentFilter.filterImage;
    
    // Reset the zoom scale rather than recreating the filter
    self.zoomSlider.value = 1.0;
    [self.fastCameraL setZoomScale:1.0];
}

- (NSString *)menuTextForMenuItem:(MenuItem)menuItem {
    switch (menuItem) {
        case MenuItemZoom:
            return @"Zoom";
            break;
        case MenuItemBrightness:
            return @"Brightness";
            break;
        case MenuItemContrast:
            return @"Contrast";
            break;
        case MenuItemSaturation:
            return @"Saturation";
            break;
        case MenuItemTorch:
            return @"Torch";
            break;
        case MenuItemReset:
            return @"Reset";
            break;
        case MenuItemCaptureImage:
            return @"Camera";
            break;
            
        default:
            break;
    }
    return @"";
}

- (void)updateMenuLabels:(BOOL)hidden {
    [_menuLabelL setText:[self menuTextForMenuItem:_currentMenuItem]];
    [_menuLabelR setText:[self menuTextForMenuItem:_currentMenuItem]];
    
    if (hidden) {
        _menuLabelL.hidden = YES;
        _menuLabelR.hidden = YES;
    } else {
        _menuLabelL.hidden = NO;
        _menuLabelR.hidden = NO;
        
        // TODO: Set timer to hid labels after 3 seconds
    }
}

- (void)updateMenuSelection:(BOOL)moveUp {
    MenuItem newMenuItem = _currentMenuItem;
    
    if (moveUp) { // Moving up in the list, so decrease the index
        if (newMenuItem == MenuItemZoom) {
            newMenuItem = MenuItemReset;
        } else {
            newMenuItem --;
        }
    } else { // Moving down, so increase the index
        if (newMenuItem == MenuItemReset) {
            newMenuItem = MenuItemZoom;
        } else {
            newMenuItem ++;
        }
    }
    _currentMenuItem = newMenuItem;
    
    [self updateMenuLabels:NO];
}

- (void)showSettings {
    _uiDisplayState = DGUIDisplayStateSettings;
    self.fastCameraL.view.hidden = YES;
    self.replicatorLayerR.hidden = YES;
    self.optionsTableView.hidden  = NO;
    [self tearDownCameraView];
}

- (void)showMagnifier {
    [self tearDownCameraView];
    
    _uiDisplayState = DGUIDisplayStateMagnifier;
    self.fastCameraL.view.hidden = NO;
    self.replicatorLayerR.hidden = YES;
    self.optionsTableView.hidden = YES;
    [self setupMagnifierView];
}

- (void)showCardboard {
    [self tearDownCameraView];
    
    _uiDisplayState = DGUIDisplayStateCardboard;
    self.fastCameraL.view.hidden = NO;
    self.replicatorLayerR.hidden = NO;
    self.optionsTableView.hidden = YES;
    [self setupCameraView];
}

-(void)executeInstruction:(NSInteger)instruction withValue:(BOOL)action {
    switch (instruction) {
        case MenuItemZoom : {
            if (action == NO && self.zoomSlider.value > 1) {
                self.zoomSlider.value += -.25;
            } else if (action == YES && self.zoomSlider.value < 10) {
                self.zoomSlider.value += .25;
            }
            
            // Update zoom filter scale
            [self.fastCameraL setZoomScale:self.zoomSlider.value];
            break;
        }
        case MenuItemBrightness : {
            self.currentFilter = self.brightnessFilter;
            [self updateCurrentFilterRangeWithIncrease:action];
            break;
        }
        case MenuItemContrast : {
            self.currentFilter = self.contrastFilter;
            [self updateCurrentFilterRangeWithIncrease:action];
            break;
        }
        case MenuItemSaturation : {
            self.currentFilter = self.saturationFilter;
            [self updateCurrentFilterRangeWithIncrease:action];
            break;
        }
        case MenuItemTorch : {
            [self updateTorchState:action];
            break;
        }
        case MenuItemReset : {
            [self resetAllFilters];
            break;
        }
        case MenuItemCaptureImage : {
//            if ([value integerValue] == MenuItemCaptureImage) {
//                // Remove the view if we have received this call a second time due to race condition
//                if ([self.confirmController.view isDescendantOfView:self.view]) {
//                    [self.confirmController dismissConfirmController:self];
//                }
//                
//                // Abort a previous capture attempt if we are trying again due to race condition
//                if (![self.fastCameraL isReadyToCapturePhoto]) {
//                    [self.fastCameraL cancelImageProcessing];
//                }
//                
//                // Capture an image from what is being displayed to the view
//                [self.fastCameraL takePicture];
//                
//            } else if ([self.confirmController.view isDescendantOfView:self.view]) {
//                if ([value integerValue] == 1) {
//                    [self.confirmController confirmButtonPressed:self];
//                } else if ([value integerValue] == 0) {
//                    [self.confirmController dismissConfirmController:self];
//                }
//            } else {
//                // Abort a previous capture attempt if we are trying again due to race condition
//                if (![self.fastCameraL isReadyToCapturePhoto]) {
//                    [self.fastCameraL cancelImageProcessing];
//                }
//            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Action Handlerss

- (IBAction)takePhotoButtonPressed:(id)sender
{
    NSLog(@"Take photo button pressed");
    
    [self.fastCameraL takePicture];
}

- (IBAction)captureVideoButtonPressed:(id)sender
{
    NSLog(@"Capture video button pressed");
    
    [self.fastCameraL captureVideo];
}

- (IBAction)flashButtonPressed:(id)sender
{
    NSLog(@"flash button pressed");
    
    FastttCameraFlashMode flashMode;
    NSString *flashTitle;
    switch (self.fastCameraL.cameraFlashMode) {
        case FastttCameraFlashModeOn:
            flashMode = FastttCameraFlashModeOff;
            flashTitle = @"Flash Off";
            break;
        case FastttCameraFlashModeOff:
        default:
            flashMode = FastttCameraFlashModeOn;
            flashTitle = @"Flash On";
            break;
    }
    if ([self.fastCameraL isFlashAvailableForCurrentDevice]) {
        [self.fastCameraL setCameraFlashMode:flashMode];
        [self.flashButton setTitle:flashTitle];
    }
}

- (IBAction)torchButtonPressed:(id)sender
{
    switch(self.fastCameraL.cameraTorchMode) {
        case FastttCameraTorchModeOn:
            [self updateTorchState:NO];
            break;
        case FastttCameraTorchModeOff:
            [self updateTorchState:YES];
        default:
            break;
    }
}

- (IBAction)brightnessValueChanged:(id)sender {
    if ([sender isKindOfClass:[UIStepper class]]) {
        UIStepper *control = (UIStepper *)sender;
        // Since the stepper has been setup to match the filter, the value can just be updated.
        self.brightnessFilter.filterValue = control.value;
    }
    self.currentFilter = self.brightnessFilter;
    self.fastCameraL.filterImage = self.currentFilter.filterImage;
}

- (IBAction)contrastValueChanged:(id)sender {
    if ([sender isKindOfClass:[UIStepper class]]) {
        UIStepper *control = (UIStepper *)sender;
        // Since the stepper has been setup to match the filter, the value can just be updated.
        self.contrastFilter.filterValue = control.value;
    }
    self.currentFilter = self.contrastFilter;
    self.fastCameraL.filterImage = self.currentFilter.filterImage;
}

- (IBAction)saturationValueChanged:(id)sender {
    if ([sender isKindOfClass:[UIStepper class]]) {
        UIStepper *control = (UIStepper *)sender;
        // Since the stepper has been setup to match the filter, the value can just be updated.
        self.saturationFilter.filterValue = control.value;
    }
    self.currentFilter = self.saturationFilter;
    self.fastCameraL.filterImage = self.currentFilter.filterImage;
}

- (IBAction)resetButtonPressed:(id)sender {
    [self resetAllFilters];
}

- (IBAction)settingsButtonPressed:(id)sender {
    [self showSettings];
}

- (IBAction)sliderVaueChanged:(id)sender {
    NSLog(@"Zoom changed: %f",self.zoomSlider.value);
    [self.fastCameraL setZoomScale:self.zoomSlider.value];
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

#pragma mark - PebbleCommunicatorDelegate

-(void)pebbleCommunicatorDidReceiveData:(NSDictionary *)dict {
    if(BKM_IS_NOT_MAIN_THREAD()) {
        BKM_REQUEUE_ON_MAIN_THREAD(dict);
    } else {
        
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
            [self executeInstruction:_currentMenuItem withValue:NO];
            break;
        case iCadeButtonB:
            [self updateMenuSelection:NO];
            break;
        case iCadeButtonC:
            [self updateMenuSelection:YES];
            break;
        case iCadeButtonD:
            [self executeInstruction:_currentMenuItem withValue:YES];
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


#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell =[tableView dequeueReusableCellWithIdentifier:@"testingUIOption"];
    } else {
        cell =[tableView dequeueReusableCellWithIdentifier:@"showMagnifierOption"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        [self showMagnifier];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end

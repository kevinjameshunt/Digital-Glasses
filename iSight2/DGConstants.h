//
//  DGConstants.h
//  DigitalGlasses
//
//  Created by Kevin Hunt on 2017-04-30.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#define BKM_IS_NOT_MAIN_THREAD() \
([NSThread currentThread] != [NSThread mainThread])

#define BKM_REQUEUE_ON_MAIN_THREAD(__ONE_ARG) \
[self performSelectorOnMainThread : _cmd withObject : __ONE_ARG waitUntilDone : NO]

#define IS_IOS11orHIGHER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0)

#define     kPSWebsiteLink                          @"https://twitter.com/ProphetStudios/"
#define     kPSFacebookLink                         @"https://facebook.com/Official.Prophet.Studios/"
#define     kPSTwitterLink                          @"https://twitter.com/ProphetStudios/"

#define     kISControlDisplaySegue                  @"controlSegue"
#define     kISControlRowIdentifierControl          @"controlRow"
#define     kISControlRowIdentifierSessionFailed    @"sessionFailedRow"

#define     kCellSingleRowHeight                    50
#define     kMagnifierControlsHeight                154
#define     kSettingsFooterHeight                   380
#define     kVideoPlayerHeight                      260

#define     kDGZoomLabel                            @"Zoom"
#define     kDGBrightnessLabel                      @"Brightness"
#define     kDGContrastLabel                        @"Contrast"
#define     kDGSaturationLabel                      @"Saturation"
#define     kDGTorchLabel                           @"Light"
#define     kDGResetLabel                           @"Reset"
#define     kDGFlashLabel                           @"Flash"
#define     kDGConnectedLabel                       @"Connected"

#define     kDGVideoInstructionsLabel               @"Instruction Videos"
#define     kDGHeadsetsLabel                        @"Buy A Headset"

#define     kDGVideoListFileName                    @"videoList.json"
#define     kDGVideoListKey                         @"videoList"
#define     kDGVideoNameKey                         @"videoName"
#define     kDGVideoFileKey                         @"videoFile"
#define     kDGVAdListFileName                      @"adList.json"
#define     kDGAdArrayKey                           @"adList"
#define     kDGAdProductNameKey                     @"productName"
#define     kDGAdProductURLKey                      @"productURL"

#define     kDGAVPlayerRateKey                      @"rate"

typedef NS_ENUM(NSInteger, DGMenuItem) {
    DGMenuItemZoom = 0,
    DGMenuItemBrightness,
    DGMenuItemContrast,
    DGMenuItemSaturation,
    DGMenuItemTorch,
    DGMenuItemReset,
//    DGMenuItemFlash,
//    DGMenuItemCaptureImage,
//    DGMenuItemCaptureVideo,
    DGMenuItemCount
};

typedef NS_ENUM(NSInteger, DGUIDisplayState) {
    DGUIDisplayStateInstructions,
    DGUIDisplayStateMagnifier,
    DGUIDisplayStateCardboard
};

typedef NS_ENUM(NSInteger, DGFilterPickerType) {
    DGFilterPickerTypeBrightness = 0,
    DGFilterPickerTypeContrast,
    DGFilterPickerTypeSaturation,
    DGFilterPickerTypeCount
};
OBJC_EXPORT NSString * _Nullable NSStringFromDGFilterPickerType(DGFilterPickerType filterType);
OBJC_EXPORT DGFilterPickerType DGFilterPickerTypeFromString(NSString * _Nullable filterTypeString);

typedef NS_ENUM(NSInteger, DGSettingsItem) {
    DGSettingsItemTerms,
    DGSettingsItemCount
};


@interface DGConstants : NSObject
@end

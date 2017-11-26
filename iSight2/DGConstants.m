//
//  DGConstants.m
//  iSight2
//
//  Created by Kevin Hunt on 2017-11-19.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGConstants.h"

@implementation DGConstants
@end

DGFilterPickerType DGFilterPickerTypeFromString(NSString * _Nullable filterTypeString) {
    DGFilterPickerType filterType = -1;
    if ([filterTypeString isEqualToString:kDGBrightnessLabel]) {
        filterType = DGFilterPickerTypeBrightness;
    } else if ([filterTypeString isEqualToString:kDGContrastLabel]) {
        filterType = DGFilterPickerTypeContrast;
    } else if ([filterTypeString isEqualToString:kDGSaturationLabel]) {
        filterType = DGFilterPickerTypeSaturation;
    }
    
    return filterType;
}

NSString * _Nullable NSStringFromDGFilterPickerType(DGFilterPickerType filterType) {
    switch (filterType) {
        case DGFilterPickerTypeBrightness:
            return kDGBrightnessLabel;
            break;
        case DGFilterPickerTypeContrast:
            return kDGContrastLabel;
            break;
        case DGFilterPickerTypeSaturation:
            return kDGSaturationLabel;
            break;
        default:
            return nil;
            break;
    }
}


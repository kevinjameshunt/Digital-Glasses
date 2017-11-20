//
//  ISFilterImageFactory.m
//  iSight2
//
//  Created by Kevin Hunt on 2015-09-10.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.
//

#import "ISFilterImageFactory.h"

@implementation ISFilterImageFactory

+ (UIImage *)imageForFilterType:(ISFilterType)filterType
{
    NSString *lookupImageName;
    
    switch (filterType) {
        case ISFilterTypeNone:
            lookupImageName = @"LookupNone";
            break;
        case ISFilterTypeBrightness:
            lookupImageName = @"brightness";
            break;
        case ISFilterTypeContrast:
            lookupImageName = @"contrast";
            break;
        case ISFilterTypeSaturation:
            lookupImageName = @"saturation";
            break;
        default:
            break;
    }
    
    UIImage *filterImage;
    
    if ([lookupImageName length] > 0) {
        filterImage = [UIImage imageNamed:lookupImageName];
    }
    
    return filterImage;
}

+ (UIImage *)imageForFilterType:(ISFilterType)filterType andValue:(NSInteger)value
{
    NSString *lookupImageName;
    
    if (value == 0) {
        return [UIImage imageNamed:@"LookupNone"];
    }
    
    switch (filterType) {
        case ISFilterTypeBrightness:
            lookupImageName = @"brightness";
            break;
        case ISFilterTypeContrast:
            lookupImageName = @"contrast";
            break;
        case ISFilterTypeSaturation:
            lookupImageName = @"saturation";
            break;
        default:
            break;
    }
    lookupImageName = [NSString stringWithFormat:@"lookup_%@_%ld",lookupImageName,(long)value];
    
    UIImage *filterImage;
    
    if ([lookupImageName length] > 0) {
        filterImage = [UIImage imageNamed:lookupImageName];
    }
    
    return filterImage;
}

+ (NSString *)nameForFilterType:(ISFilterType)filterType
{
    NSString *lookupImageName;
    
    switch (filterType) {
        case ISFilterTypeNone:
            lookupImageName = @"None";
            break;
        case ISFilterTypeBrightness:
            lookupImageName = @"Brightness";
            break;
        case ISFilterTypeContrast:
            lookupImageName = @"Contrast";
            break;
        case ISFilterTypeSaturation:
            lookupImageName = @"Saturation";
            break;
        default:
            break;
    }
    return lookupImageName;
}

+ (ISFilterRange *)filterRangeForFilterType:(ISFilterType)filterType {
    ISFilterRange * newFilter = [ISFilterRange filterWithType:filterType andValue:0];
    
    // Set the filter range and interval based on what lookup images are available
    switch (filterType) {
        case ISFilterTypeBrightness:
            newFilter.maxFilterValue = 150;
            newFilter.minFilterValue = -150;
            newFilter.filterValueIncrement = 30;
            break;
        case ISFilterTypeContrast:
            newFilter.maxFilterValue = 100;
            newFilter.minFilterValue = -60;
            newFilter.filterValueIncrement = 20;
            break;
        case ISFilterTypeSaturation:
            newFilter.maxFilterValue = 100;
            newFilter.minFilterValue = -100;
            newFilter.filterValueIncrement = 20;
            break;
        default:
            return nil;
            break;
    }
    NSLog(@"Creating %@ Filter with min: %ld, max: %ld, interval: %ld", newFilter.filterName, (long)newFilter.minFilterValue, (long)newFilter.maxFilterValue, newFilter.filterValueIncrement);
    
    return newFilter;
}

@end

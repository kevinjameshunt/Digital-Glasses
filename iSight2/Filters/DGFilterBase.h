//
//  DGFilterBase.h
//  DigitalGlasses
//
//  Created by user on 2015-09-05.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.

@import UIKit;

typedef NS_ENUM(NSInteger, ISFilterType) {
    ISFilterTypeNone,
    ISFilterTypeBrightness,
    ISFilterTypeContrast,
    ISFilterTypeSaturation
};

@interface DGFilterBase : NSObject

@property (nonatomic, assign) ISFilterType filterType;
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic, strong) UIImage *filterImage;

+ (instancetype)filterWithType:(ISFilterType)filterType;

@end

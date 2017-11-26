//
//  DGFilterBase.m
//  DigitalGlasses
//
//  Created by user on 2015-09-05.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.

#import "DGFilterBase.h"
#import "DGFilterImageFactory.h"

@implementation DGFilterBase

+ (instancetype)filterWithType:(ISFilterType)filterType
{
    DGFilterBase *imageFilter = [[self alloc] init];
    
    imageFilter.filterType = filterType;
    imageFilter.filterImage = [DGFilterImageFactory imageForFilterType:filterType];
    imageFilter.filterName = [DGFilterImageFactory nameForFilterType:filterType];
    
    return imageFilter;
}

@end

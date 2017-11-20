//
//  ISFilterBase.m
//  iSight2
//
//  Created by user on 2015-09-05.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.

#import "ISFilterBase.h"
#import "ISFilterImageFactory.h"

@implementation ISFilterBase

+ (instancetype)filterWithType:(ISFilterType)filterType
{
    ISFilterBase *imageFilter = [[self alloc] init];
    
    imageFilter.filterType = filterType;
    imageFilter.filterImage = [ISFilterImageFactory imageForFilterType:filterType];
    imageFilter.filterName = [ISFilterImageFactory nameForFilterType:filterType];
    
    return imageFilter;
}

@end

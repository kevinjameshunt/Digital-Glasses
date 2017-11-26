//
//  DGFilterRange.m
//  DigitalGlasses
//
//  Created by user on 2015-09-05.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.
//

#import "DGFilterRange.h"
#import "DGFilterImageFactory.h"

@implementation DGFilterRange

+ (instancetype)filterWithType:(ISFilterType)filterType andValue:(NSInteger)value
{
    DGFilterRange *imageFilter = [[self alloc] init];
    
    imageFilter.filterType = filterType;
    imageFilter.filterName = [DGFilterImageFactory nameForFilterType:filterType];
    imageFilter.filterImage = [DGFilterImageFactory imageForFilterType:filterType andValue:value];
    imageFilter.filterValue = value;
    
    return imageFilter;
}

- (void)setFilterValue:(NSInteger)newValue {
    _filterValue = newValue;
    self.filterImage = [DGFilterImageFactory imageForFilterType:self.filterType andValue:newValue];
}

- (void)increaseFilterValue {
    if (_filterValue < _maxFilterValue) {
        self.filterValue += _filterValueIncrement;
    }
}

- (void)decreaseFilterValue {
    if (_filterValue > _minFilterValue) {
        self.filterValue -= _filterValueIncrement;
    }
}

@end

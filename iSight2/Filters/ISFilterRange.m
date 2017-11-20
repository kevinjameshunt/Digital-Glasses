//
//  ISFilterRange.m
//  iSight2
//
//  Created by user on 2015-09-05.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.
//

#import "ISFilterRange.h"
#import "ISFilterImageFactory.h"

@implementation ISFilterRange

+ (instancetype)filterWithType:(ISFilterType)filterType andValue:(NSInteger)value
{
    ISFilterRange *imageFilter = [[self alloc] init];
    
    imageFilter.filterType = filterType;
    imageFilter.filterName = [ISFilterImageFactory nameForFilterType:filterType];
    imageFilter.filterImage = [ISFilterImageFactory imageForFilterType:filterType andValue:value];
    imageFilter.filterValue = value;
    
    return imageFilter;
}

- (void)setFilterValue:(NSInteger)newValue {
    _filterValue = newValue;
    self.filterImage = [ISFilterImageFactory imageForFilterType:self.filterType andValue:newValue];
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

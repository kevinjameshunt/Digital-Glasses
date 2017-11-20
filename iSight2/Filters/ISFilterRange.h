//
//  ISFilterRange.h
//  iSight2
//
//  Created by user on 2015-09-05.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.

#import <Foundation/Foundation.h>
#import "ISFilterBase.h"

@interface ISFilterRange : ISFilterBase

@property (nonatomic, readwrite) NSInteger filterValue;
@property (nonatomic, readwrite) NSInteger minFilterValue;
@property (nonatomic, readwrite) NSInteger maxFilterValue;
@property (nonatomic, readwrite) NSInteger filterValueIncrement;

+ (instancetype)filterWithType:(ISFilterType)filterType andValue:(NSInteger)value;

- (void)increaseFilterValue;
- (void)decreaseFilterValue;

@end

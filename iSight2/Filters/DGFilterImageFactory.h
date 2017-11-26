//
//  DGFilterImageFactory.h
//  DigitalGlasses
//
//  Created by Kevin Hunt on 2015-09-10.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DGFilterBase.h"
#import "DGFilterRange.h"

@interface DGFilterImageFactory : NSObject

+ (UIImage *)imageForFilterType:(ISFilterType)filterType;

+ (UIImage *)imageForFilterType:(ISFilterType)filterType andValue:(NSInteger)value;

+ (NSString *)nameForFilterType:(ISFilterType)filterType;

+ (DGFilterRange *)filterRangeForFilterType:(ISFilterType)filterType;

@end

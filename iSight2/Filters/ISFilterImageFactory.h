//
//  ISFilterImageFactory.h
//  iSight2
//
//  Created by Kevin Hunt on 2015-09-10.
//  Copyright (c) 2015 ProphetStudios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISFilterBase.h"
#import "ISFilterRange.h"

@interface ISFilterImageFactory : NSObject

+ (UIImage *)imageForFilterType:(ISFilterType)filterType;

+ (UIImage *)imageForFilterType:(ISFilterType)filterType andValue:(NSInteger)value;

+ (NSString *)nameForFilterType:(ISFilterType)filterType;

+ (ISFilterRange *)filterRangeForFilterType:(ISFilterType)filterType;

@end

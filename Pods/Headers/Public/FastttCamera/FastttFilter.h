//
//  FastttFilter.h
//  FastttCamera
//
//  Created by Laura Skelton on 3/2/15.
//
//

#import <UIKit/UIKit.h>
#import <GPUImage/GPUImageOutput.h>
#import <GPUImage/GPUImageFilterGroup.h>

/**
 *  Private class that contains either a lookup filter or an empty filter,
 *  used internally to filter the live camera preview in FastttFilterCamera.
 */
@interface FastttFilter : NSObject

@property (readonly, nonatomic, strong) GPUImageFilterGroup *filter;

+ (instancetype)filterWithLookupImage:(UIImage *)lookupImage;

+ (instancetype)plainFilter;

//+ (instancetype)zoomFilterWithCropRegion:(CGRect)newCropRegion;

@end

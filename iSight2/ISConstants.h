//
//  ISConstants.h
//  iSight2
//
//  Created by Kevin Hunt on 2017-04-30.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#ifndef ISConstants_h
#define ISConstants_h

typedef enum {
    MenuItemZoom = 0,
    MenuItemBrightness,
    MenuItemContrast,
    MenuItemSaturation,
    MenuItemTorch,
    MenuItemReset,
    MenuItemCaptureImage,
    MenuItemCount
} MenuItem;

#define     kISControlDisplaySegue                  @"controlSegue"
#define     kISControlRowIdentifierControl          @"controlRow"
#define     kISControlRowIdentifierSessionFailed    @"sessionFailedRow"



#endif /* ISConstants_h */

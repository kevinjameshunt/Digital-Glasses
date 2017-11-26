//
//  ISSingleControlInterfaceController.m
//  DigitalGlasses
//
//  Created by Kevin Hunt on 2017-04-30.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import "ISSingleControlInterfaceController.h"
#import "DGConstants.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface ISSingleControlInterfaceController () {
    DGMenuItem _currentDGMenuItem;
}

@end

@implementation ISSingleControlInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    _currentDGMenuItem = [context integerValue];
    switch (_currentDGMenuItem) {
        case DGMenuItemZoom:
            [self.controlLabel setText:kDGZoomLabel];
            break;
        case DGMenuItemBrightness:
            [self.controlLabel setText:kDGBrightnessLabel];
            break;
        case DGMenuItemContrast:
            [self.controlLabel setText:kDGContrastLabel];
            break;
        case DGMenuItemSaturation:
            [self.controlLabel setText:kDGSaturationLabel];
            break;
        case DGMenuItemTorch:
            [self.controlLabel setText:kDGTorchLabel];
            [self.increaseButton setTitle:@"ON"];
            [self.decreaseButton setTitle:@"OFF"];
            break;
        case DGMenuItemReset:
            [self.controlLabel setText:kDGResetLabel];
            [self.increaseButton setTitle:@"YES"];
            [self.decreaseButton setTitle:@"CANCEL"];
            break;
//        case DGMenuItemCaptureImage:
//            [self.controlLabel setText:@"Camera"];
//            [self.increaseButton setTitle:@"CAPTURE"];
//            [self.decreaseButton setTitle:@"CANCEL"];
//            break;
            
        default:
            break;
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)increaseButtonPressed {
    NSString *instructionKey;
    
    switch (_currentDGMenuItem) {
        case DGMenuItemZoom:
            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemZoom];
            break;
        case DGMenuItemBrightness:
            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemBrightness];
            break;
        case DGMenuItemContrast:
            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemContrast];
            break;
        case DGMenuItemSaturation:
            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemSaturation];
            break;
        case DGMenuItemTorch:
            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemTorch];
            break;
        case DGMenuItemReset:
            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemReset];
            break;
//        case DGMenuItemCaptureImage:
//            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemCaptureImage];
//            break;
            
        default:
            break;
    }
    NSDictionary *applicationDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], instructionKey,
                                     nil];
    [[WCSession defaultSession] sendMessage:applicationDict
                               replyHandler:nil
                               errorHandler:nil
     ];
}

- (IBAction)decreaseButtonPressed {
    NSString *instructionKey;
    
    switch (_currentDGMenuItem) {
        case DGMenuItemZoom:
            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemZoom];
            break;
        case DGMenuItemBrightness:
            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemBrightness];
            break;
        case DGMenuItemContrast:
            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemContrast];
            break;
        case DGMenuItemSaturation:
            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemSaturation];
            break;
        case DGMenuItemTorch:
            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemTorch];
            break;
        case DGMenuItemReset:
            [self popController];
            return;
            break;
//        case DGMenuItemCaptureImage:
//            instructionKey = [NSString stringWithFormat:@"%d",DGMenuItemCaptureImage];
//            break;
            
        default:
            break;
    }
    NSDictionary *applicationDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], instructionKey,
                                     nil];
    [[WCSession defaultSession] sendMessage:applicationDict
                               replyHandler:nil
                               errorHandler:nil
     ];
}

@end


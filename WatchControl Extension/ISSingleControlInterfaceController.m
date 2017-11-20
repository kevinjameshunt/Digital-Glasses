//
//  ISSingleControlInterfaceController.m
//  iSight2
//
//  Created by Kevin Hunt on 2017-04-30.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import "ISSingleControlInterfaceController.h"
#import "ISConstants.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface ISSingleControlInterfaceController () {
    MenuItem _currentMenuItem;
}

@end

@implementation ISSingleControlInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
    _currentMenuItem = [context integerValue];
    switch (_currentMenuItem) {
        case MenuItemZoom:
            [self.controlLabel setText:@"Zoom"];
            break;
        case MenuItemBrightness:
            [self.controlLabel setText:@"Brightness"];
            break;
        case MenuItemContrast:
            [self.controlLabel setText:@"Contrast"];
            break;
        case MenuItemSaturation:
            [self.controlLabel setText:@"Saturation"];
            break;
        case MenuItemTorch:
            [self.controlLabel setText:@"Torch"];
            [self.increaseButton setTitle:@"ON"];
            [self.decreaseButton setTitle:@"OFF"];
            break;
        case MenuItemReset:
            [self.controlLabel setText:@"Reset"];
            [self.increaseButton setTitle:@"YES"];
            [self.decreaseButton setTitle:@"CANCEL"];
            break;
        case MenuItemCaptureImage:
            [self.controlLabel setText:@"Camera"];
            [self.increaseButton setTitle:@"CAPTURE"];
            [self.decreaseButton setTitle:@"CANCEL"];
            break;
            
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
    
    switch (_currentMenuItem) {
        case MenuItemZoom:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemZoom];
            break;
        case MenuItemBrightness:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemBrightness];
            break;
        case MenuItemContrast:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemContrast];
            break;
        case MenuItemSaturation:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemSaturation];
            break;
        case MenuItemTorch:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemTorch];
            break;
        case MenuItemReset:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemReset];
            break;
        case MenuItemCaptureImage:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemCaptureImage];
            break;
            
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
    
    switch (_currentMenuItem) {
        case MenuItemZoom:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemZoom];
            break;
        case MenuItemBrightness:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemBrightness];
            break;
        case MenuItemContrast:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemContrast];
            break;
        case MenuItemSaturation:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemSaturation];
            break;
        case MenuItemTorch:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemTorch];
            break;
        case MenuItemReset:
            [self popController];
            return;
            break;
        case MenuItemCaptureImage:
            instructionKey = [NSString stringWithFormat:@"%d",MenuItemCaptureImage];
            break;
            
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


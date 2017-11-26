//
//  InterfaceController.m
//  WatchControl Extension
//
//  Created by Kevin Hunt on 2017-04-30.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import "InterfaceController.h"
#import "DGConstants.h"
#import "ISControlsTableViewRowController.h"

@interface InterfaceController ()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    
    if ([WCSession isSupported]) {
        _watchSession = [WCSession defaultSession];
        _watchSession.delegate = self;
        [_watchSession activateSession];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    [self loadTableViewData];
    [self setTableViewContent];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)loadTableViewData {
    if (_watchSession.activationState == WCSessionActivationStateActivated) {
        [self.tableView setNumberOfRows:DGMenuItemCount withRowType:kISControlRowIdentifierControl];
    } else {
        [self.tableView setNumberOfRows:1 withRowType:kISControlRowIdentifierSessionFailed];
    }
}
- (void)setTableViewContent {
    
    if (_watchSession.activationState == WCSessionActivationStateActivated) {
        // Loop through all menu items and set on table view rows
        for (int i=0; i<DGMenuItemCount; i++) {
            ISControlsTableViewRowController *controller = [self.tableView rowControllerAtIndex:i];
            switch (i) {
                case DGMenuItemZoom:
                    [controller.controlLabel setText:kDGZoomLabel];
                    break;
                case DGMenuItemBrightness:
                    [controller.controlLabel setText:kDGBrightnessLabel];
                    break;
                case DGMenuItemContrast:
                    [controller.controlLabel setText:kDGContrastLabel];
                    break;
                case DGMenuItemSaturation:
                    [controller.controlLabel setText:kDGSaturationLabel];
                    break;
                case DGMenuItemTorch:
                    [controller.controlLabel setText:kDGTorchLabel];
                    break;
                case DGMenuItemReset:
                    [controller.controlLabel setText:kDGResetLabel];
                    break;
//                case DGMenuItemCaptureImage:
//                    [controller.controlLabel setText:@"Camera"];
//                    break;
                    
                default:
                    break;
            }
        }
    }
}

- (nullable id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    if ([segueIdentifier isEqualToString:kISControlDisplaySegue]) {
        return [NSNumber numberWithInteger:rowIndex];
    } else {
        return nil;
    }
}

# pragma mark - Watch Session Delegate

/** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    
    if (_watchSession.activationState == WCSessionActivationStateActivated) {
        [self.tableView setNumberOfRows:DGMenuItemCount withRowType:kISControlRowIdentifierControl];
    } else {
        if (error) {
//            [FlurryWatch logWatchEvent:@"WatchApp Activation Error" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:error.code], @"code", error.description, @"description", nil]];
        }
        
        [self.tableView setNumberOfRows:1 withRowType:@"sessionFailedRow"];
    }
    
    [self setTableViewContent];
}

/** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
- (void)sessionDidBecomeInactive:(WCSession *)session {
    [self.tableView setNumberOfRows:1 withRowType:@"sessionFailedRow"];
    [self setTableViewContent];
}

/** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
- (void)sessionDidDeactivate:(WCSession *)session  {
    [self.tableView setNumberOfRows:1 withRowType:@"sessionFailedRow"];
    [self setTableViewContent];
}

@end




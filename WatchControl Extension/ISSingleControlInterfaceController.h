//
//  ISSingleControlInterfaceController.h
//  DigitalGlasses
//
//  Created by Kevin Hunt on 2017-04-30.
//  Copyright © 2017 ProphetStudios. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface ISSingleControlInterfaceController : WKInterfaceController

@property (strong, nonatomic) IBOutlet WKInterfaceLabel *controlLabel;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *increaseButton;
@property (strong, nonatomic) IBOutlet WKInterfaceButton *decreaseButton;

- (IBAction)increaseButtonPressed;
- (IBAction)decreaseButtonPressed;


@end

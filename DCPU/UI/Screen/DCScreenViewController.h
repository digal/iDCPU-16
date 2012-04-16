//
//  DCScreenViewController.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/16/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCScreenView.h"
#import "DCEmulator.h"

@interface DCScreenViewController : UIViewController {
    int _pixelMultiplier;
}

@property (nonatomic, strong) DCScreenView* screenView;

- (void) handleEmulator:(DCEmulator*)emulator;

@end

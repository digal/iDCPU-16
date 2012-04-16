//
//  DCAppDelegate.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCEmulator.h"

@class DCViewController;

@interface DCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DCViewController *viewController;

- (DCEmulator*) createEmulator;

@end

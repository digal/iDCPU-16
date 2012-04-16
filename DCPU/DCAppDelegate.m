//
//  DCAppDelegate.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCAppDelegate.h"

#import "DCViewController.h"
#import "DCEmulator.h"

@implementation DCAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    DCViewController *vc;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        vc = [[DCViewController alloc] initWithNibName:@"DCViewController_iPhone" bundle:nil];
    } else {
        vc = [[DCViewController alloc] initWithNibName:@"DCViewController_iPad" bundle:nil];
    }
    self.viewController = vc;
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}


@end

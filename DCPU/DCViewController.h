//
//  DCViewController.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCScreenViewController.h"
#import "DCEmulator.h"

@interface DCViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) DCScreenViewController *screen;
@property (strong, nonatomic) DCEmulator *dcpu; 
@end

//
//  DCScreenViewController.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/16/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ROW_CHARS = 32
#define COL_CHARS = 12

#define BORDER_PX = 16

#define CHAR_W = 4
#define CHAR_H = 8

#define PIX_W = CHAR_W*ROW_CHARS + BORDER_PX*2;
#define PIX_H = CHAR_H*COL_CHARS + BORDER_PX*2;


@interface DCScreenViewController : UIViewController {
    int _pixelMultiplier;
}


//- (void) handleEmulator;

@end

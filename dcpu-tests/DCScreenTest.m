//
//  DCScreenTest.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/16/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCScreenView.h"

@interface DCScreenTest : GHViewTestCase

@end

@implementation DCScreenTest

- (void) testBackgroundColor {
    DCScreenView *view = [[DCScreenView alloc] initWithFrame:CGRectMake(0, 0, 320, 256)];
    view.pixelMultiplier = 2;
    view->background     = 0x1; //blue
    [view setNeedsDisplay];
    GHVerifyView(view);

    view->background     = 0xc; //pink
    [view setNeedsDisplay];
    GHVerifyView(view);
}

- (void) testChars {
    DCScreenView *view = [[DCScreenView alloc] initWithFrame:CGRectMake(0, 0, 320, 256)];
    view.pixelMultiplier = 2;
    view->background     = 0xF; //white
    
    view->chars[0] = 'A' | (0x0F << 8); //black char on white bg
    
    //'A' in notch's default font would be 0x7E09, 0x7E00.
    view->font['A' * 2] = 0x7E09;
    view->font['A' * 2 + 1] = 0x7E00;

    [view setNeedsDisplay];
    GHVerifyView(view);
}


@end

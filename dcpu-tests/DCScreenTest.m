//
//  DCScreenTest.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/16/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCScreenView.h"
#import "DCBDFParser.h"

@interface DCScreenTest : GHViewTestCase

@end

@implementation DCScreenTest

- (void) testBackgroundColor {
    DCScreenView *view = [[DCScreenView alloc] initWithFrame:CGRectMake(0, 0, 288, 224)];
    view.pixelMultiplier = 2;
    view->background     = 0x1; //blue
    [view setNeedsDisplay];
    GHVerifyView(view);

    view->background     = 0xc; //pink
    [view setNeedsDisplay];
    GHVerifyView(view);
}

- (void) testChars {
    DCScreenView *view = [[DCScreenView alloc] initWithFrame:CGRectMake(0, 0, 288, 224)];
    view.pixelMultiplier = 2;
    view->background     = 0xF; //white
    
    view->chars[0] = 'A' | (0x0F << 8); //black char on white bg
    
    //'A' in notch's default font would be 0x7E09, 0x7E00.
    view->font['A' * 2] = 0x7E09;
    view->font['A' * 2 + 1] = 0x7E00;

    [view setNeedsDisplay];
    GHVerifyView(view);
}

- (void) testFont {
    NSString *testString = @"Hello, World!";
    DCScreenView *view = [[DCScreenView alloc] initWithFrame:CGRectMake(0, 0, 288, 224)];
    view.pixelMultiplier = 2;
    view->background     = 0xF; //white

    DCBDFParser *parser = [[DCBDFParser alloc] init];
    [parser loadBDFFromFile:@"atari-small"];
    
    memcpy(view->font, parser->font, VMEM_FONT_SIZE * sizeof(UInt16));
    for (int i=0; i<testString.length; i++) {
        char c = [testString characterAtIndex:i];
        view->chars[32 * 5 + 10 + i] = c | (0x0F << 8);
    }
    
    [view setNeedsDisplay];
    GHVerifyView(view);
}


@end

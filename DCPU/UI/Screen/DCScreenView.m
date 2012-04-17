//
//  DCScreenView.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/16/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCScreenView.h"
#define _FF ((float)0xFF/255.0)
#define _AA ((float)0xAA/255.0)
#define _55 ((float)0x55/255.0)


@implementation DCScreenView

@synthesize pixelMultiplier = _pixelMultiplier;

CGColorRef colors[16];

- (void)createColors {
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    //non-highlited colors
    colors[0x0] = CGColorCreate(space, (CGFloat[4]){0,    0,  0,1}); //black
    colors[0x1] = CGColorCreate(space, (CGFloat[4]){0,    0,_AA,1}); //blue
    colors[0x2] = CGColorCreate(space, (CGFloat[4]){0,  _AA,  0,1}); //green
    colors[0x3] = CGColorCreate(space, (CGFloat[4]){0,  _AA,_AA,1}); //cyan
    colors[0x4] = CGColorCreate(space, (CGFloat[4]){_AA,  0,  0,1}); //red
    colors[0x5] = CGColorCreate(space, (CGFloat[4]){_AA,  0,_AA,1}); //magenta
    colors[0x6] = CGColorCreate(space, (CGFloat[4]){_AA,_55,  0,1}); //brown
    colors[0x7] = CGColorCreate(space, (CGFloat[4]){_AA,_AA,_AA,1}); //gray

    //highlited colors
    colors[0x8] = CGColorCreate(space, (CGFloat[4]){_55,_55,_55,1}); //dgray
    colors[0x9] = CGColorCreate(space, (CGFloat[4]){_55,_55,_FF,1}); //lblue
    colors[0xA] = CGColorCreate(space, (CGFloat[4]){_55,_FF,_55,1}); //lgreen
    colors[0xB] = CGColorCreate(space, (CGFloat[4]){_55,_FF,_FF,1}); //lcyan
    colors[0xC] = CGColorCreate(space, (CGFloat[4]){_FF,_55,_55,1}); //pink
    colors[0xD] = CGColorCreate(space, (CGFloat[4]){_FF,_55,_FF,1}); //lmagenta
    colors[0xE] = CGColorCreate(space, (CGFloat[4]){_FF,_FF,_55,1}); //yellow
    colors[0xF] = CGColorCreate(space, (CGFloat[4]){_FF,_FF,_FF,1}); //white
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pixelMultiplier = 1;
        [self createColors];
//        self.backgroundColor = [UIColor blueColor];

    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    NSLog(@"drawrect: %@, pxX: %d", NSStringFromCGRect(rect), _pixelMultiplier);
    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextRetain(context);

    CGContextSetFillColorWithColor(context, colors[self->background]);
    CGContextFillRect(context, rect);
    
    for (int chx = 0; chx <ROW_CHARS; chx++) {
        for (int chy = 0; chy <COL_CHARS; chy++) {
            int x = BORDER_PX * _pixelMultiplier + (CHAR_W * chx * _pixelMultiplier);
            int y = BORDER_PX * _pixelMultiplier + (CHAR_H * chy * _pixelMultiplier);
//            NSLog(@"chCoord = %dx%d, coord=%dx%d", chx, chy, x, y);

            
            UInt16 chWord = self->chars[chy * ROW_CHARS + chx];
//            NSLog(@"chWord: 0x%04x", chWord);
            UInt8 fgColor = chWord >> 12;
            UInt8 bgColor = (chWord >> 8) & 0xF;

            CGContextSetFillColorWithColor(context, colors[bgColor]);
            CGContextSetStrokeColorWithColor(context, colors[fgColor]);
            
            CGContextFillRect(context, CGRectMake(x, y, CHAR_W * _pixelMultiplier, CHAR_H * _pixelMultiplier));
        }
    }
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

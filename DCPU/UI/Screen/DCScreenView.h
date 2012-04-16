//
//  DCScreenView.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/16/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCMemory.h"

//screen size in px
#define PIX_W (CHAR_W*ROW_CHARS + BORDER_PX*2)
#define PIX_H (CHAR_H*COL_CHARS + BORDER_PX*2)

#define BORDER_PX 16

@interface DCScreenView : UIView {
    @public 
    
    UInt16 chars[VMEM_DISPLAY_SIZE];
    UInt16 font [VMEM_FONT_SIZE];
    UInt16 background;
}


@property (nonatomic, assign) NSUInteger pixelMultiplier;

@end

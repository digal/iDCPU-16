//
//  Memory.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/16/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

/**************** VIDEO *****************/

#define ROW_CHARS 32
#define COL_CHARS 12

#define CHAR_W 4
#define CHAR_H 8

#define VMEM_DISPLAY_START 0x8000
#define VMEM_DISPLAY_SIZE  (ROW_CHARS * COL_CHARS) //0x0180
#define VMEM_FONT_START    0x8180
#define VMEM_FONT_SIZE     0x0100
#define VMEM_BG            0x8280


/**************** KEYBOARD *****************/
#define KB_BUFFER_START 0x9000
#define KB_BUFFER_SIZE  0x0010
#define KB_LAST_KEY_P   0x9010


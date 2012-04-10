//
//  DCEmulator.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MEMSIZE 10000

#define A regs[0]
#define B regs[1]
#define C regs[2]
#define X regs[3]
#define Y regs[4]
#define Z regs[5]
#define I regs[6]
#define J regs[7]

@interface DCEmulator : NSObject {
@public    
    UInt16 regs[8];
    UInt16 pc;
    UInt16 sp;
    UInt16 o;
    UInt16 mem[MEMSIZE];
}

- (void) step;
- (NSString*) state;

@end

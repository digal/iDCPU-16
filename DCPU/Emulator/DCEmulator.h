//
//  DCEmulator.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Instructions.h"
#import "Values.h"

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

    long cycles; 
}

- (void) step;
- (NSString*) state;

- (UInt16) getvalue:(UInt8)src;
- (void) setValue:(UInt16)value for:(UInt8)dst;


@end

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

#define MEMSIZE 0x10000
#define STACK_START 0xffff

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

//internal stuff for reading/writing values
- (UInt16) getValue:(UInt8)src;
- (void) setValue:(UInt16)value for:(UInt8)dst address:(UInt16)address;

//a should be processed before b, so whe should get destination address and modify PC/SP first
- (UInt16) getAddrForSet:(UInt8)dst;

//execute single word instruction
- (void) exec:(UInt16)instr;

//load binary into memory
- (void) loadBinary:(UInt16*)binary withLength:(UInt16)length;

@end

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

- (UInt16) getValue:(UInt8)src;
- (void) setValue:(UInt16)value for:(UInt8)dst;


@end

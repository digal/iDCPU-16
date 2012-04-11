//
//  DCEmulator.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCEmulator.h"
#import "ConciseKit.h"

@implementation DCEmulator

- (id)init {
    self = [super init];
    if (self) {
        self->sp = STACK_START;
        NSLog(@"%@", [self state]);
    }
    return self;
}

- (UInt16) getValue:(UInt8)src {
    if (src >= A && src <= J) {
        //0x00-0x07: register (A, B, C, X, Y, Z, I or J, in that order)
        return regs[src];
    } else if (src >= MEM_A && src <= MEM_J) { 
        //0x08-0x0f: [register]
        return mem[regs[src & 0x07]];
    } else if (src >= (A | 0x10) && src <= (J | 0x10)) { 
        //0x10-0x17: [next word + register]
        cycles++;
        return mem[regs[0x0f & src] + mem[pc++]];
    } else if (src >= (A | 0x10) && src <= (J | 0x10)) { 
        //0x10-0x17: [next word + register]
        cycles++;
        return mem[regs[0x0f & src] + mem[pc++]];
    } else if (src == POP) {
        //0x18: POP / [SP++]
        return mem[sp++];
    } else if (src == PEEK) {
        //0x19: PEEK / [SP]
        return mem[sp];
    } else if (src == SP) {
        //0x1b: SP
        return sp;
    } else if (src == PC) {
        //0x1c: PC
        return pc;
    } else if (src == O) {
        //0x1d: O
        return o;
    } else if (src == NWP) {
        //0x1e: [next word]
        cycles++;
        return mem[mem[pc++]];
    } else if (src == NW) {
        //0x1f: next word (literal)
        cycles++;
        return mem[pc++];
    } else {
        [self error:$str(@"Unknown source: 0x%02x", src)];
        return 0x00;
    }
}

- (void) setValue:(UInt16)value for:(UInt8)dst {
    if (dst >= A && dst <= J) {
        //0x00-0x07: register (A, B, C, X, Y, Z, I or J, in that order)
        regs[dst] = value;
    } else if (dst >= MEM_A && dst <= MEM_J) { 
        //0x08-0x0f: [register]
        mem[regs[dst & 0x07]] = value;
    } else if (dst >= (A | 0x10) && dst <= (J | 0x10)) { 
        //0x10-0x17: [next word + register]
        cycles++;
        mem[regs[0x0f & dst] + mem[pc++]] = value;
    } else if (dst == PUSH) {
        //0x1a: PUSH / [--SP]
        mem[--sp] = value;
    } else if (dst == SP) {
        //0x1b: SP
        sp = value;
    } else if (dst == PC) {
        //0x1c: PC
        pc = value;
    } else if (dst == O) {
        //0x1d: O
        o = value;
    } else if (dst == NWP) {
        //0x1e: [next word]
        mem[mem[pc++]] = value;
    } else {
        [self error:$str(@"Unknown destination: 0x%02x", dst)];
    }

}


- (void) step {
    
    
}

- (void)error:(NSString*)message {
    NSLog(@"ERROR: %@", message);
    NSLog(@"CPU: %@", [self state]);
}


- (NSString *)state {
    return $str(@"PC:0x%04x SP:0x%04x O:0x%04x \n A:0x%04x B:0x%04x C:0x%04x X:0x%04x Y:0x%04x Z:0x%04x I:0x%04x J:0x%04x", pc, sp, o, regs[A], regs[B], regs[C], regs[X], regs[Y], regs[Z], regs[I], regs[J]);
}

@end

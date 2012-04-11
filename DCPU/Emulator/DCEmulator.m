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
    } else if (src >= 0x20 && src <=0x3f) {
        //0x20-0x3f: literal value 0x00-0x1f (literal)
        return src & 0x1f;
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



- (void) exec:(UInt16) instr {
//    In a basic instruction, the lower four bits of the first word of the instruction are the opcode,
//    and the remaining twelve bits are split into two six bit values, called a and b.
//    a is always handled by the processor before b, and is the lower six bits.
//    In bits (with the least significant being last), a basic instruction has the format: bbbbbbaaaaaaoooo

    
//    * SET, AND, BOR and XOR take 1 cycle, plus the cost of a and b
//    * ADD, SUB, MUL, SHR, and SHL take 2 cycles, plus the cost of a and b
//    * DIV and MOD take 3 cycles, plus the cost of a and b
//    * IFE, IFN, IFG, IFB take 2 cycles, plus the cost of a and b, plus 1 if the test fails


    UInt8 op = instr         & 0xf;     //4 bit
    UInt8 a =  (instr >> 4)  & 0x3f;    //6 bit
    UInt8 b =  (instr >> 10) & 0x3f;    //6 bit
    UInt16 bValue;    
    switch (op) {
        case 0x0: 
            [self error:@"extended OPS are not supported yet"];
            break;
        case SET: //0x1: SET a, b - sets a to b
            cycles++;
            bValue = [self getValue:b];
            [self setValue:bValue for:a];
            break;
            
        default:
            [self error:$str(@"unknown op: %1x (instr %04x)", op, instr)];
            break;
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

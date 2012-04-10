//
//  Values.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/11/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

// Values: (6 bits)
//     0x00-0x07: register (A, B, C, X, Y, Z, I or J, in that order)
//     0x08-0x0f: [register]
//     0x10-0x17: [next word + register]
//          0x18: POP / [SP++]
//          0x19: PEEK / [SP]
//          0x1a: PUSH / [--SP]
//          0x1b: SP
//          0x1c: PC
//          0x1d: O
//          0x1e: [next word]
//          0x1f: next word (literal)
//     0x20-0x3f: literal value 0x00-0x1f (literal)


#define REG_A 0x00
#define REG_B 0x01
#define REG_C 0x02
#define REG_X 0x03
#define REG_Y 0x04
#define REG_Z 0x05
#define REG_I 0x06
#define REG_J 0x07

#define MEM_A 0x08
#define MEM_B 0x09
#define MEM_C 0x0a
#define MEM_X 0x0b
#define MEM_Y 0x0c
#define MEM_Z 0x0d
#define MEM_I 0x0e
#define MEM_J 0x0f

#define POP   0x18
#define SEEK  0x19
#define PUSH  0x1a



//
//  DCEmulatorTest.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GHUnitIOS/GHUnit.h> 
#import "DCEmulator.h"
#import "ConciseKit.h"

@interface DCOpCodesTest : GHTestCase {}
@end

@implementation DCOpCodesTest
DCEmulator* _emulator;

- (void)setUp {
    _emulator = [[DCEmulator alloc] init];
}

- (void)tearDown { 
    _emulator = nil;
}

- (void)testSetRegLiteral {

    //test literal
    int b = 0x3f; //literal 0x1f
    int a = X;
    
    UInt16 instr = SET | (a << 4) | (b << 10); //0xfc31
    GHTestLog($str(@"Instruction for \"SET X, 0x1f\": %04x", instr));
    [_emulator exec:instr];
    GHAssertEquals([_emulator getValue:X fromAddress:0x0], (UInt16)0x1f, @"SET X, 0x1f");
    GHAssertEquals(_emulator->cycles, 1l, @"SET REG, LITERAL should take 1 cycle");
}

- (void)testSetMemReg {
    //test memory write
    //SET [0x1000], X
    UInt16 val  = 0x1234;
    UInt16 addr = 0x1000;
    [_emulator setValue:val for:X forAddress:0x0]; //set x

    UInt16 program[2] = {
        SET | (NWP << 4) | (X << 10), //
        addr
    };
    GHTestLog($str(@"Instruction for \"SET [0x1000], X\": %04x %04x", program[0], program[1]));
    [_emulator loadBinary:&program[0] withLength:2];
    //TODO: rewrite for actual program execution
    [_emulator setValue:0x0001 for:PC forAddress:0x0]; //emulate running program
    [_emulator exec:program[0]];
    GHAssertEquals([_emulator getValue:PC fromAddress:0x0], (UInt16)2, @"PC should be incremented after setting to memory pointer");
    GHAssertEquals(_emulator->mem[addr], val, @"Value 0x1f should be copied from X to memory");
    GHAssertEquals(_emulator->cycles, 1l, @"SET [ADDR], REG should take 1 cycle");
}

- (void)testSetRegMem {
    //test memory read
    //SET Y, [0x1000]
    UInt16 val  = 0x1234;
    UInt16 addr = 0x1000;

    UInt16 program[2] = {
        SET | (Y << 4) | (NWP << 10), //
        addr
    };
    _emulator->mem[addr] = val; //put test value into memory
    GHTestLog($str(@"Instruction for \"SET Y, [0x1000]\": %04x %04x", program[0], program[1]));
    [_emulator loadBinary:&program[0] withLength:2];
    //TODO: rewrite for actual program execution
    [_emulator setValue:0x0001 for:PC forAddress:0x0]; //emulate running program
    [_emulator exec:program[0]];
    GHAssertEquals([_emulator getValue:PC fromAddress:0x0], (UInt16)2, @"PC should be incremented after setting to memory pointer");
    GHAssertEquals([_emulator getValue:Y fromAddress:0x0], val, @"Value 0x1f should be copied from memory to Y");
    GHAssertEquals(_emulator->cycles, 2l, @"SET REG, [ADDR] should take 2 cycles");
}

- (void)testSetMemMem {
    //test memory read
    //SET [0x2000], [0x1000]
    UInt16 val  = 0x1234;
    UInt16 srcAddr = 0x1000;
    UInt16 dstAddr = 0x2000;
    
    UInt16 program[3] = {
        SET | (NWP << 4) | (NWP << 10), //
        dstAddr,
        srcAddr
    };
    _emulator->mem[srcAddr] = val; //put test value into memory
    GHTestLog($str(@"Instruction for \"SET [0x2000], [0x1000]\": %04x %04x %04x", program[0], program[1], program[2]));
    [_emulator loadBinary:&program[0] withLength:3];
    //TODO: rewrite for actual program execution
    [_emulator setValue:0x0001 for:PC forAddress:0x0]; //emulate running program
    [_emulator exec:program[0]];
    GHAssertEquals([_emulator getValue:PC fromAddress:0x0], (UInt16)3, @"PC should be incremented after setting to memory pointer");
    GHAssertEquals(_emulator->mem[dstAddr], val, @"Value 0x1f should be copied from memory to memory");
    GHAssertEquals(_emulator->cycles, 2l, @"SET [ADDR], [ADDR] should take 2 cycles");
}

- (void)testSum {
    //ADD X, Y
    _emulator->regs[X]=0x1000;
    _emulator->regs[Y]=0x23ef;
    [_emulator exec:(ADD | (X << 4) | (Y << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x33ef, @"X should be equal X + Y");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should be 0x0, as there's no overflow");
    GHAssertEquals(_emulator->cycles, 2l, @"ADD should take 2 cycles");
}

- (void)testSumWithMemory {
    //ADD [0x1000], [0x2000]
    
    _emulator->mem[0x1000]=0x3200;
    _emulator->mem[0x2000]=0x23ef;
    
    UInt16 program[3] = {
        ADD | (NWP << 4) | (NWP << 10), //
        0x1000,
        0x2000
    };
    
    [_emulator loadBinary:&program[0] withLength:3];
    _emulator->pc = 0x1;
    [_emulator exec:program[0]];

    GHAssertEquals(_emulator->mem[0x1000], (UInt16)0x55ef, @"X should be equal X + Y");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should be 0x0, as there's no overflow");
    GHAssertEquals(_emulator->pc, (UInt16)0x3, @"pc should be 3");
    GHAssertEquals(_emulator->cycles, 4l, @"ADD [addr], [addr] should take 4 cycles");

}

- (void)testSumWithOverflow {
    //ADD [0x1000], [X] ; X=0x2000

    
    _emulator->mem[0x1000]=0xeeee;
    _emulator->mem[0x2000]=0xffff;
    _emulator->regs[X]=0x2000;
    
    UInt16 program[2] = {
        ADD | (NWP << 4) | (MEM_X << 10), //
        0x1000
    };
    
    [_emulator loadBinary:&program[0] withLength:2];
    _emulator->pc = 0x1;
    [_emulator exec:program[0]];
    
    GHAssertEquals(_emulator->mem[0x1000], (UInt16)0xeeed, @"X should be equal X + Y");
    GHAssertEquals(_emulator->o, (UInt16)0x0001, @"O should be 0x0001, as there's overflow");
    GHAssertEquals(_emulator->pc, (UInt16)0x2, @"pc should be 3");
    GHAssertEquals(_emulator->cycles, 3l, @"ADD [addr], [reg] should take 4 cycles");
}

- (void)testSub {
    //SUB Y, X
    _emulator->regs[Y]=0x23ef;
    _emulator->regs[X]=0x1234;
    [_emulator exec:(SUB | (Y << 4) | (X << 10))];
    GHAssertEquals(_emulator->regs[Y], (UInt16)0x11bb, @"Y should be equal Y - X");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should be 0x0, as there's no overflow");
    GHAssertEquals(_emulator->cycles, 2l, @"SUB should take 2 cycles");
}

- (void)testSubWithUnderflow {
    //SUB X, Y
    _emulator->regs[X]=0x1234;
    _emulator->regs[Y]=0x23ef;
    [_emulator exec:(SUB | (X << 4) | (Y << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0xee45, @"X should be equal X - Y");
    GHAssertEquals(_emulator->o, (UInt16)0xffff, @"O should be 0xffff, as there's an underflow");
    GHAssertEquals(_emulator->cycles, 2l, @"SUB should take 2 cycles");
}

- (void)testAnd {
    //AND X, 0x05
    _emulator->regs[X]=0x0f0f;
    [_emulator exec:(AND | (X << 4) | (0x25 << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0005, @"X should be equal 0x0f0f & 0x05");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should remain untouched");
    GHAssertEquals(_emulator->cycles, 1l, @"AND should take 1 cycles");
}

- (void)testBor {
    //BOR X, 0x05
    _emulator->regs[X]=0x0ff2;
    [_emulator exec:(BOR | (X << 4) | (0x25 << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0ff7, @"X should be equal 0x0ff2 | 0x05");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should remain untouched");
    GHAssertEquals(_emulator->cycles, 1l, @"BOR should take 1 cycles");
}

- (void)testXor {
    //XOR X, 0x17
    _emulator->regs[X]=0x0ff2;
    [_emulator exec:(XOR | (X << 4) | (0x37 << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0fe5, @"X should be equal 0x0ff2 ^ 0x17");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should remain untouched");
    GHAssertEquals(_emulator->cycles, 1l, @"XOR should take 1 cycles");
}

- (void)testShl {
    //SHL X, Y (0000 0110 = 0x06 -> 0011 0000 = 0x30)
    _emulator->regs[X]=0x0006; 
    _emulator->regs[Y]=0x0003;
    [_emulator exec:(SHL | (X << 4) | (Y << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0030, @"X should be equal 0x0006 << 3");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should remain untouched");
    GHAssertEquals(_emulator->cycles, 2l, @"SHL should take 2 cycles");
    
    //overflow
    //0x30 << 12 (0011 0000 = 0x30 -> 0000 0000 = 0x00, o = 0x03)
    [_emulator exec:(SHL | (X << 4) | (0x2c << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0000, @"X should be equal 0x0030 << 12");
    GHAssertEquals(_emulator->o, (UInt16)0x0003, @"O should be 3");
    GHAssertEquals(_emulator->cycles, 4l, @"SHL should take 2 cycles");
}

- (void)testShr {
    //SHR X, Y (0110 0000 = 0x60 -> 0000 0011 = 0x03)
    _emulator->regs[X]=0x0060; 
    _emulator->regs[Y]=0x0005;
    [_emulator exec:(SHR | (X << 4) | (Y << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0003, @"X should be equal 0x0060 >> 5");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should remain untouched");
    GHAssertEquals(_emulator->cycles, 2l, @"SHR should take 2 cycles");
    
    //overflow
    //0x03 >> 2 (0000 0011 = 0x03 -> 0000 0000 = 0x00, o = 0xc000)
    [_emulator exec:(SHR | (X << 4) | (0x22 << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0000, @"X should be equal 0x0003 >> 2");
    GHAssertEquals(_emulator->o, (UInt16)0xc000, @"O should be 0xc000");
    GHAssertEquals(_emulator->cycles, 4l, @"SHR should take 2 cycles");
}


@end

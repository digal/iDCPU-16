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
    [_emulator loadBinary:program withLength:2];
    [_emulator step];
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
    [_emulator loadBinary:program withLength:2];
    [_emulator step];
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
    [_emulator loadBinary:program withLength:3];
    //TODO: rewrite for actual program execution
    [_emulator step];
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
    
    [_emulator loadBinary:program withLength:3];
    [_emulator step];

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
    
    [_emulator loadBinary:program withLength:2];
    [_emulator step];
    
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

- (void)testMod {
    //MOD X, 0x03
    _emulator->regs[X]=0x00ff;
    [_emulator exec:(MOD | (X << 4) | (0x23 << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0, @"X should be equal 255 % 3");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should remain untouched");
    GHAssertEquals(_emulator->cycles, 3l, @"MOD should take 3 cycles");

    //MOD X, 0x03
    _emulator->regs[X]=0x00fe;
    [_emulator exec:(MOD | (X << 4) | (0x23 << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x02, @"X should be equal 254 % 3");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should remain untouched");
    GHAssertEquals(_emulator->cycles, 6l, @"MOD should take 3 cycles");

    //MOD X, Y(=0)
    _emulator->regs[X]=0x0ffe;
    _emulator->regs[Y]=0x0000;
    [_emulator exec:(MOD | (X << 4) | (Y << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x00, @"X should be equal zero");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should remain untouched");
    GHAssertEquals(_emulator->cycles, 9l, @"MOD should take 3 cycles");
}

- (void)testMul {
    //MUL X, 0x05 (255 * 5)
    _emulator->regs[X]=0x00ff;
    [_emulator exec:(MUL | (X << 4) | (0x25 << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x04fb, @"X should be equal 255 * 5 = 1275");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should remain untouched");
    GHAssertEquals(_emulator->cycles, 2l, @"MUL should take 2 cycles");

    //MUL X, 0x00  1275 * 0
    [_emulator exec:(MUL | (X << 4) | (0x20 << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0000, @"X should be equal 1275 * 0 = 0");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should remain untouched");
    GHAssertEquals(_emulator->cycles, 4l, @"MUL should take 2 cycles");

    //MUL X, 0x05 (0xffff * 0x50)
    _emulator->regs[X]=0xffff;
    _emulator->regs[Y]=0x0050;
    [_emulator exec:(MUL | (X << 4) | (Y << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0xffb0, @"X should be equal 0xffff * 0x0050 = 0xffb0");
    GHAssertEquals(_emulator->o, (UInt16)0x004f, @"O should be 0x004f");
    GHAssertEquals(_emulator->cycles, 6l, @"MUL should take 2 cycles");
}

- (void)testDiv {
    //DIV X, 0x05 (255 / 5)
    _emulator->regs[X]=0x00ff;
    [_emulator exec:(DIV | (X << 4) | (0x25 << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0033, @"X should be equal 255 / 5 = 51");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should remain untouched");
    GHAssertEquals(_emulator->cycles, 3l, @"DIV should take 3 cycles");
    
    //DIV X, 0x00  (51 / 0)
    [_emulator exec:(DIV | (X << 4) | (0x20 << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0000, @"X should be equal  0");
    GHAssertEquals(_emulator->o, (UInt16)0x0, @"O should be 0");
    GHAssertEquals(_emulator->cycles, 6l, @"DIV should take 3 cycles");
    
    //DIV X, Y  (16 / 64), overflow
    _emulator->regs[X]=0x0010;
    _emulator->regs[Y]=0x0040;
    [_emulator exec:(DIV | (X << 4) | (Y << 10))];
    GHAssertEquals(_emulator->regs[X], (UInt16)0x0000, @"X should be equal 0x0010 / 0x0040 = 0x0000");
    GHAssertEquals(_emulator->o, (UInt16)0x4000, @"O should be 0x10 0000 / 0x40 = 0x4000");
    GHAssertEquals(_emulator->cycles, 9l, @"DIV should take 3 cycles");
}

- (void)testIFE {
    UInt16 program[27] = {
        //equals
        IFE | (NW << 4) | (NW << 10), 0x1234, 0x1234, 
        SET | (NWP << 4) | (NW << 10), 0x1000, 0xABBA, //this should be executed

        //skip op with a word
        IFE | (NW << 4) | (NW << 10), 0x1234, 0x1235, 
        SET | (J << 4) | (NW << 10), 0xDEAD, //this should be skipped
        SET | (X << 4) | (NW << 10), 0xAAAA, //should be exec'd anyway

        //skip op with b word
        IFE | (0x25 << 4) | (NW << 10), 0x0006,
        SET | (NWP << 4) | (0x3f << 10), 0x1002, //this should be skipped
        SET | (Y << 4) | (NW << 10), 0xBBBB, //should be exec'd anyway

        //skip op with a and b words
        IFE | (NW << 4) | (NW << 10), 0x1234, 0xbcde,
        SET | (NWP << 4) | (NW << 10), 0x1003, 0xCACA, //this should be skipped
        SET | (I << 4) | (NW << 10), 0xCCCC //should be exec'd anyway
};
    
    [_emulator loadBinary:program withLength:27];
    while (_emulator->pc<27) {
        [_emulator step];
    }
    
    GHAssertEquals(_emulator->mem[0x1000], (UInt16)0xABBA, @"IFE should exec next instruction if numbers are equal");

    GHAssertEquals(_emulator->regs[J], (UInt16)0x0000, @"IFE should skip next op with arg words if a!=b");

    GHAssertEquals(_emulator->mem[0x1002], (UInt16)0x0000, @"IFE should skip next op with arg words if a!=b");

    GHAssertEquals(_emulator->regs[X], (UInt16)0xAAAA, @"This op should be executed anyway");
    GHAssertEquals(_emulator->regs[Y], (UInt16)0xBBBB, @"This op should be executed anyway");
    GHAssertEquals(_emulator->regs[I], (UInt16)0xCCCC, @"This op should be executed anyway");
}

- (void)testIFN {
    UInt16 program[28] = {
        //equals
        IFN | (NW << 4) | (NW << 10), 0x1234, 0x1235, 
        SET | (NWP << 4) | (NW << 10), 0x1000, 0xABBA, //this should be executed
        
        //skip op with a word
        IFN | (NW << 4) | (NW << 10), 0x1234, 0x1234, 
        SET | (J << 4) | (NW << 10), 0xDEAD, //this should be skipped
        SET | (X << 4) | (NW << 10), 0xAAAA, //should be exec'd anyway
        
        //skip op with b word
        IFN | (NW << 4) | (NW << 10), 0x0006, 0x0006,
        SET | (NWP << 4) | (0x3f << 10), 0x1002, //this should be skipped
        SET | (Y << 4) | (NW << 10), 0xBBBB, //should be exec'd anyway
        
        //skip op with a and b words
        IFN | (NW << 4) | (NW << 10), 0xbcde, 0xbcde,
        SET | (NWP << 4) | (NW << 10), 0x1003, 0xCACA, //this should be skipped
        SET | (I << 4) | (NW << 10), 0xCCCC //should be exec'd anyway
    };
    
    [_emulator loadBinary:program withLength:28];
    while (_emulator->pc<28) {
        [_emulator step];
    }
    
    GHAssertEquals(_emulator->mem[0x1000], (UInt16)0xABBA, @"IFN should exec next instruction if numbers are not equal");
    
    GHAssertEquals(_emulator->regs[J], (UInt16)0x0000, @"IFN should skip next op with arg words if a==b");
    
    GHAssertEquals(_emulator->mem[0x1002], (UInt16)0x0000, @"IFN should skip next op with arg words if a==b");
    
    GHAssertEquals(_emulator->regs[X], (UInt16)0xAAAA, @"This op should be executed anyway");
    GHAssertEquals(_emulator->regs[Y], (UInt16)0xBBBB, @"This op should be executed anyway");
    GHAssertEquals(_emulator->regs[I], (UInt16)0xCCCC, @"This op should be executed anyway");
}


@end

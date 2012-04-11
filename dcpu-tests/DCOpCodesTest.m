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

- (void)testSet {

    //test literal
    int b = 0x3f; //literal 0x1f
    int a = X;
    
    UInt16 instr = SET | (a << 4) | (b << 10); //0xfc31
    GHTestLog($str(@"Instruction for \"SET X, 0x1f\": %04x", instr));
    [_emulator exec:instr];
    GHAssertEquals([_emulator getValue:X], (UInt16)0x1f, @"SET X, 0x1f");
    
    //test memory
    //SET [0x1000], X
    UInt16 program[2] = {
            SET | (NWP << 4) | (X << 10), //
            0x1000
    };
    GHAssertEquals([_emulator getValue:PC], (UInt16)0, @"PC check");
    GHTestLog($str(@"Instruction for \"SET [0x1000], X\": %04x %04x", program[0], program[1]));
    [_emulator loadBinary:&program[0] withLength:2];
    //TODO: rewrite for actual program execution
    [_emulator setValue:0x0001 for:PC]; //emulate running program
    [_emulator exec:program[0]];
    GHAssertEquals([_emulator getValue:PC], (UInt16)2, @"PC should be incremented after setting to memory pointer");
    GHAssertEquals(_emulator->mem[0x1000], (UInt16)0x1f, @"Value 0x1f should be copied from X to memory");

}


@end

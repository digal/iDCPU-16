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

@interface DCEmulatorTest : GHTestCase {}
@end

@implementation DCEmulatorTest
DCEmulator* _emulator;

- (void)setUp {
    _emulator = [[DCEmulator alloc] init];
}

- (void)tearDown { 
    _emulator = nil;
}

- (void) testInitState {
    GHAssertTrue(_emulator->sp == 0x0000, @"Stack pointer should be 0x0000");
    GHAssertTrue(_emulator->pc == 0, @"PC should be 0");
    GHAssertTrue(_emulator->o  == 0,  @"Overflow flag should be 0");
    
    for (int i=0; i<=7; i++) {
        GHAssertTrue(_emulator->regs[i] == 0, @"Register %02x should be 0", i);
    }
}

- (void) testLoadBinary {
    UInt16 sample[4] = {0x0001, 0x0022, 0x0333, 0xffff};
    [_emulator loadBinary:sample withLength:4];
    
    for (int i=0; i<=3; i++) {
        GHAssertEquals(_emulator->mem[i], sample[i], $str(@"%dst word of program should be == %04x",i, sample[i]));
    }
}

- (void) testHandler {
    __block int calls = 0;
    DCHandler hndl = ^(DCEmulator* emu) {
        NSLog(@"called");
        calls++;
        if (calls == 1) {
            GHAssertEquals(emu->regs[X], (UInt16)1, @"X should be 1 after 1st call");
            GHAssertEquals(emu->regs[Y], (UInt16)2, @"Y should be 2 after 1st call");
            GHAssertEquals(emu->regs[Z], (UInt16)0, @"Z should be 0 after 1st call");
            GHAssertEquals(emu->mem[0x1000], (UInt16)0, @"mem[0x1000] should be 0 after 1st call");
        } else {
            GHAssertEquals(emu->regs[X], (UInt16)1, @"X should be 1 after 2nd call");
            GHAssertEquals(emu->regs[Y], (UInt16)2, @"Y should be 2 after 2nd call");
            GHAssertEquals(emu->regs[Z], (UInt16)3, @"Z should be 3 after 2nd call");
            GHAssertEquals(emu->mem[0x1000], (UInt16)4, @"mem[0x1000] should be 4 after 2nd call");
        }
    };
    [_emulator addHWHandler:hndl withPeriod:2 andName:@"test handler"];
    
    UInt16 program[5] = {
        SET | X << 4 | 0x21 << 10,
        SET | Y << 4 | 0x22 << 10,
        SET | Z << 4 | 0x23 << 10,
        SET | NWP << 4 | 0x24 << 10, 0x1000
    };
    
    [_emulator loadBinary:program withLength:5];
    [_emulator step];
    [_emulator step];
    GHAssertEquals(calls, 1, @"Handler should be called 1 time after 2 steps");
    [_emulator step];
    [_emulator step];
    GHAssertEquals(calls, 2, @"Handler should be called 2 tims after 4 steps");
    
    
}

@end

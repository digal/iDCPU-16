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
    for (int i=0; i<=7; i++) {
        GHAssertTrue(_emulator->regs[i] == 0, @"Register %02x should be 0", i);
    }
}

- (void) testRegisters {
    for (UInt8 reg=REG_A; reg<=REG_J; reg++) {
        UInt16 addr = 0x1000+reg*10;
        UInt16 val = 0x1234+reg;
        UInt8 memreg = 0x08 | reg;
        
        GHTestLog(@"reg: 0x%02x, memreg: 0x%02x", reg, memreg);
        
        [_emulator setValue:addr for:reg];
        GHAssertEquals(_emulator->regs[reg], addr, @"setValue should work for register");
        GHAssertEquals([_emulator getvalue:reg], addr, @"getValue should work for register");
        
        [_emulator setValue:val for:memreg];
        GHAssertEquals(_emulator->mem[addr], val, @"setValue should work for [register]");
        GHAssertEquals([_emulator getvalue:memreg], val, @"getValue should work for register");
    }
}

@end

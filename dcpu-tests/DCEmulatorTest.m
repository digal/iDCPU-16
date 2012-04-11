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
    GHAssertTrue(_emulator->sp == 0xffff, @"Stack pointer should be 0xffff");
    GHAssertTrue(_emulator->pc == 0, @"PC should be 0");
    GHAssertTrue(_emulator->o  == 0,  @"Overflow flag should be 0");
    
    for (int i=0; i<=7; i++) {
        GHAssertTrue(_emulator->regs[i] == 0, @"Register %02x should be 0", i);
    }
}

- (void) testLoadBinary {
    UInt16 sample[4] = {0x0001, 0x0022, 0x0333, 0xffff};
    [_emulator loadBinary:&sample[0] withLength:4];
    
    for (int i=0; i<=3; i++) {
        GHAssertEquals(_emulator->mem[i], sample[i], $str(@"%dst word of program should be == %04x",i, sample[i]));
    }
}

@end

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
@end

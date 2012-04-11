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
    int b = 0x3f; //literal 0x1f
    int a = X;
    int op = SET;
    
    UInt16 instr = op | (a << 4) | (b << 10);
    GHTestLog($str(@"Instruction for \"SET X, 0x1f\": %04x", instr));
    [_emulator exec:instr];
    GHAssertEquals([_emulator getValue:X], (UInt16)0x1f, @"SET X, 0x1f");
}


@end

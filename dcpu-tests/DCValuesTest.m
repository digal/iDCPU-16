//
//  DCEmulatorTest.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCEmulator.h"
#import <GHUnitIOS/GHUnit.h> 
#import "ConciseKit.h"

@interface DCValuesTest : GHTestCase {}
@end

@implementation DCValuesTest
DCEmulator* _emulator;


- (void)setUp {
    _emulator = [[DCEmulator alloc] init];
}
- (void)tearDown { 
    _emulator = nil;
}


- (void) testRegisters {
    GHTestLog(@"Testing src/dest from 0x00 to 0x0f (reg and [reg] cases)");

    for (UInt8 reg=A; reg<=J; reg++) {
        UInt16 addr = 0x1000+reg*10;
        UInt16 val = 0x1234+reg;
        UInt8 memreg = 0x08 | reg;
        
        GHTestLog(@"reg: 0x%02x, memreg: 0x%02x", reg, memreg);
        
        
        [_emulator setValue:addr for:reg forAddress:0x0];
        GHAssertEquals(_emulator->regs[reg], addr, @"setValue should work for register");
        GHAssertEquals([_emulator getValue:reg fromAddress:0x0], addr, @"getValue should work for register");
        
        UInt16 argAddr = [_emulator getAddr4Arg:memreg];
        GHAssertEquals(addr, argAddr, @"argAddr should be equal 0x%04x", addr);
        
        [_emulator setValue:val for:memreg forAddress:argAddr];
        GHAssertEquals(_emulator->mem[addr], val, @"setValue should work for [register]");
        GHAssertEquals([_emulator getValue:memreg fromAddress:argAddr], val, @"getValue should work for [register]");
    }
    
    UInt16 pcVal = 0x0010;
    [_emulator setValue:pcVal for:PC forAddress:0x0];
    GHAssertEquals(_emulator->pc, pcVal, @"setValue should work for PC");
    GHAssertEquals([_emulator getValue:PC fromAddress:0x0], pcVal, @"getValue should work for PC");

    UInt16 spVal = 0xfff0;
    [_emulator setValue:spVal for:SP forAddress:0x0];
    GHAssertEquals(_emulator->sp, spVal, @"setValue should work for SP");
    GHAssertEquals([_emulator getValue:SP fromAddress:0x0], spVal, @"getValue should work for SP");

    UInt16 underflow = 0xffff;
    [_emulator setValue:underflow for:O forAddress:0x0];
    GHAssertEquals(_emulator->o, underflow, @"setValue should work for O, trimming its value to 1 bit");
    GHAssertEquals([_emulator getValue:O fromAddress:0x0], underflow, @"getValue should work for O");

}

//TODO: less obscure test
- (void) testNextWordAndReg {
    GHTestLog(@"Testing src/dest from 0x10 to 0x1f ([reg + next word] case)");
    GHTestLog(@"Setting each target word in memory to corresponding register number");
    
    GHAssertEquals(_emulator->pc, (UInt16)0, @"PC should be zero at the beginning");
    GHAssertEquals(_emulator->cycles, (long)0, @"cycles should be 0 at the beginning");
    
    for (UInt8 reg=A; reg<=J; reg++) {
        //each target word should contain corresponding register number
        UInt16 nwValue = 0x1000 + reg;
        UInt16 addr = nwValue + reg;
        GHTestLog(@"reg: 0x%02x, nwValue: 0x%04x, addr: 0x%04x", reg, nwValue, addr);
        _emulator->mem[reg]  = nwValue;
        
        [_emulator setValue:reg for:reg forAddress:0x0];
        
        UInt16 argAddr = [_emulator getAddr4Arg:(0x10 | reg)]; 
        GHAssertEquals(addr, argAddr, @"argAddr should be equal 0x%04x", addr);
        [_emulator setValue:reg for:(0x10 | reg) forAddress:argAddr];
    }

    GHAssertEquals(_emulator->cycles, (long)8, @"cycles should be 8 after set loop");
    GHAssertEquals(_emulator->pc, (UInt16)8, @"pc should point to 0x08 after set loop");

    //reset PC
    _emulator->pc = 0;
    for (UInt8 src=0x10; src<=0x17; src++) {
        UInt16 targetVal = (UInt16)(src & 0x0f);
        UInt16 targetAddr = 0x1000 + ((src & 0x0f) * 2);
        UInt16 argAddr = [_emulator getAddr4Arg:src];
        
        GHAssertEquals(targetAddr, argAddr, $str(@"getAddr4Arg should be 0x%04x", targetAddr));

        
        GHTestLog(@"src: 0x%02x, addr: 0x%04x", src, targetAddr);

        GHAssertEquals(_emulator->mem[targetAddr], targetVal, @"[nextword + register] should be register number");
        GHAssertEquals([_emulator getValue:src fromAddress:targetAddr], targetVal, @"getValue for [nextword + register] should be register number");
    }
    
    GHAssertEquals(_emulator->pc, (UInt16)8, @"pc should point to 0x08 after set loop");
    GHAssertEquals(_emulator->cycles, (long)16, @"cycles should be 16 after set loop");
}

- (void) testStack {
    GHAssertEquals(_emulator->cycles, (long)0, @"cycles should be 0 at the beginning");
    GHAssertEquals([_emulator getValue:SP fromAddress:0x0],  (UInt16)0x0000, @"SP should point to the beginning of the stack");

    UInt16 argAddr = [_emulator getAddr4Arg:PUSH];
    [_emulator setValue:1 for:PUSH forAddress:argAddr];
    NSLog(@"PUSH %@", [_emulator state]);
    GHAssertEquals([_emulator getValue:SP fromAddress:0x0],  (UInt16)0xffff, @"SP should point to the beginning of the stack - 1 word");
    
    argAddr = [_emulator getAddr4Arg:PUSH];
    [_emulator setValue:2 for:PUSH forAddress:argAddr];
    NSLog(@"PUSH %@", [_emulator state]);
    GHAssertEquals([_emulator getValue:SP fromAddress:0x0],  (UInt16)0xfffe, @"SP should point to the beginning of the stack - 2 words");
    
    argAddr = [_emulator getAddr4Arg:PUSH];
    [_emulator setValue:3 for:PUSH forAddress:argAddr];
    NSLog(@"PUSH %@", [_emulator state]);
    GHAssertEquals([_emulator getValue:SP fromAddress:0x0],  (UInt16)0xfffd, @"SP should point to the beginning of the stack - 3 words");

    
    argAddr = [_emulator getAddr4Arg:PEEK];
    GHAssertEquals([_emulator getValue:PEEK fromAddress:argAddr], (UInt16)3, @"Seek should read 3");
    GHAssertEquals([_emulator getValue:SP fromAddress:0x0],  (UInt16)0xfffd, @"SP should point to the beginning of the stack - 3 words");
    NSLog(@"PEEK %@", [_emulator state]);

    argAddr = [_emulator getAddr4Arg:PEEK];
    GHAssertEquals([_emulator getValue:PEEK fromAddress:argAddr], (UInt16)3, @"Seek should not change a stack pointer");
    GHAssertEquals([_emulator getValue:SP fromAddress:0x0],  (UInt16)0xfffd, @"SP should point to the beginning of the stack - 3 words");
    NSLog(@"PEEK %@", [_emulator state]);
    
    argAddr = [_emulator getAddr4Arg:POP];
    GHAssertEquals([_emulator getValue:POP fromAddress:argAddr],  (UInt16)3, @"Pop should pop 3");
    GHAssertEquals([_emulator getValue:SP fromAddress:0x0],  (UInt16)0xfffe, @"SP should point to the beginning of the stack - 2 words");
    NSLog(@"POP %@", [_emulator state]);

    argAddr = [_emulator getAddr4Arg:POP];
    GHAssertEquals([_emulator getValue:POP fromAddress:argAddr],  (UInt16)2, @"Pop should pop 2");
    GHAssertEquals([_emulator getValue:SP fromAddress:0x0],  (UInt16)0xffff, @"SP should point to the beginning of the stack - 1 word");
    NSLog(@"POP %@", [_emulator state]);
    
    argAddr = [_emulator getAddr4Arg:PEEK];
    GHAssertEquals([_emulator getValue:PEEK fromAddress:argAddr], (UInt16)1, @"Seek should read 1");
    GHAssertEquals([_emulator getValue:SP fromAddress:0x0],  (UInt16)0xffff, @"SP should point to the beginning of the stack - 1 word");
    NSLog(@"PEEK %@", [_emulator state]);
    
    argAddr = [_emulator getAddr4Arg:POP];
    GHAssertEquals([_emulator getValue:POP fromAddress:argAddr],  (UInt16)1, @"Pop should pop 1");
    GHAssertEquals([_emulator getValue:SP fromAddress:0x0],  (UInt16)0x0000, @"SP should point to the beginning of the stack");
    NSLog(@"POP %@", [_emulator state]);
    

    GHAssertEquals(_emulator->cycles, (long)0, @"cycles should not increase when working with stack");
}

- (void)testMemory {
    UInt16 val  = 0x1234;
    UInt16 addr = 0x1000;

    //put target address to [PC]
    _emulator->mem[0] = addr;
    //put value to [target address]
    UInt16 argAddr = [_emulator getAddr4Arg:NWP];
    [_emulator setValue:val for:NWP forAddress:argAddr];
    
    GHAssertEquals([_emulator getValue:PC fromAddress:0x0], (UInt16)0x1,  @"Setting [next word] should increase PC");
    [_emulator setValue:0x0 for:PC forAddress:0x0]; //reset pc;
    GHAssertEquals([_emulator getValue:PC fromAddress:0x0], (UInt16)0x0,  @"Resetting PC check");
    
    argAddr = [_emulator getAddr4Arg:NW];
    GHAssertEquals([_emulator getValue:NW fromAddress:argAddr], (UInt16)addr, @"Getting next word literal should return target addr");
    GHAssertEquals(_emulator->cycles, (long)1,            @"reading a word should increase cycles");
    GHAssertEquals([_emulator getValue:PC fromAddress:0x0], (UInt16)0x1,  @"Getting next word literal should increase PC");

    [_emulator setValue:0x0 for:PC forAddress:0x0]; //reset pc;
    GHAssertEquals([_emulator getValue:PC fromAddress:0x0], (UInt16)0x0,  @"Resetting PC check");
    
    argAddr = [_emulator getAddr4Arg:NWP];
    GHAssertEquals([_emulator getValue:NWP fromAddress:argAddr], (UInt16)val, @"Getting [next word] should return target value");
    GHAssertEquals(_emulator->cycles, (long)2,            @"reading a [word] should increase cycles");
    GHAssertEquals([_emulator getValue:PC fromAddress:0x0], (UInt16)0x1,  @"Getting [next word] should increase PC");
}

- (void)testLiterals {
    GHAssertEquals([_emulator getValue:0x20 fromAddress:0x0], (UInt16)0x00,  @"Getting first literal");
    GHAssertEquals([_emulator getValue:0x3f fromAddress:0x0], (UInt16)0x1f,  @"Getting last literal");
    GHAssertEquals([_emulator getValue:0x31 fromAddress:0x0], (UInt16)0x11,  @"Getting random literal");
}


@end

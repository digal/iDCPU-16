//
//  DCEmulator.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCInstructions.h"
#import "DCValues.h"
#import "DCHardwareHandler.h"
#import "DCMemory.h"

#define MEMSIZE 0x10000

//https://twitter.com/#!/notch/status/187636538870468608
//SP starts at 0. The first PUSH is to --SP, which is 0xFFFF
#define STACK_START 0x0000; 

@interface DCEmulator : NSObject {
@public    
    UInt16 regs[8];
    UInt16 pc;
    UInt16 sp;
    UInt16 o;
    UInt16 mem[MEMSIZE];

    long cycles; 
}

@property (nonatomic, retain) NSMutableArray* handlers;


- (void) step;
- (NSString*) state;
- (void)addHWHandler:(DCHandler)handler withPeriod:(int)period andName:(NSString*)name;

//internal stuff for reading/writing values
- (UInt16) getValue:(UInt8)src fromAddress:(UInt16)address;
- (void) setValue:(UInt16)value for:(UInt8)dst forAddress:(UInt16)address;

//a should be processed before b, so whe should get destination address and modify PC/SP first
- (UInt16) getAddr4Arg:(UInt8)dst;

//execute single word instruction
- (void) exec:(UInt16)instr;

//load binary into memory
- (void) loadBinary:(UInt16*)binary withLength:(UInt16)length;

@end

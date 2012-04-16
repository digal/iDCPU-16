//
//  Instructions.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#define JSR 0x01 //JSR a - pushes the address of the next instruction to the stack, then sets PC to a
#define SET 0x1  //SET a, b - sets a to b
#define ADD 0x2  //ADD a, b - sets a to a+b, sets O to 0x0001 if there's an overflow, 0x0 otherwise
#define SUB 0x3  //SUB a, b - sets a to a-b, sets O to 0xffff if there's an underflow, 0x0 otherwise
#define MUL 0x4  //MUL a, b - sets a to a*b, sets O to ((a*b)>>16)&0xffff
#define DIV 0x5  //DIV a, b - sets a to a/b, sets O to ((a<<16)/b)&0xffff. if b==0, sets a and O to 0 instead.
#define MOD 0x6  //MOD a, b - sets a to a%b. if b==0, sets a to 0 instead.
#define SHL 0x7  //SHL a, b - sets a to a<<b, sets O to ((a<<b)>>16)&0xffff
#define SHR 0x8  //SHR a, b - sets a to a>>b, sets O to ((a<<16)>>b)&0xffff
#define AND 0x9  //AND a, b - sets a to a&b
#define BOR 0xa  //BOR a, b - sets a to a|b
#define XOR 0xb  //XOR a, b - sets a to a^b
#define IFE 0xc  //IFE a, b - performs next instruction only if a==b
#define IFN 0xd  //IFN a, b - performs next instruction only if a!=b
#define IFG 0xe  //IFG a, b - performs next instruction only if a>b
#define IFB 0xf  //IFB a, b - performs next instruction only if (a&b)!=0
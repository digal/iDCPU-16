//
//  DCProgram.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/22/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCProgram.h"

@implementation DCProgram
@synthesize bytecode;
@synthesize debugSymbols;

- (id)init {
    self = [super init];
    if (self) {
        bytecode = [NSMutableArray array];
    }
    return self;
}

@end

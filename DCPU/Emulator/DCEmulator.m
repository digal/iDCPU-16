//
//  DCEmulator.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/10/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCEmulator.h"
#import "ConciseKit.h"

@implementation DCEmulator

- (id)init {
    self = [super init];
    if (self) {
        NSLog(@"%@", [self state]);
    }
    return self;
}

- (void) step {
    
}

- (NSString *)state {
    return $str(@"A:0x%04x B:0x%04x C:0x%04x X:0x%04x Y:0x%04x Z:0x%04x I:0x%04x J:0x%04x \n", A, B, C, X, Y, Z, I, J);
}

@end

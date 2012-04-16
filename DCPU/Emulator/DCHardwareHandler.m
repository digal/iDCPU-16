//
//  DCHardwareHandler.m
//  DCPU
//
//  Created by Yuriy Buyanov on 4/16/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import "DCHardwareHandler.h"

@implementation DCHardwareHandler

@synthesize handler;
@synthesize name;

- (id)initWithHandler:(DCHandler)handlerBlock period:(int)cycles andName:(NSString*)handlerName{
    self = [super init];
    if (self) {
        self.handler = handlerBlock;
        self.name = handlerName;
        self->period = cycles;
        self->lastCall = 0;
    }
    return self;
    
}

@end

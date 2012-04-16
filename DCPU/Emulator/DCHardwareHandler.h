//
//  DCHardwareHandler.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/16/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//


#import <Foundation/Foundation.h>

typedef void (^DCHandler)(id);

#import "DCEmulator.h"

@interface DCHardwareHandler : NSObject {
    @public  

    int period;
    int lastCall;
}

@property (nonatomic, copy) DCHandler handler;
@property (nonatomic, retain) NSString* name;

- (id)initWithHandler:(DCHandler)handlerBlock period:(int)cycles andName:(NSString*)handlerName;

@end


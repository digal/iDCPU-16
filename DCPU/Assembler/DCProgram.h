//
//  DCProgram.h
//  DCPU
//
//  Created by Yuriy Buyanov on 4/22/12.
//  Copyright (c) 2012 e-Legion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCProgram : NSObject 
    @property (nonatomic, strong) NSArray *bytecode;
    @property (nonatomic, strong) NSDictionary *debugSymbols;
@end
